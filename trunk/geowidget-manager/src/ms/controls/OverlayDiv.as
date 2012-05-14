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
	
	import mx.containers.Canvas;
	import mx.events.FlexEvent;
	import mx.events.MoveEvent;
	import mx.events.ResizeEvent;
	
	public class OverlayDiv extends Canvas
	{
		
		public function OverlayDiv()
		{
			super();
			
			addEventListener(MoveEvent.MOVE, updatePosition);
			addEventListener(ResizeEvent.RESIZE, updatePosition);
			addEventListener(FlexEvent.ADD, addedAsChild);
			
		}
		
		public function applyTemplate(templateStr:String, data:Object):void {
			
			callLater(applyTemplate2, [templateStr, data]);
			
		}
		
		private function applyTemplate2(templateStr:String, data:Object):void {
			
			var jsonStr:String = JSON.encode(data);
			
			ExternalInterface.call('overlayDivApplyTemplate', this.id, templateStr, jsonStr);
			
		}
		
		public function clear():void {
			
			ExternalInterface.call('overlayDivClear', this.id);
			
		}
		
		public function restoreVisibility():void {
			
			updateVisiblity(visible);
			
		}
		
		public function restorePositionSize():void {
			if(visible) {
				callLater(overlayDivMove);
			}
		}
		
		public function set source(src:String):void
		{
			ExternalInterface.call('overlayDivLoad', this.id, src);
		}
		
		private function addedAsChild(e:FlexEvent):void {
			parent.addEventListener(MoveEvent.MOVE, updatePosition);
		}
		
		protected function updatePosition(e:Event):void {
			if(visible) {
				
				callLater(overlayDivMove);
			}
		}
		
		/**
		 * Move overlay div through ExternalInterface.  The location is determined using localToGlobal()
		 * on a Point in the Canvas.
		 **/
		private function overlayDivMove(): void
		{
			
			var localPt:Point = new Point(0, 0);
			var globalPt:Point = this.localToGlobal(localPt);
			
			ExternalInterface.call("overlayDivMove", this.id, globalPt.x, globalPt.y, this.width, this.height);
		}
		
		/**
		 * Whether the IFrame is visible.
		 **/
		override public function set visible(visible: Boolean): void
		{
			super.visible=visible;
			
			updateVisiblity(visible);
		}
		
		private function updateVisiblity(visible:Boolean):void {
			
			if (visible)
			{
				ExternalInterface.call("overlayDivShow", this.id);
			}
			else 
			{
				ExternalInterface.call("overlayDivHide", this.id);
			}
		}
		
	}
}