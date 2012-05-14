/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('ms.ItemSelector', function(Y){
    YUI.namespace("ms");
    
    YUI.ms.ItemSelector = function(){
        var that = {};
        
        var headerContent = "Please select an item";
        
        that.setHeader = function(header){
            headerContent = header;
        };
		that.hide = function() {
			if (that.overlay !== undefined) {
				that.overlay.hide();
				that.overlay.destroy();
				delete that.overlay;
			}
		};
        that.selectItem = function(items, callback, labelFn){
			that.hide();
            var headerContainer = Y.Node.create('<div class="item-selector-header"></div>');
            var closeButton = Y.Node.create('<a href="#" class="item-selector-close"></a>');
            closeButton.on('click', function(e){
            	that.hide();
            });
			headerContainer.appendChild(closeButton);
            var headerText = Y.Node.create('<span></span>');
			headerContainer.appendChild(headerText);
			headerText.setContent(headerContent);
            var container = Y.Node.create('<div class="item-selector"></div>');
            that.overlay = new Y.Overlay({
                headerContent: headerContainer,
                bodyContent: container,
				zIndex: 9999
            });
            that.overlay.set("centered", true);
            var list = Y.Node.create('<ol></ol>');
            container.appendChild(list);
            Y.Array.each(items, function(item){
                var itemNode = Y.Node.create('<li><a href="#">' + labelFn(item) + '</a></li>');
                list.appendChild(itemNode);
                itemNode.on('click', function(e){
					that.hide();
                    callback(item);
                });
            });
            that.overlay.render();
        };
        return that;
    }();
}, '0.0.1', {
    requires: ['node', 'overlay']
});
