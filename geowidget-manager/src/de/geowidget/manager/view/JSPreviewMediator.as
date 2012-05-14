/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.view
{
	import de.geowidget.manager.controller.Messages;
	import de.geowidget.manager.view.components.JSPreview;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class JSPreviewMediator extends Mediator
	{
		public static const NAME:String = "JSPreviewMediator";

		// Buffer show map state, so we can set the visiblity state after the widget url has been determined
		private var showMap:Boolean = false;
		
		public function JSPreviewMediator(data:Object = null)
		{
			super(NAME,data);
			preview.addEventListener(FlexEvent.SHOW, handleShow);
			preview.addEventListener(FlexEvent.HIDE, handleHide);
		}
		
		public function get preview():JSPreview{
			return viewComponent as JSPreview;
		}
		
		private function handleShow(e:Event):void {
			showMap = true;
			sendNotification(Messages.PREVIEW_REQUEST);
		}
		
		private function handleHide(e:Event):void {
			showMap = preview.mapPreview.visible = false;
		}
		
		override public function listNotificationInterests() : Array{
			return [Messages.PREVIEW_URL_UPDATED, Messages.CONFIG_UPDATED, Messages.METADATA_UPDATED];
		}
		
		override public function handleNotification(notification:INotification) : void{
			switch(notification.getName()){
				case Messages.PREVIEW_URL_UPDATED:
					if(showMap) {
						preview.mapPreview.source = notification.getBody() as String;
						preview.mapPreview.visible = true;
					}
				break;
				case Messages.CONFIG_UPDATED:
				case Messages.METADATA_UPDATED:
					if(showMap) {
						sendNotification(Messages.PREVIEW_REQUEST);
					}
				break;
			}
		}
	}
}