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
	import de.geowidget.manager.model.SessionProxy;
	import de.geowidget.manager.model.vo.CommitDataVO;
	import de.geowidget.manager.model.vo.FeaturesVO;
	import de.geowidget.manager.model.vo.UserVO;
	import de.geowidget.manager.utils.EuroFormatter;
	import de.geowidget.manager.view.components.TestTab;
	
	import flash.events.Event;
	
	import ms.util.StringUtil;
	import mx.utils.StringUtil;
	import gnu.as3.gettext.FxGettext;
	
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class TestTabMediator extends Mediator
	{
		public static const NAME:String  = "TestTabMediator";
		
		// Buffer show map state, so we can set the visiblity state after the widget url has been determined
		private var showMap:Boolean = false;
		
		public function TestTabMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			tab.addEventListener(FlexEvent.SHOW, handleShow);
			tab.addEventListener(FlexEvent.HIDE, handleHide);
			tab.tosLabel.htmlText = mx.utils.StringUtil.substitute(FxGettext.gettext("Yes, I agree to the <u><a href='{0}' target='_blank'>terms of service</a></u>, the <u><a href='{1}' target='_blank'>terms of use</a></u> and the <u><a href='{2}' target='_blank'>terms of use for the Google Maps API</a></u>"), "/pages/agb", "/pages/terms", "http://code.google.com/intl/de-DE/apis/maps/terms.html");
		}
		
		public function get tab():TestTab{
			return viewComponent as TestTab;
		}
		
		private function handleShow(e:Event):void {
			showMap = true;
			sendNotification(Messages.SAVE_WIDGET);
		}
		
		private function handleHide(e:Event):void {
			showMap = tab.map.visible = false;	
		}

		override public function listNotificationInterests() : Array{
			return [Messages.WIDGET_SAVED, Messages.COMMIT_DATA_UPDATED, Messages.RESTART_APP];
		}
		
		override public function handleNotification(notification:INotification) : void{
			switch(notification.getName()){
				case Messages.WIDGET_SAVED:
					if(showMap) {
						tab.map.source = notification.getBody() as String;
						tab.map.visible = true;	
					}
					break;
				case Messages.COMMIT_DATA_UPDATED:
					// set commit text
					var user:UserVO = (facade.retrieveProxy(SessionProxy.NAME) as SessionProxy).user;
					var commitData:CommitDataVO = notification.getBody() as CommitDataVO;
					var formatter:EuroFormatter = new EuroFormatter();
					tab.commitText.htmlText = ms.util.StringUtil.template(FxGettext.gettext("To the right you see the preview of the widget as you have configured it.<br/><br/>Before continuing make sure<br/>the widget looks like you expected.<br/><br/>By pressing the '<b>Generate Widget</b>' button your changes<br/>will be visible to your live environment.<br/><br/>Configuration for:<br/>{firstName} {lastName}<br/><br/>You have selected the following options:<br/>{options}<br/><br/>The new configuration has <b>{numberLocations} locations</b>.<br/>So your monthly costs for the widget are <b>{pricePerMonth}</b>.<br/>So your yearly costs for the widget are <b>{pricePerYear}</b>.")
					 , {
						 numberLocations: commitData.numberLocations,
						 pricePerLocation: formatter.format(commitData.pricePerLocation),
						 pricePerMonth: formatter.format(commitData.pricePerMonth),
						 pricePer3Months: formatter.format(commitData.pricePer3Months),
						 pricePer6Months: formatter.format(commitData.pricePer6Months),
						 pricePerYear: formatter.format(commitData.pricePerYear),
						 options: buildOptions(commitData.features),
						 firstName: user.firstName,
						 lastName: user.lastName,
						 email: user.email,
						 website: user.website,
						 gender: user.gender
					 });
					break;
				case Messages.RESTART_APP:
					tab.tos.selected = false;
					tab.tos.errorString = '';
					tab.validationForm.showErrorMessage('');
					break;
			}
		}
		
		private function buildOptions(features:FeaturesVO):String {
			var result:String = "";
			
			if(features.showZoom)
				result += FxGettext.gettext("<li>Show zoom bar</li>");
			if(features.showOverview)
				result += FxGettext.gettext("<li>Show overview map</li>");
			if(features.showMapTypes)
				result += FxGettext.gettext("<li>Show map type component</li>");
			if(features.showRoute)
				result += FxGettext.gettext("<li>Enable routing</li>");
			if(features.showSearch)
				result += FxGettext.gettext("<li>Show search bar</li>");
			if(features.showWelcomeText)
				result += FxGettext.gettext("<li>Welcome Text</li>");
			if(!features.dontCluster)
				result += FxGettext.gettext("<li>Cluster locations</li>");
			
			return result;
		}

	}
}