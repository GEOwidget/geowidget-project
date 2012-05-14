/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.ConfigLoader', function(Y){

    YUI.namespace("geowidget");
    
    YUI.geowidget.ConfigLoader = function(){
        var that = {};
        that.loadConfig = function(callback){
            YUI.geowidget.Model.root = YUI.geowidget.root || YUI.ms.URLParser.parse('root');
            if (YUI.geowidget.Model.root === '') {
                YUI.geowidget.Model.root = '.';
            }
            var fileName = YUI.geowidget.Model.root + '/config.json';
            Y.io(fileName, {
                on: {
                    success: function(id, o, args){
                        // Process the JSON data returned from the server
                        config = [];
                        try {
                            config = Y.JSON.parse(o.responseText);
                        } 
                        catch (e) {
                            alert('Error parsing JSON: ' + e.description);
                            return;
                        }
						
                        var postLocation = function(){
                            config.locations.every = function(singleCallback){
                                Y.Array.each(config.locations, singleCallback);
                            };
                            config.locations.every(function(location){
								// update location object - inject additional functions and properties
                                location.latLng = new google.maps.LatLng(location.lat, location.lng);
                                if (location.address === undefined) {
                                    location.address = (location.street !== undefined ? location.street + ", " : '') +
                                    (location.postalCode !== undefined ? location.postalCode + " " : '') +
                                    location.city;
                                }
								location.hasInfoWindow = function() {
									return Y.Lang.isArray(location.templates) && location.templates.length > 0;
								};
                            });
                            YUI.geowidget.Model.config = config;
                            callback(config);
                        };
						
						// correct path to positionIcon
						if(config.positionIcon) {
							config.positionIcon.image		= YUI.geowidget.Model.root + '/' + config.positionIcon.image;
							config.positionIcon.overImage	= YUI.geowidget.Model.root + '/' + config.positionIcon.overImage;
						}
						
                        if (Y.Lang.isString(config.locations)) {
                            var locationsDS = new Y.DataSource.Get({
                                source: config.locations
                            });
                            locationsDS.sendRequest('?a=1', {
                                success: function(result){
                                    config.locations = result.data;
                                    postLocation();
                                }
                            });
                        }
                        else {
                            postLocation();
                        }
                    }
                }
            });
        };
        that.preloadTemplates = function(callback){
            var locations = YUI.geowidget.Model.config.locations;
			YUI.geowidget.Model.config.templates = YUI.geowidget.Model.config.templates || {};
            var templates = YUI.geowidget.Model.config.templates;
            YUI.geowidget.Model.config.locale = YUI.geowidget.Model.config.locale || 'de_DE'; 
            var templatePath = 'templates/' + YUI.geowidget.Model.config.locale + '/';
            // set global templates
            templates.route = templates.route || templatePath + 'route.html';
            templates.directions = templates.directions || templatePath + 'directions.html';
            templates.directionsItem = templates.directionsItem || templatePath + 'directionsItem.html';
            templates.body = templates.body || templatePath + 'body.html';
            templates.locationSelector = templates.locationSelector || templatePath + 'locationSelector.html';
            templates.locationSummaryItem = templates.locationSummaryItem || templatePath + 'locationSummaryItem.html';
            templates.locationSummary = templates.locationSummary || templatePath + 'locationSummary.html';
            templates.locationListItem = templates.locationListItem || templatePath + 'locationListItem.html';
			templates.locationListHiddenItem = templates.locationListHiddenItem || templatePath + 'locationListHiddenItem.html';
            var templateNames = Y.Object.values(templates);
            
            // add local templates
            Y.Array.each(locations, function(location){
                templateNames = templateNames.concat(location.templates || []);
            });
            // eliminate doubles
            templateNames = Y.Array.unique(templateNames);
            // load templates
            YUI.ms.TemplateLoader.loadTemplates(templateNames, callback);
        };
        that.getMapType = function(){
            switch (YUI.geowidget.Model.config.layout.mapType) {
                case 'NORMAL_MAP_TYPE':
                    return G_NORMAL_MAP;
                case 'SATELLITE_MAP_TYPE':
                    return G_SATELLITE_MAP;
                case 'HYBRID_MAP_TYPE':
                    return G_HYBRID_MAP;
                case 'SATELLITE_3D_MAP_TYPE':
                    return G_SATELLITE_3D_MAP;
				case 'OSM_MAP_TYPE':
					var osmlicense = "<a href='http://www.openstreetmap.com' target='_blank'>License</a>";
					var osmcopyright = new google.maps.Copyright(1, new google.maps.LatLngBounds(new google.maps.LatLng(-90, -180), new google.maps.LatLng(90, 180)), 0, osmlicense);
					var osmcopyrightCollection = new google.maps.CopyrightCollection("OpenStreetsMap: ");
					osmcopyrightCollection.addCopyright(osmcopyright);
					var osm = [new google.maps.TileLayer(osmcopyrightCollection, 0, 15)];
					osm[0].getTileUrl = function(a,b) {
					  return "http://tile.openstreetmap.org/" + b + "/" + a.x + "/" + a.y + ".png"; };
					return new google.maps.MapType(osm, G_SATELLITE_MAP.getProjection(), "OpenStreetMap", {minResolution:0, maxResolution:15});				
                default:
                    return G_PHYSICAL_MAP;
            }
        };
        return that;
    }();
}, '0.0.1', {
    requires: ['io', 'json-parse', 'collection', 'ms.TemplateLoader', 'datasource-get']
});
