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
	import de.geowidget.manager.model.vo.ConfigVO;
	import de.geowidget.manager.model.vo.UserVO;
	import de.geowidget.manager.model.FileProxy;
	import de.geowidget.manager.view.components.WelcomeContainer;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import gnu.as3.gettext.FxGettext;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.events.CloseEvent;
	import mx.rpc.events.FaultEvent;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	
	public class WelcomeMediator extends Mediator
	{
		public static const NAME:String  = "WelcomeMediator";
		
		private var _user:UserVO;
		
		public function WelcomeMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			container.welcomeFirstTime.okButton.addEventListener(MouseEvent.CLICK, handleWelcomeClick);
			container.welcomeFirstTime.parisButton.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				navigateToURL(new URLRequest('/geowidget-js/index.html?root=customers/myparis'), '_blank');
			});
			container.welcomeFirstTime.golfButton.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				navigateToURL(new URLRequest('/geowidget-js/index.html?root=customers/mygolf'), '_blank');
			});
			container.welcomeFirstTime.storeButton.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				navigateToURL(new URLRequest('/geowidget-js/index.html?root=customers/ias'), '_blank');
			});
			container.welcome.okButton.addEventListener(MouseEvent.CLICK, handleWelcomeClick);
			container.welcome.removeWidgetButton.addEventListener(MouseEvent.CLICK, handleWelcomeRemoveWidgetClick);
			container.welcome.addEventListener(FlexEvent.HIDE, handleHide);
			container.appContainer.backForwardButtons.addEventListener("ok", handleBackToAccount);
			container.appContainer.backForwardButtons.addEventListener("cancel", handleBackToAccount);
			
			container.views.addEventListener(Event.CHANGE, function(e:Event):void {
				sendNotification(Messages.SET_NAVIGATION_VIEW, container.views.selectedIndex===3 ? container.appContainer.views : null);
			});
		}
		
		override public function onRegister():void {
			facade.registerMediator(new AppContainerMediator(container.appContainer));
		}
		
		public function get container():WelcomeContainer{
			return viewComponent as WelcomeContainer;
		}
		
		private function backToAccount():void {
			
			// restart app
			sendNotification(Messages.RESTART_APP);
		}
		
		private function handleHide(e:Event):void {
			container.welcome.map.visible = false;	
		}
		
		private function handleBackToAccount(e:Event):void {
			backToAccount();
		}

		private function handleWelcomeClick(e:Event):void {
			container.views.selectedIndex = WelcomeContainer.APP_INDEX;
		}
		
		private function handleWelcomeRemoveWidgetClick(e:Event):void {
			
			container.welcome.map.visible = false;
			
			var alert:Alert = Alert.show(FxGettext.gettext("Do you really want to delete the map?"), FxGettext.gettext("Confirm"), Alert.YES | Alert.NO);
			alert.addEventListener(CloseEvent.CLOSE, function(e:CloseEvent):void {
					
					if(e.detail == Alert.YES){
						sendNotification(Messages.REMOVE_WIDGET);
					}
					else
					{
						container.welcome.map.visible = true;
					}
					
				}
			)
			
			
		}
		
		private function onFault(event:FaultEvent, token:Object):void {
			
			sendNotification(Messages.FAULT_MESSAGE,event.fault.faultString);
		}
		
		override public function listNotificationInterests() : Array{
			return [Messages.USER_UPDATED, Messages.TEST_URL_UPDATED, Messages.CONFIG_UPDATED, Messages.RESTART_APP];
		}
		
		override public function handleNotification(notification:INotification) : void{
			
			switch(notification.getName()){
				case Messages.USER_UPDATED:
					_user = notification.getBody() as UserVO;
					
					if(_user.widgetSaved) {
						
						container.views.selectedIndex = WelcomeContainer.WELCOME_INDEX;
						sendNotification(Messages.LOAD_WIDGET);
						
					} else {
						
						sendNotification(Messages.LOAD_DEFAULT_TEMPLATES);
						
						container.views.selectedIndex = WelcomeContainer.WELCOME_FIRST_INDEX;
						
					}
					break;
				case Messages.TEST_URL_UPDATED:
					container.welcome.map.source = notification.getBody() as String;
					container.welcome.map.visible = true;	
					break;
				case Messages.CONFIG_UPDATED:
					var config:ConfigVO = notification.getBody() as ConfigVO;
					// the map preview must not be larger then the configured size
					container.welcome.map.maxHeight = config.widgetHeight + 20;
					container.welcome.map.maxWidth = config.widgetWidth + 30;
					break;
				case Messages.RESTART_APP:
					
					container.views.selectedIndex = WelcomeContainer.START_INDEX;
					container.welcome.map.visible = false;
					
					break;
			}
		}
	}
}