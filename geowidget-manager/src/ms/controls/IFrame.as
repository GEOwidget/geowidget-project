/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package ms.controls
{
	
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	
	import gnu.as3.gettext.FxGettext;
	import gnu.as3.gettext._FxGettext;
	
	import mx.containers.Canvas;
	import mx.events.FlexEvent;
	import mx.events.MoveEvent;
	import mx.events.ResizeEvent;
	
	public class IFrame extends Canvas
	{
		private var fx:_FxGettext = FxGettext;
		private var _source: String;
		private var _visibleBefore: Boolean;
		public var isLoaded: Boolean = false;
		
		public function IFrame()
		{
			super();
			
			addEventListener(MoveEvent.MOVE, updatePosition);
			addEventListener(ResizeEvent.RESIZE, updatePosition);
			addEventListener(FlexEvent.ADD, addedAsChild);
			_visibleBefore = ExternalInterface.call("isIFrameVisible");
			ExternalInterface.addCallback("frameLoaded", function():void {
				isLoaded = true;
				dispatchEvent(new Event("loaded"));
			});
		}
		
		public function applyTemplateIFrame(templateStr:String, data:Object):void {
			
			callLater(applyTemplateIFrame2, [templateStr, data]);
			
		}
		
		private function applyTemplateIFrame2(templateStr:String, data:Object):void {
			
			var jsonStr:String = JSON.encode(data);
			
			ExternalInterface.call('applyTemplateIFrame', templateStr, jsonStr);
			
		}
		
		public function clearIFrame():void {
			
			ExternalInterface.call('clearIFrame');
			
		}
		
		public function restoreVisibility():void {
			
			updateIFrameVisiblity(visible);
			
		}
		
		public function restorePositionSize():void {
			if(visible) {
				callLater(moveIFrame);
			}
		}
		
		private function addedAsChild(e:FlexEvent):void {
			parent.addEventListener(MoveEvent.MOVE, updatePosition);
		}
		
		protected function updatePosition(e:Event):void {
			if(visible) {
				
				callLater(moveIFrame);
			}
		}
		
		/**
		 * Call a Javascript function inside of the IFrame with the provided parameters
		 * @param functionName
		 * @param rest
		 * @return 
		 */
		public function call(functionName:String, ... rest):* {
			if(isLoaded) {
				return ExternalInterface.call("callIFrame", functionName, rest);	
			} else 
				throw new Error("IFrame not loaded - cannot call function");
		}
		
		/**
		 * Move iframe through ExternalInterface.  The location is determined using localToGlobal()
		 * on a Point in the Canvas.
		 **/
		private function moveIFrame(): void
		{
			
			var localPt:Point = new Point(0, 0);
			var globalPt:Point = this.localToGlobal(localPt);
			
			ExternalInterface.call("moveIFrame", globalPt.x, globalPt.y, this.width, this.height);
		}
		
		/**
		 * The source URL for the IFrame.  When set, the URL is loaded through ExternalInterface.
		 **/
		public function set source(source: String): void
		{
			if (source)
			{
				
				if (! ExternalInterface.available)
				{
					throw new Error(fx.gettext("ExternalInterface is not available in this container. Internet Explorer ActiveX, Firefox, Mozilla 1.7.5 and greater, or other browsers that support NPRuntime are required."));
				}
				_source = source;
				isLoaded = false;
				ExternalInterface.call("loadIFrame", source);
				moveIFrame();
			}
		}
		
		public function get source(): String
		{
			return _source;
		}
		
		/**
		 * Whether the IFrame is visible.
		 **/
		override public function set visible(visible: Boolean): void
		{
			super.visible=visible;
			
			updateIFrameVisiblity(visible);
		}
		
		private function updateIFrameVisiblity(visible:Boolean):void {
			
			if (visible)
			{
				ExternalInterface.call("showIFrame");
			}
			else 
			{
				ExternalInterface.call("hideIFrame");
			}
		}
		
	}
}