/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.MarkerFactory', function(Y){
    YUI.namespace("geowidget");
    
    YUI.geowidget.MarkerFactory = function(map, infoWindowFactory, zoomManager){
        var that = this;
        this.map = map;
        this.infoWindowFactory = infoWindowFactory;
        this.zoomManager = zoomManager;
        YUI.geowidget.Model.after('selectedLocationChange', function(){
            var location = YUI.geowidget.Model.get('selectedLocation');
            if (location) {
				// center to the location and zoom to maximal zoom range of the location
				// if a zoom range is not defined zoom to zoom level 14
				// also if user is at a higher zoom level than the calculated one, don't do anything as the user does
				// not want to zoom out 
				var locationZoom = location.zoomRange ? location.zoomRange[1] : 14;
                that.map.setCenter(location.marker.getLatLng(), that.map.getZoom() > locationZoom ? that.map.getZoom() : locationZoom);
                that.infoWindowFactory.displayLocationInfoWindow(that.map, location);
            }
        });
    };
    
    YUI.geowidget.MarkerFactory.prototype.addInfoToMarker = function(marker, location){
        google.maps.Event.addListener(marker, "click", function(){
            YUI.geowidget.Model.setLocation(location);
        });
    };
    
    YUI.geowidget.MarkerFactory.prototype.lookupIcon = function(id){
        return Y.Array.find(YUI.geowidget.Model.config.icons, function(icon){
            return icon.id === id;
        });
    };
    
    YUI.geowidget.MarkerFactory.prototype.lookupCluster = function(id){
        var clusters = YUI.geowidget.Model.config.clusters;
        if (Y.Lang.isArray(clusters) && clusters.length > 0) {
            var cluster = Y.Array.find(clusters, function(cluster){
                return cluster.id === id;
            });
            if (cluster === null) {
                cluster = clusters[0];
            }
        }
        else {
            cluster = {};
        }
        return cluster;
    };
    
    YUI.geowidget.MarkerFactory.prototype.getNormalIcon = function(id){
        if (id === undefined) {
            return 'assets/logo/logo.png';
        }
        else {
            return YUI.geowidget.Model.root + '/' + this.lookupIcon(id).image;
        }
    };
    
    YUI.geowidget.MarkerFactory.prototype.getOverIcon = function(id){
        if (id === undefined) {
            return 'assets/logo/overLogo.png';
        }
        else {
            return YUI.geowidget.Model.root + '/' + this.lookupIcon(id).overImage;
        }
    };
	
    YUI.geowidget.MarkerFactory.prototype.getzIndex = function(id){
		var that = this;
        if (id) {
			var icon = that.lookupIcon(id);
			if (icon.zIndex) {
				return function(){
					return icon.zIndex;
				};
			}
        }
        return undefined;
    };
    
    YUI.geowidget.MarkerFactory.prototype.getClusterIcon = function(id){
        var cluster = this.lookupCluster(id);
        return {
            'url': cluster.image ? YUI.geowidget.Model.root + '/' + cluster.image : 'assets/logo/cluster.png',
            'width': cluster.width || 30,
            'height': cluster.height || 30,
            'opt_anchor': [cluster.anchorY || 0, cluster.anchorX || 0],
            'opt_textColor': cluster.color || '#000000',
            'opt_textSize': cluster.fontSize || 11
        };
    };
    
    YUI.geowidget.MarkerFactory.prototype.createIcon = function(location){
        var icon = new google.maps.Icon();
        icon.image = this.getNormalIcon(location.icon);
        if (location.icon === undefined) {
            icon.iconSize = new google.maps.Size(32, 37);
            icon.iconAnchor = new google.maps.Point(6, 37);
        }
        else {
            var iconObj = this.lookupIcon(location.icon);
            icon.iconSize = new google.maps.Size(iconObj.width, iconObj.height);
            if (iconObj.anchorX === undefined || iconObj.anchorY === undefined) {
                // if anchor is not defined, put it at the image's center
                icon.iconAnchor = new google.maps.Point(iconObj.width / 2, iconObj.height / 2);
            }
            else {
                icon.iconAnchor = new google.maps.Point(iconObj.anchorX, iconObj.anchorY);
            }
        }
        return icon;
    };
    
    YUI.geowidget.MarkerFactory.prototype.createMarker = function(location){
        var clickable = YUI.geowidget.Model.config.features.showRoute || location.hasInfoWindow();
        
        var marker = new google.maps.Marker(location.latLng, {
            icon: this.createIcon(location),
            title: location.city,
            clickable: clickable,
			zIndexProcess: this.getzIndex(location.icon)
        });
        
        if (clickable) {
            var normalIconSrc = this.getNormalIcon(location.icon);
            var overIconSrc = this.getOverIcon(location.icon);
            
            // only add mouseover and click events if there is some information to display
            
            google.maps.Event.addListener(marker, "mouseover", function(){
                marker.setImage(overIconSrc);
            });
            
            google.maps.Event.addListener(marker, "mouseout", function(){
                marker.setImage(normalIconSrc);
            });
            this.addInfoToMarker(marker, location);
        }
        
        // store location data in marker object - not nice but needed for determining the actual locations of a cluster
        marker._location = location;
        
        return marker;
    };
    
    YUI.geowidget.MarkerFactory.prototype.createMarkers = function(locations){
        var clusters = {};
        var that = this;
        
        locations.every(function(location){
            var marker = that.createMarker(location);
            var id = location.cluster;
            
            // FIXME: Store marker object into locations' list
            // Is there another way to determinate all (only visible) markers on map?
            location.marker = marker;
            location.iconImage = that.getNormalIcon(location.icon);
            
            if (!clusters[id]) {
                // Create separated hash for markers
                clusters[id] = [];
            }
            // Store marker in hash
            clusters[id].push(marker);
            if (YUI.geowidget.Model.config.features.dontCluster) {
                that.map.addOverlay(marker);
            }
            that.createEdges(location, locations);
        });
        
        if (!YUI.geowidget.Model.config.features.dontCluster) {
            YUI.geowidget.Model.clusterers = {};
            
            Y.Object.each(clusters, function(_markers, _id){
                if (_id === "undefined") {
                    _id = undefined;
                }
                
                var markerClusterer = new MarkerClusterer(that.map, _markers, {
                    gridSize: that.lookupCluster(_id).gridSize || 50,
                    maxZoom: 15,
                    styles: [that.getClusterIcon(_id)],
                    zoomOnClick: false
                });
                
                YUI.geowidget.Model.clusterers[_id] = markerClusterer;
                
                google.maps.Event.addListener(markerClusterer, "clusterclick", function(cluster){
                    var markers = cluster.getRealMarkers();
                    var locations = Y.Array.map(markers, function(marker){
                        return marker._location;
                    });
                    YUI.geowidget.Model.selectedClusterLocations = locations;
                    var infowindow = that.infoWindowFactory.createSummaryInfoWindow(that.map, locations, function(location){
                        YUI.geowidget.Model.setLocation(location);
                    });
                    that.map.openInfoWindow(cluster.getCenter(), infowindow);
                });
            });
        }
    };
    
    YUI.geowidget.MarkerFactory.prototype.createEdges = function(location, locations){
        var that = this;
        var layoutEdges = YUI.geowidget.Model.config.layout.edges ||
        {};
        if (Y.Lang.isArray(location.edges)) {
            var srcLocationNumber = Y.Array.indexOf(locations, location);
            var polylines = [];
            Y.Array.each(location.edges, function(destLocationNumber){
                if (destLocationNumber > srcLocationNumber) {
                    // only draw edges with a greater index
                    // that way the undirected edges are only drawn once 
                    // (as each edge is stored twice, one for each connected node)
                    var destLocation = locations[destLocationNumber];
                    var polyline = new google.maps.Polyline([location.latLng, destLocation.latLng], layoutEdges.color || "#658DBA", layoutEdges.size || 4, layoutEdges.opacity || 0.5, {
                        geodesic: layoutEdges.geodesic || false
                    });
                    that.map.addOverlay(polyline);
                    polylines.push(polyline);
                }
            });
            // TODO: show/hide also incoming edges
            location.showEdges = function(){
                Y.Array.each(polylines, function(polyline){
                    polyline.show();
                });
            };
            location.hideEdges = function(){
                Y.Array.each(polylines, function(polyline){
                    polyline.hide();
                });
            };
        }
    };
    
    YUI.geowidget.MarkerFactory.prototype.createKMLs = function(kmls){
		var that = this;
        if (kmls) {
            Y.Array.each(kmls, function(kml){
                var url = Y.substitute(kml.url, {
                    //root: 'http://test.geowidget.de/geowidget-js/' + YUI.geowidget.Model.root
					root:	location.protocol + '//' + location.host + '/geowidget-js/' + YUI.geowidget.Model.root
                });
                kml.marker = new google.maps.GeoXml(url, function(){
                    if (kml.marker.loadedCorrectly()) {
                        // kml.marker.gotoDefaultViewport(that.map);
                    }
                    else {
                        // TODO log this error
                        alert('could not load kml: ' + url);
                    }
                });
                that.map.addOverlay(kml.marker);
            });
        }
    };
    
}, '0.0.1', {
    requires: ['collection']
});
