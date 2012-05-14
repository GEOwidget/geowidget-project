/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.manager.LayoutManager', function(Y){

    YUI.namespace("geowidget.manager");
    
    YUI.geowidget.manager.LayoutManager = function(){
		var that = {};
		
		that.unblock = function() {
			Y.one('#gw-layout-block').remove();
		};
		
		that.arrange = function(map) {
			var top		= Y.Node.get('.gw-layout-top');
			var left	= Y.Node.get('.gw-layout-left');
			var main	= Y.Node.get('.gw-layout-main');
			var right	= Y.Node.get('.gw-layout-right');
			var bottom	= Y.Node.get('.gw-layout-bottom');
			
			// TODO: Check if any block except main is empty (they have no controls)
			// Empty blocks should be removed here
	
			var h1	= (top)?(top.get('offsetHeight')):(0);
			var h2	= (bottom)?(bottom.get('offsetHeight')):(0);
			
			var w1 = (left)?(left.get('offsetWidth')):(0);
			var w2 = (right)?(right.get('offsetWidth')):(0);
			
			that.setStyle(top,		0, 0, null, 0);
			that.setStyle(left,		h1, null, h2, 0);
			that.setStyle(main,		h1, w2, h2, w1);
			that.setStyle(right,	h1, 0, h2, null);
			that.setStyle(bottom,	null, 0, 0, 0);
			
			map.checkResize();
		};
		
		that.setStyle = function(node, top, right, bottom, left) {
			if(node) {
				if(top !== null)		node.setStyle('top', top + 'px');
				if(right !== null)	node.setStyle('right', right + 'px');
				if(bottom !== null)	node.setStyle('bottom', bottom + 'px');
				if(left !== null)	node.setStyle('left', left + 'px');
				
				// FIXME: Needs only for IE!
				if(Y.UA.ie > 0 && top !== null && bottom !== null) {
					node.setAttribute('dh', (top + bottom));
				}
				
				if(Y.UA.ie > 0 && left !== null && right !== null) {
					node.setAttribute('dw', (left + right));
				}
			}
		};
		
		return that;
    }();
    
}, '0.0.1', {
    requires: ['node']
});