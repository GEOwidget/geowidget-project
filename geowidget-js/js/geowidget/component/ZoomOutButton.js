/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.component.ZoomOutButton', function(Y){
    YUI.namespace("geowidget.component");
    
    YUI.geowidget.component.ZoomOutButton = function(parent, zoomManager, map){
        var that = this;
        
        that.zoomManager = zoomManager;
        that.map = map;
        
        var parentNode = Y.Node.get(parent);
        var button = Y.Node.create('<div class="gw-zoom-out-button"></div>');
        parentNode.appendChild(button);
        button.on('click', function(){
            that.zoomManager.zoomToLocations();
        });
        var checkVisibility = function(){
            button.setStyle('display', that.zoomManager.isZoomedIn() ? 'block' : 'none');
        };
        checkVisibility();
        google.maps.Event.addListener(that.map, "zoomend", function(oldLevel, newLevel){
            checkVisibility();
        });
    };
}, '0.0.1', {
    requires: ['geowidget.manager.ZoomManager', 'node']
});


