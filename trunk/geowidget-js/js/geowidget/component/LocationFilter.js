/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.component.LocationFilter', function(Y){
    YUI.namespace("geowidget.component");
    
    YUI.geowidget.component.LocationFilter = function(placeholder, isFeature, locations){
        var that = this;
        
        if (YUI.geowidget.component.LocationFilter.superclass.constructor.call(that, placeholder, isFeature)) {
            that.groups = {};
            that.isGroupVisible = {};
            
            // order markers per icon in a group
            for (var i = 0; i < locations.length; i++) {
                var icon = locations[i].icon || undefined;
                if (!that.groups[icon]) {
                    that.groups[icon] = [];
                }
                that.groups[icon].push(locations[i].marker);
            }
            
            var ul = Y.Node.create('<ul></ul>');
            that.placeholder.appendChild(ul);
            
            // for each group build a checkbox
            Y.Array.each(YUI.geowidget.Model.config.icons, function(icon){
				var id = icon.id;
				var overlays = that.groups[id];
				if (overlays) {
					var li = Y.Node.create('<li><label for="' + id + '"><input type="checkbox" id="' + id + '" name="' + id + '" checked="true" /><img src="' + that.getIcon(id) + '" alt="" height="15" /> ' + id + ' anzeigen</label></li>');
					ul.appendChild(li);
					that.isGroupVisible[id] = true;
					
					li.query('input').on('click', function(){
						var checkbox = this;
						var checked = checkbox.get('checked');
						that.isGroupVisible[id] = checked;
						
						icon.visible = checked;
						that.updateModel();
						
						// update view - TODO: right now works only with clusterer                    
						Y.Object.each(YUI.geowidget.Model.clusterers, function(clusterer, id){
							for (var i = 0; i < overlays.length; i++) {
								if (checked) {
									clusterer.showMarker(overlays[i], true);
								}
								else {
									clusterer.hideMarker(overlays[i], true);
								}
							}
							clusterer.redraw_();
						});
						
					});
				}
				
				icon.visible = true; 
            });
            
            var maxWidth = 0;
            ul.all('li').each(function(li){
                maxWidth = Math.max(maxWidth, li.get('offsetWidth') || 0);
            });
            ul.all('li').each(function(li){
                li.setStyle('width', maxWidth + 'px');
            });
			
			that.updateModel();
        }
    };
    
    Y.extend(YUI.geowidget.component.LocationFilter, YUI.geowidget.component.GWComponent);
    // TODO: here -> template for this component could be placed in global storage like YUI.geowidget.Model.config.templates for loading in ConfigLoader
    
    YUI.geowidget.component.LocationFilter.prototype.getIcon = function(id){
        if (id == 'undefined') {
            return 'assets/logo/logo.png';
        }
        else {
            return YUI.geowidget.Model.root + '/' + this.lookupIcon(id).image;
        }
    };
    
    YUI.geowidget.component.LocationFilter.prototype.lookupIcon = function(id){
        return Y.Array.find(YUI.geowidget.Model.config.icons, function(icon){
            return icon.id == id;
        });
    };
    
    YUI.geowidget.component.LocationFilter.prototype.updateModel = function(){
        var that = this;
        var visibleLocations = [];
		var hiddenLocations = [];
        // update model
        Y.Object.each(that.groups, function(overlays, id){
            if (that.isGroupVisible[id]) {
                Y.Array.each(overlays, function(overlay){
                    visibleLocations.push(overlay._location);
                });
            }
			else {
				Y.Array.each(overlays, function(overlay){
                    hiddenLocations.push(overlay._location);
                });
			}
        });
		YUI.geowidget.Model.set('visibleLocations', visibleLocations);
		YUI.geowidget.Model.set('hiddenLocations', hiddenLocations);
    };
}, '0.0.1', {
    requires: ['geowidget.component.GWComponent', 'node']
});
