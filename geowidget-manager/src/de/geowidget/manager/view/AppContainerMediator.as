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
	import de.geowidget.manager.view.components.AppContainer;
	import de.geowidget.manager.view.configure.LayoutTabMediator;
	import de.geowidget.manager.view.configure.OptionsTabMediator;
	import de.geowidget.manager.view.dialog.FeedbackDialog;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gnu.as3.gettext.FxGettext;
	import gnu.as3.gettext._FxGettext;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	import mx.utils.URLUtil;
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class AppContainerMediator extends Mediator
	{
		public static const NAME:String = "AppContainerMediator";
		[Bindable]
		private var fx:_FxGettext = FxGettext;
		private var informUserOfSave:Boolean = false;
		
		private var actionCode:String;
		
		public function AppContainerMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			Application.application.previewButton.addEventListener(Event.CHANGE, handlePreviewToogle);
			Application.application.feedbackButton.addEventListener(MouseEvent.CLICK, handleFeedbackClick);
			
			tab.views.addEventListener(Event.CHANGE, handleViewIndexChange);
			tab.configureTab.addEventListener(Event.CHANGE, handleViewIndexChange);
			
			Application.application.welcomeContainer.views.addEventListener(Event.CHANGE, handleViewIndexChange);
			tab.saveButton.addEventListener(MouseEvent.CLICK, handleSave);
			tab.backForwardButtons.addEventListener("change", handleBackForward);
			tab.backForwardButtons.addEventListener("commit", handleCommit);
			tab.backForwardButtons.okLabel = FxGettext.gettext('Back to your account');
		}
		
		override public function onRegister():void {
			facade.registerMediator(new StoresTabMediator(tab.storeTab));
			facade.registerMediator(new BuildTabMediator(tab.buildTab));
			facade.registerMediator(new TestTabMediator(tab.testTab));
			facade.registerMediator(new LayoutTabMediator(tab.configureTab.layoutTab));
			facade.registerMediator(new OptionsTabMediator(tab.configureTab.optionsTab));
			facade.registerMediator(new JSPreviewMediator(Application.application.preview));
		}
		
		public function get tab():AppContainer{
			return viewComponent as AppContainer;
		}
		
		private function setPreview(enable:Boolean):void {
			Application.application.previewButton.selected = enable;
			Application.application.preview.visible = enable;
			Application.application.preview.width = Application.application.preview.visible ? 420 : 0;
		}
		
		private function handleCommit(e:Event):void {
			
			sendNotification(Messages.COMMIT_REQUEST, actionCode);
			
		}
		
		private function handleSave(e:Event):void {
			tab.saveButton.enabled = false;
			informUserOfSave = true;
			sendNotification(Messages.SAVE_WIDGET);
		}
		
		private function handleBackForward(e:Event):void{
			
			// do autosave on view change (but only if there is something to save)
			if(tab.saveButton.enabled) {
				informUserOfSave = false;
				sendNotification(Messages.SAVE_WIDGET);
			}
		}
		
		private function handleViewIndexChange(e:Event):void{
			
			Application.application.previewButton.visible = true;
			Application.application.feedbackButton.visible = true;
			
			if(Application.application.welcomeContainer.views.selectedIndex!=3 || tab.views.selectedIndex>=2)
			{
				setPreview(false);
				
				Application.application.previewButton.visible = false;
				Application.application.feedbackButton.visible = false;
			}
			
		}
		
		private function handlePreviewToogle(e:Event):void{
			setPreview(Application.application.previewButton.selected);
		}
		
		private function handleFeedbackClick(e:Event):void{
			
			var dlg:FeedbackDialog = PopUpManager.createPopUp(tab,FeedbackDialog, true) as FeedbackDialog;
			PopUpManager.centerPopUp(dlg);
			dlg.addEventListener("ACCEPT_OK",handleFeedbackDialogClose);
			dlg.addEventListener("ACCEPT_CANCEL",handleFeedbackDialogClose);
		}
		
		private function handleFeedbackDialogClose(e:Event):void
		{
			var dlg:FeedbackDialog = e.currentTarget as FeedbackDialog;
			
			dlg.removeEventListener("ACCEPT_OK", handleFeedbackDialogClose);
			dlg.removeEventListener("ACCEPT_CANCEL", handleFeedbackDialogClose);
			
			PopUpManager.removePopUp(dlg);
			
			if(e.type == "ACCEPT_OK")
			{
				Alert.show(FxGettext.gettext("Your feedback has been send successfully"));
			}
		}

		override public function listNotificationInterests() : Array{
			return [Messages.CONFIG_UPDATED, Messages.WIDGET_SAVED, Messages.COMMITED, Messages.RESTART_APP, Messages.METADATA_UPDATED, Messages.DISABLE_PREVIEW];
		}
		
		override public function handleNotification(notification:INotification) : void{
			switch(notification.getName()){
				case Messages.METADATA_UPDATED:
				case Messages.CONFIG_UPDATED:
					tab.saveButton.enabled = true;
					break;
				case Messages.WIDGET_SAVED:
					if(informUserOfSave) {
						Alert.show(FxGettext.gettext("Your configuration has been saved successfully."));
						informUserOfSave = false;
					}
					break;
				case Messages.COMMITED:
					tab.backForwardButtons.commitSucceeded();
					break;
				case Messages.RESTART_APP:
					// reset view if app restarts
					tab.views.selectedIndex = 0;
				//	tab.configureTab.selectedIndex = 0;
					Application.application.previewButton.selected = false;
					setPreview(false);
					break;
				case Messages.DISABLE_PREVIEW:
					setPreview(false);
					break;
			}
		}
		
	}
}