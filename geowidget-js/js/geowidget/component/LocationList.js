/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.component.LocationList', function(Y){
    YUI.namespace("geowidget.component");
    
    YUI.geowidget.component.LocationList = function(placeholder, isFeature, map){
        var that = this;
        
        if (YUI.geowidget.component.LocationList.superclass.constructor.call(that, placeholder, isFeature)) {
            that.map = map;
            
            YUI.geowidget.Model.after('hiddenLocationsChange', function(){
                that.update();
            });
            YUI.geowidget.Model.after('selectedLocationChange', function(){
                that.onItemSelect(YUI.geowidget.Model.get('selectedLocation'));
            });
            
            that.update();
            that.placeholder.setStyle('display', 'block');
        }
    };
    
    Y.extend(YUI.geowidget.component.LocationList, YUI.geowidget.component.GWComponent);
    // TODO: here -> template for this component could be placed in global storage like YUI.geowidget.Model.config.templates for loading in ConfigLoader
    
    YUI.geowidget.component.LocationList.prototype.update = function(){
        var that = this;
        var list = Y.Node.create('<ol></ol>');
        
        if (that.placeholder.query('ol')) {
            that.placeholder.removeChild(that.placeholder.query('ol'));
        }
        that.placeholder.appendChild(list);
        
		var visibleLocation = YUI.geowidget.Model.get('visibleLocations');
		var locations = YUI.geowidget.Model.config.locations;
        locations = locations.sort(function(a, b){
            return (a.city > b.city) ? 1 : -1;
        });
        
        Y.Array.each(locations, function(location){
			var visible = (Y.Array.indexOf(visibleLocation, location) >= 0);
			
			var itemTemplate = (visible)?
								YUI.geowidget.Model.config.templates.locationListItem:
								YUI.geowidget.Model.config.templates.locationListHiddenItem;
			
			var li = Y.Node.create(YUI.ms.TemplateLoader.applyTemplate(itemTemplate, location).html);
			list.appendChild(li);
			location.li = li;
			
			if (visible) {
				li.query('a').on('click', function(){
					YUI.geowidget.Model.setLocation(location);
				});
			}
        });
        that.onItemSelect(YUI.geowidget.Model.get('selectedLocation'));
    };
    
    YUI.geowidget.component.LocationList.prototype.deselectAll = function(){
        this.placeholder.queryAll('li').removeClass('selected');
    };
    
    YUI.geowidget.component.LocationList.prototype.onItemSelect = function(location){
        // First of all - deselect all
        this.deselectAll();
        
        if (location && location.li) {
            location.li.addClass('selected');
			if(!YUI.ms.NodeHelper.isInParentView(location.li)) {
                location.li.scrollIntoView();
            }
        }
    };

}, '0.0.2', {
    requires: ['geowidget.component.GWComponent', 'node', 'ms.NodeHelper']
});


