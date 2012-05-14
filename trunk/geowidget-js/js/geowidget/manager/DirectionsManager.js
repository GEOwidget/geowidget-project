/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.manager.DirectionsManager', function(Y){

    YUI.namespace("geowidget.manager");
    
    YUI.geowidget.manager.DirectionsManager = function(map){
        var that = this;
        that.map = map;
        that.displayRoute = false;
        that.directions = new google.maps.Directions();
        that.directionsOptions = {
            locale: YUI.geowidget.Model.config.locale,
            travelMode: G_TRAVEL_MODE_DRIVING,
            getPolyline: true,
            getSteps: true
        };
        YUI.geowidget.Model.after('selectedLocationChange', function(){
            if (YUI.geowidget.Model.get('selectedLocation') && (YUI.geowidget.Model.get('selectedLocation')!== that.toLocation)) {
                // another location is selected as the one that displays the route, so hide the route
                that.hideRoute();
            }
        });
    };
    
    YUI.geowidget.manager.DirectionsManager.prototype.createInfoWindow = function(location){
        if (this.displayRoute && location == this.toLocation) {
            var numRoutes = this.directions.getNumRoutes();
            var r = 0;
            var route = this.directions.getRoute(r);
            
            var itemTemplate = YUI.geowidget.Model.config.templates.directionsItem;
            var template = YUI.geowidget.Model.config.templates.directions;
            var obj = Y.merge(location, {
                startAddress: this.directions.getGeocode(r).address,
                endAddress: this.directions.getGeocode(r + 1).address,
                routeDistance: route.getDistance().html,
                routeDuration: route.getDuration().html,
                routeSummary: route.getSummaryHtml()
            });
            var infoWindow = YUI.ms.TemplateLoader.applyTemplate(template, obj);
            var infoWindowNode = Y.Node.create(infoWindow.html);
            var itemList = infoWindowNode.query('div.routeTablePlaceholder');
            var numSteps = route.getNumSteps();
            for (var stepNumber = 0; stepNumber < numSteps; stepNumber++) {
                var step = route.getStep(stepNumber);
                var item = Y.Node.create(YUI.ms.TemplateLoader.applyTemplate(itemTemplate, Y.merge(obj, {
                    stepNumber: stepNumber + 1,
                    stepDescription: step.getDescriptionHtml(),
                    stepDistance: step.getDistance().html,
                    stepDuration: step.getDuration().html
                })).html);
                itemList.append(item);
            }
            infoWindow.html = YUI.ms.NodeHelper.getHTML(infoWindowNode);
            return infoWindow;
        }
        else {
            return YUI.ms.TemplateLoader.applyTemplate(YUI.geowidget.Model.config.templates.route, location);
        }
    };
    
    YUI.geowidget.manager.DirectionsManager.prototype.showStep = function(route, step){
        this.map.showMapBlowup(this.directions.getRoute(route).getStep(step).getLatLng());
    };
    
    YUI.geowidget.manager.DirectionsManager.prototype.hideRoute = function(){
        this.displayRoute = false;
		YUI.geowidget.Model.managers.clusterManager.unhighlightMarker();
        if (this.tooltip) {
            this.tooltip.hide();
        }
        if (this._line !== undefined) {
            this.map.removeOverlay(this._line);
        }
        if (this._positionOverlay !== undefined) {
            this.map.removeOverlay(this._positionOverlay);
        }
    };
    
    YUI.geowidget.manager.DirectionsManager.prototype.showRoute = function(){
		YUI.geowidget.Model.managers.clusterManager.highlightMarker(this.toLocation.marker);
        if (this._line !== undefined) {
            this.map.addOverlay(this._line);
        }
		/*
        if (this._positionOverlay !== undefined) {
            this.map.addOverlay(this._positionOverlay);
        }
		*/
        this.displayRoute = true;
    };
    
    YUI.geowidget.manager.DirectionsManager.prototype.printRoute = function(){
        var saddr = encodeURIComponent(this.fromLocation.address);
        var daddr = encodeURIComponent(this.toLocation.address);
        
        var routeWindow = window.open("http://maps.google.de/maps?pw=2&saddr=" + saddr + "&daddr=" + daddr, '_blank', "width=769,height=832,status=yes,scrollbars=yes,resizable=yes");
        routeWindow.focus();
    };
    
    YUI.geowidget.manager.DirectionsManager.prototype.calcRoute = function(fromLocation, toLocation){
        var addHideTool = function(overlay, latLng){
            if (!that.tooltip) {
                that.tooltip = new Tooltip(YUI.geowidget.I18N.getText('directionsManager.removeRoute'), 4);
                that.map.addOverlay(that.tooltip);
                google.maps.Event.addListener(that.tooltip, 'click', function(){
                    that.hideRoute();
                });
            }
            google.maps.Event.addListener(overlay, 'mouseover', function(){
                that.tooltip.setLatLng(latLng);
                that.tooltip.show();
                setTimeout(function(){
                    that.tooltip.hide();
                }, 3000);
            });
            google.maps.Event.addListener(overlay, 'click', function(){
                that.hideRoute();
            });
        };
        var that = this;
        that.fromLocation = fromLocation;
        that.toLocation = toLocation;
        this.directions.clear();
        var eventListener = google.maps.Event.addListener(that.directions, "load", function(){
			that.hideRoute();
			that._line = that.directions.getPolyline();
			
			var startPlacemark = that.directions.getRoute(0).getStartGeocode();
			var startLatLng = that._line.getVertex(0);
			var endLatLng = that._line.getVertex(that._line.getVertexCount() - 1);
			that._positionOverlay = that.createPosition({
				address: startPlacemark.address,
				latLng: startLatLng
			});
			
			if (that._positionOverlay !== undefined) {
				// #151 Add position marker always
				that.map.addOverlay(that._positionOverlay);
			}
			
			YUI.geowidget.Model.managers.zoomManager.zoomToBounds(that._line.getBounds());
			that.lastDistance = that.directions.getDistance();
			
			if(YUI.geowidget.Model.config.features.showRoute === true) {
				addHideTool(that._positionOverlay, startLatLng);
				addHideTool(that._line, that._line.getBounds().getCenter());
				that.showRoute();
			}
			
            YUI.geowidget.InfoWindowFactory.displayLocationInfoWindow(that.map, that.toLocation, {
                showRouteTab: YUI.geowidget.Model.config.features.showRoute
            });
            google.maps.Event.removeListener(eventListener);
        });
        this.directions.loadFromWaypoints([fromLocation.latLng, toLocation.latLng], this.directionsOptions);
    };
    
    YUI.geowidget.manager.DirectionsManager.prototype.createPosition = function(placemark){
		var positionIcon = YUI.geowidget.Model.config.positionIcon || {
			image:		'assets/position.png',
			overImage:	'assets/position.png',
			width:		30,
			height:		30
		};

		var icon = new google.maps.Icon();
        icon.image = positionIcon.image;
        icon.iconSize = new google.maps.Size(positionIcon.width, positionIcon.height);
        icon.iconAnchor = new google.maps.Point(15, 15);
		
        var marker = new google.maps.Marker(placemark.latLng, {
            icon: icon,
            title: placemark.address
        });
		
		// If overImage is different set the hover behavior
		if(positionIcon.overImage !== null && positionIcon.overImage != positionIcon.image) {
			google.maps.Event.addListener(marker, "mouseover", function(){
				marker.setImage(positionIcon.overImage);
			});
			
			google.maps.Event.addListener(marker, "mouseout", function(){
				marker.setImage(positionIcon.image);
			});
		}
		
        return marker;
    };
    
}, '0.0.1', {
    requires: ['ms.NodeHelper']
});
