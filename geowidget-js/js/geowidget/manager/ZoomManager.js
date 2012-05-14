/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.manager.ZoomManager', function(Y){

    YUI.namespace("geowidget.manager");
    
    YUI.geowidget.manager.ZoomManager = function(map){
        var that = this;
        this.map = map;
        this.GERMANY = {
            zoom: 6,
            latLng: new google.maps.LatLng(51.220647, 10.041504)
        };
        this.EUROPE = {
            zoom: 5,
            latLng: new google.maps.LatLng(48.886483489234266, 2.342630624771118)
        };
        google.maps.Event.addListener(this.map, "zoomend", function(oldLevel, newLevel){
            if (Y.Lang.isFunction(that.zoomFunction)) {
                that.zoomFunction();
            }
            // zoom range for locations
            var updateZoomRange = function(geoItems){
                if (geoItems) {
                    Y.Array.each(geoItems, function(location){
                        if (Y.Lang.isArray(location.zoomRange)) {
                            // zoom range is defined, show location only if it is in range, otherwise hide it
                            var min = location.zoomRange[0];
                            var max = location.zoomRange[1];
                            if (newLevel >= min && newLevel <= max) {
                                location.marker.show();
                                if (Y.Lang.isFunction(location.showEdges)) {
                                    location.showEdges();
                                }
                            }
                            else {
                                location.marker.hide();
                                if (Y.Lang.isFunction(location.hideEdges)) {
                                    location.hideEdges();
                                }
                            }
                        }
                    });
                }
            };
            
            // update zoom range for kmls & locations
            updateZoomRange(YUI.geowidget.Model.config.locations);
            updateZoomRange(YUI.geowidget.Model.config.kmls);
        });
    };
    
    YUI.geowidget.manager.ZoomManager.prototype.zoomToBounds = function(bounds){
        var zoomLevel = this.map.getBoundsZoomLevel(bounds);
        if (zoomLevel > 15) {
            zoomLevel = 15;
        }
        this.map.setCenter(bounds.getCenter(), zoomLevel);
    };
    
    YUI.geowidget.manager.ZoomManager.prototype.zoomToLocations = function(){
        this.map.closeInfoWindow();
        this.zoomToBounds(YUI.geowidget.util.GeoUtil.createLocationBounds(YUI.geowidget.Model.config.locations));
        this.allLocationsVisibleZoom = this.map.getZoom();
    };
    
    YUI.geowidget.manager.ZoomManager.prototype.zoomToOverview = function(){
        if (YUI.geowidget.Model.config.layout.overview) {
			var overview = YUI.geowidget.Model.config.layout.overview;
            this.map.closeInfoWindow();
            this.map.setCenter(new google.maps.LatLng(overview.lat, overview.lng), overview.zoom);
        }
        else {
            this.zoomToLocations();
        }
    };
    
    YUI.geowidget.manager.ZoomManager.prototype.zoomToCluster = function(){
        this.map.closeInfoWindow();
        this.zoomToBounds(YUI.geowidget.util.GeoUtil.createLocationBounds(YUI.geowidget.Model.selectedClusterLocations));
        this.allLocationsVisibleZoom = this.map.getZoom();
    };
    
    YUI.geowidget.manager.ZoomManager.prototype.isZoomedIn = function(){
        return this.map.getZoom() > this.allLocationsVisibleZoom;
    };
    
    YUI.geowidget.manager.ZoomManager.prototype.zoomToCountry = function(country){
        this.map.closeInfoWindow();
        this.map.setCenter(country.latLng);
        this.map.setZoom(country.zoom);
    };
    
    YUI.geowidget.manager.ZoomManager.prototype.zoomIn = function(levels){
        this.map.closeInfoWindow();
        for (var i = 0; i < levels; i++) {
            this.map.zoomIn();
        }
    };
    
}, '0.0.1', {
    requires: ['geowidget.util.GeoUtil']
});

