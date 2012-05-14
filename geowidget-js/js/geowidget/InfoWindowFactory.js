/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.InfoWindowFactory', function(Y){

    YUI.namespace("geowidget");
    
    YUI.geowidget.InfoWindowFactory = function(){
        var that = {};
        
        that.createInfoWindows = function(location){
            var infowindows = [];
            var templates = location.templates || [];
            Y.Array.each(templates, function(template){
                var content = YUI.ms.TemplateLoader.applyTemplate(template, location);
                infowindows.push(content);
            });
			
            if (YUI.geowidget.Model.config.features.showRoute === true) {
				infowindows.push(YUI.geowidget.Model.managers.directionsManager.createInfoWindow(location));
			}	
				
            return infowindows;
        };
        
        that.displayLocationInfoWindow = function(map, location, config){
            config = config ||
            {};
            var infowindows = YUI.geowidget.InfoWindowFactory.createInfoWindows(location);
            that.displayInfoWindow(map, location.marker.getLatLng(), infowindows, {
                onOpenFn: function(){
					YUI.geowidget.Model.managers.clusterManager.highlightMarker(location.marker);
                },
                onCloseFn: function(){
					if (YUI.geowidget.Model.get('selectedLocation') === location) {
						YUI.geowidget.Model.set('selectedLocation', null);
					}
					YUI.geowidget.Model.managers.clusterManager.unhighlightMarker();
                },
                startTab: (config.showRouteTab) ? (infowindows.length - 1) : 0
            });
        };
        
        that.displayInfoWindow = function(map, latLng, infowindows, config){
            config = config ||
            {};
            var defaultWidth;
            var defaultHeight;
            var selectTab = function(tab){
                if (!defaultWidth && !defaultHeight) {
                    defaultWidth = map.getInfoWindow().getContentContainers()[0].clientWidth;
                    defaultHeight = map.getInfoWindow().getContentContainers()[0].clientHeight;
                }
                var container = Y.get(map.getInfoWindow().getContentContainers()[tab]);
                var contentWidth = container.query('.infowindow').getStyle('width').match(/(\d+)px/);
                var width;
                if (contentWidth) {
                    width = parseInt(contentWidth[1], 10);
                }
                else {
                    width = defaultWidth;
                }
                map.getInfoWindow().reset(latLng, map.getInfoWindow().getTabs(), new GSize(width, defaultHeight), null, null);
                map.getInfoWindow().selectTab(tab);
            };
            
            var options = function(multiple){
                return {
                    onOpenFn: function(){
                        if (multiple) {
							selectTab(config.startTab || 0);
						}
                        Y.Array.each(infowindows, function(infowindow){
                            eval(infowindow.js);
                        });
                        if (Y.Lang.isFunction(config.onOpenFn)) {
                            config.onOpenFn();
                        }
                    },
                    onCloseFn: config.onCloseFn
                };
            };
            if (infowindows.length === 1) {
                map.openInfoWindowHtml(latLng, infowindows[0].html, options(false));
            }
            else {
                var counter = 0;
                var mappedWindows = Y.Array.map(infowindows, function(content){
                    var infowindow = new google.maps.InfoWindowTab(content.title, content.html);
                    var localCounter = counter;
                    infowindow.onclick = function(){
                        selectTab(localCounter);
                    };
                    counter++;
                    return infowindow;
                });
                map.openInfoWindowTabsHtml(latLng, mappedWindows, options(true));
            }
        };
        
        that.createSummaryInfoWindow = function(map, locations, callback){
            var itemTemplate = YUI.geowidget.Model.config.templates.locationSummaryItem;
            var template = YUI.geowidget.Model.config.templates.locationSummary;
            var infoWindow = Y.Node.create(YUI.ms.TemplateLoader.getTemplate(template));
            var itemList = infoWindow.query('.section.list');
			var mapZoom = infoWindow.query('.section.zoom');
			
            Y.Array.each(locations, function(location){
                var item = Y.Node.create(YUI.ms.TemplateLoader.applyTemplate(itemTemplate, location).html);
                item.on('click', function(node){
                    callback(location);
                });
                item.on('mouseenter', function(e){
                    this.addClass("over");
                });
                item.on('mouseleave', function(e){
                    this.removeClass("over");
                });
                itemList.append(item);
            });
			
			var eventListener = google.maps.Event.addListener(map, "zoomend", function(oldLevel, newLevel){
				that.isAllowZoomIn(mapZoom, newLevel);
			});
			
			google.maps.Event.addListener(map, "infowindowclose", function(){
				google.maps.Event.removeListener(eventListener);
			});
			
			that.isAllowZoomIn(mapZoom, map.getZoom());
			
            return Y.Node.getDOMNode(infoWindow);
        };
		
		that.isAllowZoomIn = function(node, level) {
			if(node) {
				node.setStyle('visibility', (level < 15)?'visible':'hidden');
			}
		};
        
        return that;
    }();
}, '0.0.1', {
    requires: ['node', 'collection', 'ms.TemplateLoader']
});

