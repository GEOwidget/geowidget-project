/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('ms.NodeHelper', function(Y){
    YUI.namespace("ms");
    
    YUI.ms.NodeHelper = function(){
        var that = {};
        
        that.getHTML = function(node){
            if (!node) {
                throw "ms.NodeHelper.getHTML couldn't find node";
            }
            var tag = Y.Node.getDOMNode(node);
            if (tag.outerHTML) {
                return tag.outerHTML;
            }
            var wrapper = document.createElement("div");
            wrapper.appendChild(tag.cloneNode(true));
            return wrapper.innerHTML;
        };
        
        that.isInParentView = function(node){
            var offsetParent = node.get('offsetParent');
            var top = offsetParent.get('scrollTop');
            var height = offsetParent.get('offsetHeight');
            var y = node.get('offsetTop');
            return y >= top && y <= (top + height);
        };
        
        return that;
    }();
}, '0.0.1', {
    requires: ['node']
});
