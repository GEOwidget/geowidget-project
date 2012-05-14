/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.component.LocationSelector', function(Y){
    YUI.namespace("geowidget.component");
    
    YUI.geowidget.component.LocationSelector = function(placeholder, infoText){
        var that = this;
        
        var placeholderNode = Y.Node.get('#' + placeholder);
        var template = YUI.geowidget.Model.config.templates.locationSelector;
        var content = YUI.ms.TemplateLoader.getTemplate(template);
        placeholderNode.appendChild(Y.Node.create(content));
        
        var inputFieldNode = placeholderNode.query('.gw-search-input input');
        var suggestionContainerNode = placeholderNode.query('.gw-search-input .gw-search-suggestion');
        var submitButtonNode = placeholderNode.query('.gw-search-submit input');
        
        var inputField = Y.guid('myInputField');
        var suggestionContainer = Y.guid('mySuggestionContainer');
        var submitButton = Y.guid('mySubmitButton');
        
        inputFieldNode.set('id', inputField);
        suggestionContainerNode.set('id', suggestionContainer);
        submitButtonNode.set('id', submitButton);
        
        var cities = [];
        
        YUI.ms.Behaviours.setInfoText(inputField, infoText);
        
        var oDS = new YAHOO.util.LocalDataSource(cities);
        // Optional to define fields for single-dimensional array 
        oDS.responseSchema = {
            fields: ["state"]
        };
        
        YUI.geowidget.component.LocationSelector.superclass.constructor.call(that, inputField, suggestionContainer, oDS, {
            allowBrowserAutocomplete: false,
			useShadow: true
        });
        
        that.inputFieldNode = inputFieldNode;
        
        that.publish('enter');
        
        inputFieldNode.on('keyup', function(event){
            if (event.keyCode == 13) {
                that.fire('enter');
            }
        });
        
        submitButtonNode.on('click', function(){
            that.fire('enter');
        });
        
        Y.io('assets/cities.json', {
            on: {
                success: function(id, xhr){
                    var remoteCities = Y.JSON.parse(xhr.responseText);
                    Y.Array.each(remoteCities, function(city){
                        cities.push(city);
                    });
                }
            }
        });
        
        /*    YUI.geowidget.util.GeoNames.search({
         'country': ['DE'],
         'maxRows': 1000,
         'lang': 'de'
         }, function(json){
         if (json.geonames) {
         for (var i = 0; i < json.geonames.length; i++) {
         cities.push(json.geonames[i].name);
         }
         console.log(cities);
         }
         
         }); */
    };
    
    Y.extend(YUI.geowidget.component.LocationSelector, YAHOO.widget.AutoComplete);
    Y.augment(YUI.geowidget.component.LocationSelector, Y.EventTarget);
    
    YUI.geowidget.component.LocationSelector.prototype.getValue = function(){
        return this.inputFieldNode.get('value');
    };
}, '0.0.1', {
    requires: ['node', 'ms.Behaviours', 'event', 'geowidget.util.GeoNames', 'io', 'json-parse', 'yui2-autocomplete']
});


