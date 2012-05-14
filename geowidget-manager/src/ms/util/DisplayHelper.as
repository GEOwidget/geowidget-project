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
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gnu.as3.gettext.FxGettext;
	
	import mx.containers.TitleWindow;
	import mx.controls.Alert;
	import mx.controls.ProgressBar;
	import mx.core.Application;
	import mx.core.Container;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	public class DisplayHelper
	{
		private static var progressBar:ProgressBar;
		
		public static function decorateWithWindow(child:DisplayObject, width:Number, height:Number, closeButton:Boolean = false):TitleWindow {
			var window:TitleWindow = new TitleWindow();
			window.width = width;
			window.height = height;
			window.showCloseButton = closeButton;
			window.addChild(child);
			return window;
		}

		public static function displayPopup(window:IFlexDisplayObject, parent:DisplayObject, removeOnClick:Boolean = true):void {
			if(removeOnClick) {
				window.addEventListener(MouseEvent.CLICK, function():void {
					PopUpManager.removePopUp(window);
				});
			}
			if(window is TitleWindow && TitleWindow(window).showCloseButton) {
				window.addEventListener(Event.CLOSE, function():void {
					PopUpManager.removePopUp(window);
				});
			}
	        PopUpManager.addPopUp(window, parent, true);
	        PopUpManager.centerPopUp(window);
		}
		
		public static function displayPage(parent:DisplayObject, pagePath:String, styleName:String, removeOnClick:Boolean = true, showCloseButton:Boolean = false):void {
        	var child:DisplayObject = DisplayObjectFactory.createDisplayObject(null, pagePath, styleName, false);
			var window:TitleWindow = decorateWithWindow(child, 500, 500, showCloseButton);
			DisplayHelper.displayPopup(window, parent, removeOnClick);
		}
		
		public static function trackProgress(label:String, obj:Object, indeterminate:Boolean=false):void {
			if(progressBar==null) {
				progressBar = new ProgressBar();
			} else
				removeProgress();
	        PopUpManager.addPopUp(progressBar, DisplayObject(Application.application));
			PopUpManager.centerPopUp(progressBar);
			progressBar.indeterminate = indeterminate;
    		progressBar.source = obj;
        	progressBar.label = label + " %3%%";
        	progressBar.labelPlacement="center"
        	progressBar.addEventListener(Event.COMPLETE, function():void {
        		PopUpManager.removePopUp(progressBar);
        	});
		}
		
		public static function removeProgress():void {
			if(progressBar!=null)
				PopUpManager.removePopUp(progressBar);
		}
		
		public static function hasChild(container:Container, child:UIComponent):Boolean {
			return child.parent === container;
		}
		
	}
}