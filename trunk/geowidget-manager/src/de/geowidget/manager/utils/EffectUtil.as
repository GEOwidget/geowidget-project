/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.utils
{
	import com.google.maps.MapMouseEvent;
	import com.google.maps.overlays.Marker;
	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	public class EffectUtil
	{
		private static var ROLLOVER_WIDTH:int = 5;
		private static var ROLLOVER_HEIGTH:int = 5;

	    private static var rollOverFilter:GlowFilter = new GlowFilter(0xffffff, 1, ROLLOVER_WIDTH, ROLLOVER_HEIGTH, 10);

		public function EffectUtil()
		{
		}

		public static function applyRollOverFilter(icon:BitmapData):BitmapData {
			var overIcon:BitmapData = new BitmapData(icon.width, icon.height, true, 0x0);
			overIcon.applyFilter(icon, icon.rect, new Point(), EffectUtil.rollOverFilter);
			return overIcon;
		}
		
		public static function enlargeImage(icon:BitmapData, growX:int, growY:int):BitmapData {
			var biggerIcon:BitmapData = new BitmapData(icon.width+growX, icon.height+growY, true, 0x0);
			biggerIcon.copyPixels(icon, icon.rect, new Point(growX/2, growY/2));
			return biggerIcon;
		}
	    
	    public static function addRollOverFeedbackMarker(marker:Marker):void {
		        marker.addEventListener(MapMouseEvent.ROLL_OVER,
	                function(event:MapMouseEvent):void {
	                	marker.foreground.filters = [rollOverFilter];
	                }
	                );
		        marker.addEventListener(MapMouseEvent.ROLL_OUT,
	                function(event:MapMouseEvent):void {
	                	marker.foreground.filters = [];
	                }
	                );    	
	    }

	    public static function addRollOverFeedback(marker:UIComponent):void {
		        marker.addEventListener(MouseEvent.ROLL_OVER,
	                function(event:MouseEvent):void {
	                	marker.filters = [rollOverFilter];
	                }
	                );
		        marker.addEventListener(MouseEvent.ROLL_OUT,
	                function(event:MouseEvent):void {
	                	marker.filters = [];
	                }
	                );    	
	    }

	}
}