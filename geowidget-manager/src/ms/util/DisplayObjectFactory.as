/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package ms.util
{
	import flash.display.DisplayObject;
	import flash.events.TextEvent;
	import flash.events.Event;
	import mx.controls.TextArea;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.text.StyleSheet;
	import flash.utils.getDefinitionByName;
	import mx.containers.TitleWindow;
	
	public class DisplayObjectFactory
	{
		public static function createTextArea(url:String, styleName:String = "content", castShadow:Boolean = true):TextArea {
    			var text:TextArea = new TextArea();
    			if(castShadow) {
        			var filter:DropShadowFilter = new DropShadowFilter(1,90,0,0.3);
        			text.filters = [filter];
    			}
    			
    			text.editable = false;
    			text.styleName = styleName;
    			text.percentWidth = 100;
    			text.percentHeight = 100;

               	var request:URLRequest = new URLRequest(url);
				var loader:URLLoader = new URLLoader();
        		loader.addEventListener(Event.COMPLETE, function(event:Event):void {
        			text.htmlText = event.target.data;
					var ss:StyleSheet = new StyleSheet();
					ss.setStyle("a:hover", {textDecoration: "underline"});
					text.styleSheet = ss;	           
        		});
	            try
	            {
	                loader.load(request);
	            }
	            catch (error:Error)
	            {
	                trace("error loading page: " + error);
	            }
				return text;				            
		}
		
		public static function createObject(className:String):DisplayObject {
        	var c:Class = Class(flash.utils.getDefinitionByName(className));
        	return new c();
		}
		
		public static function createDisplayObject(className:String, url:String, styleName:String = "content", castShadow:Boolean = true):DisplayObject {
        	if(className == null) {
        		if(url!=null) {
        			return createTextArea(url, styleName, castShadow);
	            } else
	            	return null;
            } else {
            	return createObject(className);
            }
		}
	}
}