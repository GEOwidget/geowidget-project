/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.util.GeoUtil', function(Y){
    YUI.namespace("geowidget.util");
    
    YUI.geowidget.util.GeoUtil = function(){
        var that = {};
        
        that.findNearestLocation = function(latLng, locations){
            var minDistance = Number.MAX_VALUE;
            var nearestLocation;
            for (var i = 0; i < locations.length; i++) {
                var location = locations[i];
                var distance = latLng.distanceFrom(location.latLng);
                if (distance < minDistance) {
                    nearestLocation = location;
                    minDistance = distance;
                }
            }
            return nearestLocation;
        };
        
        that.getNearestLocation = function(location, callback){
            that.retrievePlacemark(location, function(placemark){
                var nearestLocation = that.findNearestLocation(placemark.latLng, YUI.geowidget.Model.get('visibleLocations'));
                callback(placemark, nearestLocation);
            });
        };
        
        that.createLocationBounds = function(locations){
            var bounds = new google.maps.LatLngBounds();
            for (var i = 0; i < locations.length; i++) {
                var location = locations[i];
                bounds.extend(location.latLng);
            }
            return bounds;
        };
        
        that.createCenterBorderBound = function(center, border){
            var oppositeCorner = new google.maps.LatLng(border.lat() + (center.lat() - border.lat()) * 2, border.lng() + (center.lng() - border.lng()) * 2);
            var bounds = new google.maps.LatLngBounds();
            bounds.extend(border);
            bounds.extend(oppositeCorner);
            return bounds;
        };
        
        that.retrievePlacemark = function(address, callback){
            var geocoder = new google.maps.ClientGeocoder();
            var convertPlaceMark = function(placemark){
                return {
                    latLng: new google.maps.LatLng(placemark.Point.coordinates[1], placemark.Point.coordinates[0]),
                    address: placemark.address
                };
            };
            geocoder.setBaseCountryCode('de');
            geocoder.getLocations(address, function(response){
                if (response.Status.code === G_GEO_SUCCESS) {
                    var placemarks = response.Placemark;
                    if (placemarks.length == 1) {
                        var placemark = placemarks[0];
                        callback(convertPlaceMark(placemark));
                    }
                    else 
                        if (placemarks.length > 1) {
                            YUI.ms.ItemSelector.setHeader(YUI.geowidget.I18N.getText('geoUtil.multiplePlaces'));
                            YUI.ms.ItemSelector.selectItem(placemarks, function(placemark){
                                callback(convertPlaceMark(placemark));
                            }, function(placemark){
                                return placemark.address;
                            });
                        }
                        else {
                            alert(YUI.geowidget.I18N.getText('geoUtil.noAddress'));
                        }
                } else {
					alert(YUI.geowidget.I18N.getText('geoUtil.error') + " " + response.Status.code + ". " + YUI.geowidget.I18N.getText('geoUtil.tryAgain'));
				}
            });
        };
        
        return that;
    }();
}, '0.0.1', {
    requires: ['io', 'json-parse', 'ms.ItemSelector']
});
