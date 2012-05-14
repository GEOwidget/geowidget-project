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
	import de.geowidget.manager.view.components.BuildTab;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	
	import gnu.as3.gettext.FxGettext;
	import gnu.as3.gettext._FxGettext;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class BuildTabMediator extends Mediator
	{
		public static const NAME:String  = "BuildTabMediator";
		[Bindable]
		private var fx:_FxGettext = FxGettext;
		private const template:String = FxGettext.gettext("<p>Please embed the HTML code below into your HTML file to include the generated widget. For your convenience you can also use this <a href='{0}' target='_blank'>example HTML</a> as template.</p>");
		
		
		public function BuildTabMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			init();
		}
		
		public function get tab():BuildTab{
			return viewComponent as BuildTab;
		}
		
		protected function init():void{
			tab.headText.text= template;
		}
		
		override public function listNotificationInterests() : Array{
			return [Messages.PRODUCTION_URL_UPDATED, Messages.WIDGETSOURCE_UPDATED];
		}
		
		override public function handleNotification(notification:INotification) : void{
			switch(notification.getName()){
				case Messages.PRODUCTION_URL_UPDATED:
					tab.headText.text = StringUtil.substitute(template,notification.getBody() as String);
				break;
				case Messages.WIDGETSOURCE_UPDATED:
					tab.widgetSource.text = notification.getBody() as String;
				break;
			}
		}
		
	}
}