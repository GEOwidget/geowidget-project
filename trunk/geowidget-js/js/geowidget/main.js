/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI({
    modules: {
        'yui2-yde': {
            fullpath: "http://yui.yahooapis.com/2.7.0/build/yahoo-dom-event/yahoo-dom-event.js"
        },
        'yui2-datasource': {
            fullpath: "http://yui.yahooapis.com/2.7.0/build/datasource/datasource-min.js"
        },
        'yui2-autocomplete': {
            fullpath: "http://yui.yahooapis.com/2.7.0/build/autocomplete/autocomplete-min.js",
            requires: ['yui2-yde', 'yui2-fonts', 'yui2-autocompletecss', 'yui2-datasource']
        },
        'yui2-fonts': {
            fullpath: "http://yui.yahooapis.com/2.7.0/build/fonts/fonts-min.css",
            type: 'css'
        },
        'yui2-autocompletecss': {
            fullpath: "http://yui.yahooapis.com/2.7.0/build/autocomplete/assets/skins/sam/autocomplete.css",
            type: 'css'
        }
    }
}).use('geowidget.manager.ClusterManager', 'geowidget.Model', 'node', 'substitute', 'geowidget.ConfigLoader', 'geowidget.InfoWindowFactory', 'geowidget.component.LocationSelector', 'geowidget.component.LocationList', 'geowidget.component.LocationFilter', 'geowidget.MarkerFactory', 'geowidget.manager.ZoomManager', 'geowidget.manager.DirectionsManager', 'geowidget.manager.LayoutManager', 'geowidget.component.ZoomOutButton', 'geowidget.I18N', function(Y){
	YUI.geowidget.ConfigLoader.loadConfig(function(config){
		var urlMapper = function(url){
                return Y.substitute(url, {
                    root: YUI.geowidget.Model.root
                });
        };
        YUI.ms.TemplateLoader = YUI.ms.TemplateLoader({
            // map root to template names ({root} is substituted with root of actual configuration)
            urlMapper: urlMapper
        });
        YUI.geowidget.ConfigLoader.preloadTemplates(function(){
            var template = YUI.geowidget.Model.config.templates.body;
            //document.body.innerHTML = YUI.ms.TemplateLoader.getTemplate(template);
			Y.one('#gw-layout').set('innerHTML', YUI.ms.TemplateLoader.getTemplate(template));
			
			var is_ui_ready		= false;
			var is_map_ready	= false;
			var is_locked		= true;

			var map = new google.maps.Map2(document.getElementById("map_canvas"));
            map.enableContinuousZoom();
            map.enableScrollWheelZoom();
            map.setMapType(YUI.geowidget.ConfigLoader.getMapType());
            if (config.features.showMapTypes) {
				map.addMapType(G_PHYSICAL_MAP);
                map.addControl(new google.maps.MapTypeControl());
            }
            if (config.features.showZoom) {
                map.addControl(new google.maps.LargeMapControl3D());
            }
            if (config.features.showOverview) {
                map.addControl(new google.maps.OverviewMapControl());
            }
			
			// Use "load" if shouldn't wait for all maps element
			// Use "tilesloaded" if should wait for all maps element
			google.maps.Event.addListener(map, (Y.UA.ie > 0)?"load":"tilesloaded", function(){
				// Unlock widget if UI is ready. 
				is_map_ready = true;
				if(is_ui_ready && is_map_ready && is_locked) {
					YUI.geowidget.manager.LayoutManager.unblock();
					is_locked = false;
				}
			});
            
            YUI.geowidget.Model.managers = {};
            YUI.geowidget.Model.managers.directionsManager = new YUI.geowidget.manager.DirectionsManager(map);
            YUI.geowidget.Model.managers.zoomManager = new YUI.geowidget.manager.ZoomManager(map);
            YUI.geowidget.Model.managers.clusterManager = new YUI.geowidget.manager.ClusterManager(map);
            var managers = YUI.geowidget.Model.managers;
            var markerFactory = new YUI.geowidget.MarkerFactory(map, YUI.geowidget.InfoWindowFactory, managers.zoomManager);
            
            markerFactory.createMarkers(config.locations);
			markerFactory.createKMLs(config.kmls);
            
            if (config.features.showSearch) {
                var locationSelector = new YUI.geowidget.component.LocationSelector("search_form", config.infoText || "Please enter your location");
                locationSelector.on('enter', function(){
                    YUI.geowidget.util.GeoUtil.getNearestLocation(locationSelector.getValue(), function(placemark, nearestLocation){
	                    YUI.geowidget.Model.selectedPosition = placemark;
                        managers.directionsManager.calcRoute(placemark, nearestLocation);
                    });
                });
            }
            else {
                Y.Node.get('#search_form').remove();
            }
            
            // zoom out button is not layouted by layout manager, therefore has now mark up in body template
            //var zoomOutButton = new YUI.geowidget.component.ZoomOutButton(".gw-layout-main", managers.zoomManager, map);
            
            var locationList = new YUI.geowidget.component.LocationList("#location_list", config.features.showLocationList, map);
            var locationFilter = new YUI.geowidget.component.LocationFilter("#location_filter", config.features.showLocationFilter, config.locations);
            
            YUI.geowidget.manager.LayoutManager.arrange(map);
            
            managers.zoomManager.zoomToOverview();
			
            if (config.features.showWelcomeText) {
                map.openInfoWindowHtml(map.getCenter(), config.features.welcomeText);
            }
            if (config.features.showWelcomeLocation) {
	           YUI.geowidget.Model.setLocation(config.locations[config.features.welcomeLocation]);
            }
			
			// Unlock widget if map is loaded. 
			is_ui_ready = true;
			if(is_ui_ready && is_map_ready && is_locked) {
				YUI.geowidget.manager.LayoutManager.unblock();
				is_locked = false;
			}
        });
    });
});
