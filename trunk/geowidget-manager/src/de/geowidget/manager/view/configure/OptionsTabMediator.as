/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.view.configure
{
	import de.geowidget.manager.controller.Messages;
	import de.geowidget.manager.model.vo.ClusterVO;
	import de.geowidget.manager.model.vo.ConfigVO;
	import de.geowidget.manager.view.configure.components.OptionsTab;
	import de.geowidget.manager.view.configure.options.ClusterOptionsMediator;
	import de.geowidget.manager.view.dialog.EditHTMLDialog;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class OptionsTabMediator extends Mediator
	{
		public static const NAME:String = "OptionsTabMediator";
		
		public function OptionsTabMediator(data:Object = null)
		{
			super(NAME, data);
			
			tab.showSearchBar.addEventListener(FlexEvent.VALUE_COMMIT, handleSearchBar);
			tab.clusterLocations.addEventListener(FlexEvent.VALUE_COMMIT, handleClusterLocations);
			tab.showRoute.addEventListener(FlexEvent.VALUE_COMMIT, handleRoute);
			// welcome text stuff
			tab.showWelcomeText.addEventListener(FlexEvent.VALUE_COMMIT, handleWelcomeText);
			tab.welcomeTextEdit.addEventListener(MouseEvent.CLICK, handleEditWelcomeText);
		}
		
		override public function onRegister():void {
			facade.registerMediator(new ClusterOptionsMediator(tab.clusterOptions));
		}
		
		public function get tab():OptionsTab{
			return viewComponent as OptionsTab;
		}
		
		private function handleWelcomeText(e:Event):void {
			tab.config.features.showWelcomeText = tab.showWelcomeText.selected;
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		}
		
		private function handleEditWelcomeText(e:Event):void {
			var dlg:EditHTMLDialog = PopUpManager.createPopUp(tab, EditHTMLDialog, true) as EditHTMLDialog;
			dlg.htmlText = tab.config.features.welcomeText;
			PopUpManager.centerPopUp(dlg);
			dlg.addEventListener("ACCEPT_OK",handleDlgClose);
			dlg.addEventListener("ACCEPT_CANCEL",handleDlgClose);
		}

		private function handleDlgClose(e:Event):void{
			var dlg:EditHTMLDialog = e.currentTarget as EditHTMLDialog;
			dlg.removeEventListener("ACCEPT_OK",handleDlgClose);
			dlg.removeEventListener("ACCEPT_CANCEL",handleDlgClose);
			PopUpManager.removePopUp(dlg);
			if(e.type == "ACCEPT_OK")
			{
				tab.config.features.welcomeText = dlg.htmlText;
			}
			// THIS IS A HACK: we have to update the config on a cancel event to, as the CKEDITOR destroys our preview
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		}
		
		private function handleRoute(e:Event):void {
			tab.config.features.showRoute = tab.showRoute.selected;
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		}

		private function handleSearchBar(e:Event):void {
			tab.config.features.showSearch = tab.showSearchBar.selected;
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		};
		
		private function handleClusterLocations(e:Event):void {
			tab.config.features.dontCluster = !tab.clusterLocations.selected;
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		};

		override public function listNotificationInterests() : Array{
			return [Messages.CONFIG_UPDATED];
		}
		
		override public function handleNotification(notification:INotification) : void{
			switch(notification.getName()){
				case Messages.CONFIG_UPDATED:
					tab.config = notification.getBody() as ConfigVO;
					// show/hide option panels
					tab.welcomeTextOptions.enabled = tab.config.features.showWelcomeText;
					tab.clusterOptions.enabled = !tab.config.features.dontCluster;
				break;
			}
		}
	}
}