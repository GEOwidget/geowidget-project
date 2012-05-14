/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.model
{
	import de.geowidget.manager.controller.Messages;
	import de.geowidget.manager.model.vo.CountryVO;
	import de.geowidget.manager.model.vo.LocationVO;
	import de.geowidget.manager.model.vo.UserVO;
	import de.geowidget.manager.utils.GeoHelper;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import gnu.as3.gettext.FxGettext;
	import gnu.as3.gettext.ISO_639_1;
	import gnu.as3.gettext.Locale;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class SessionProxy extends Proxy
	{
		public static const NAME:String = "SessionProxy";
		
		//this will be injected at other place
		public var sessionService:RemoteObject;
		
		[Bindable]
		public var countryList:ArrayCollection;
		
		private var countryByCode:Object;
		
		public function SessionProxy()
		{
			super(NAME, new UserVO());
		}
		
		public function get user():UserVO {
			return data as UserVO;
		}
		
		public function logout():void{
			var token:AsyncToken = sessionService.getOperation('logout').send();
			token.addResponder(new mx.rpc.Responder(function():void {
				sendNotification(Messages.LOGOUT);
				navigateToURL(new URLRequest('/'), '_self');
			}, onFault));
		}
		
		public function getUser():void {
			
			var token:AsyncToken = sessionService.getUser();
			token.addResponder(new AsyncResponder(function(event:ResultEvent, t:Object):void {
				data = event.result as UserVO;
				setlocale(Locale.LC_MESSAGES, Locale.__FP_ISO639_TO_LOCALE__[user.langCode]);
				GeoHelper.getInstance().setGeocoderLanguage(ISO_639_1.codes[user.langCode]);
				
				sendNotification(Messages.USER_UPDATED, data);
			}, onFault));
		}
		
	    public function getCountryByLocation(location:LocationVO):CountryVO {
			if(location != null && location.country != null) {
				return getCountryByCode(location.country);
			} else {
				return null;
			}
	    }
		
		public function getCountryByCode(code:String):CountryVO
		{
			if(code !=null && countryByCode != null && countryByCode[code.toUpperCase()])
			{
				return countryByCode[code.toUpperCase()];
			}
			
			return null;
		}
		
		public function getCountryList():void
		{
			
			var currentLocale:String = Locale.setlocale(Locale.LC_MESSAGES);
			var token:AsyncToken = sessionService.getCountryList(currentLocale);
			
			token.addResponder(new AsyncResponder(function(event:ResultEvent, t:Object):void {
				
				var resultArr:Array = event.result as Array;
				
				var newCountryList:ArrayCollection = new ArrayCollection(resultArr);
				
				countryByCode = new Object();
				
				for each(var country:CountryVO in resultArr)
				{
					if(country.code != null)
					{
						countryByCode[country.code.toUpperCase()] = country;
					}
				}
				
				countryList = newCountryList;
				
			}, onFault));
			
		}
		
		private function onFault(e:FaultEvent, t:Object):void{
			sendNotification(Messages.FAULT_MESSAGE, FxGettext.gettext("Error while accessing your session."));
		}
		
	}
}