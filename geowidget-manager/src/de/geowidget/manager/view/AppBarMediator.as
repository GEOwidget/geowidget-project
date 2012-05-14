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
	import de.geowidget.manager.view.components.AppBar;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.ViewStack;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class AppBarMediator extends Mediator
	{
		public static const NAME:String = "AppBarMediator";
		public function AppBarMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			tab.logoutBtn.addEventListener(MouseEvent.CLICK,logout);
			// disable click event for the button bar
			tab.buttonBar.addEventListener(MouseEvent.CLICK, function(event:Event):void {
				event.stopImmediatePropagation();
			}, true);
		}
		
		public function get tab():AppBar{
			return viewComponent as AppBar;
		}
		
		private function logout(e:Event):void{
			sendNotification(Messages.LOGOUT_REQUEST);
		}
		
		override public function listNotificationInterests() : Array{
			return [Messages.SET_NAVIGATION_VIEW];
		}
		
		override public function handleNotification(notification:INotification) : void{
			switch(notification.getName()){
				case Messages.SET_NAVIGATION_VIEW:
					var views:ViewStack = notification.getBody() as ViewStack;
					tab.buttonBar.dataProvider = views;
					break;
			}
		}
	}
}