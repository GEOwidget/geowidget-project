/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 package de.geowidget.manager.controller
{
	import de.geowidget.manager.ServiceLocator;
	import de.geowidget.manager.model.FileProxy;
	import de.geowidget.manager.model.SessionProxy;
	import de.geowidget.manager.model.vo.LocationVO;
	import de.geowidget.manager.view.dialog.EditLocationDialog;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class LocationDataCmd extends SimpleCommand
	{
		public function LocationDataCmd()
		{
		}
		
		override public function execute(notification:INotification) : void{
			var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
			var sessionProxy:SessionProxy = facade.retrieveProxy(SessionProxy.NAME) as SessionProxy;
			var dlg:EditLocationDialog;
			var location:LocationVO;
			var handleDlgClose:Function;
			
			switch(notification.getName()){
				case Messages.UPDATE_LOCATION:
					// TODO: copy the updated location to the fileProxy
					// right now it's ok as fileProxy is using the same reference
					sendNotification(Messages.CONFIG_UPDATED, fileProxy.config);
					break;
				case Messages.ADD_LOCATION:
					dlg = PopUpManager.createPopUp(Application.application as DisplayObject, EditLocationDialog, true) as EditLocationDialog;
					location = new LocationVO();
					location.country = sessionProxy.user.countryCode;
					dlg.facade = facade;
					dlg.sessionProxy = sessionProxy;
					dlg.fileProxy = fileProxy;
					dlg.widgetService = ServiceLocator.getInstance().getWidgetService();
					
					dlg.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:Event):void {
						dlg.setLocation(location);
					});
					
					
					PopUpManager.centerPopUp(dlg);
					handleDlgClose = function(e:Event):void {
						dlg.removeEventListener("ACCEPT_OK", handleDlgClose);
						dlg.removeEventListener("ACCEPT_CANCEL", handleDlgClose);
						PopUpManager.removePopUp(dlg);
						if(e.type == "ACCEPT_OK")
						{
							fileProxy.addLocation(dlg.getLocation());
						}
					}	
					dlg.addEventListener("ACCEPT_OK", handleDlgClose);
					dlg.addEventListener("ACCEPT_CANCEL", handleDlgClose);
					break;
				case Messages.DELETE_LOCATION:
					fileProxy.removeRow(notification.getBody() as LocationVO);
					break;
				case Messages.EDIT_LOCATION:
					dlg = PopUpManager.createPopUp(Application.application as DisplayObject, EditLocationDialog, true) as EditLocationDialog;
					var sourceLocation:LocationVO = notification.getBody() as LocationVO;
					
					location = new LocationVO();
					location.copyFromLocation(sourceLocation);
					// as databinding is not triggered automatically, update geo status
					dlg.facade = facade;
					dlg.sessionProxy = sessionProxy;
					dlg.fileProxy = fileProxy;
					dlg.widgetService = ServiceLocator.getInstance().getWidgetService();
					
					dlg.addEventListener(FlexEvent.CREATION_COMPLETE, function(e:Event):void {
						
						dlg.setLocation(location);
					}); 
					
					PopUpManager.centerPopUp(dlg);
					handleDlgClose = function(e:Event):void {
						dlg.removeEventListener("ACCEPT_OK", handleDlgClose);
						dlg.removeEventListener("ACCEPT_CANCEL", handleDlgClose);
						PopUpManager.removePopUp(dlg);
						if(e.type == "ACCEPT_OK")
						{
							sourceLocation.copyFromLocation(dlg.getLocation());
							
							sendNotification(Messages.UPDATE_LOCATION, sourceLocation);
						}
					}	
					dlg.addEventListener("ACCEPT_OK", handleDlgClose);
					dlg.addEventListener("ACCEPT_CANCEL", handleDlgClose);
					break;
			}
		}
		
	}
}