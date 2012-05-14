/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.model
{
	import com.adobe.serialization.json.JSON;
	
	import de.geowidget.manager.controller.Messages;
	import de.geowidget.manager.model.vo.CommitDataVO;
	import de.geowidget.manager.model.vo.ConfigVO;
	
	import ms.controls.IFrame;
	
	import mx.controls.Alert;
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class CommitProxy extends Proxy
	{
		public static const NAME:String = "CommitProxy";

		// this will be injected from other place
		public var commitService:RemoteObject;

		public function CommitProxy()
		{
			super(NAME, new CommitDataVO());
		}
		
		public function get commitData():CommitDataVO{
			return data as CommitDataVO;
		}
		
		public function updateCommitData(config:ConfigVO):void {
			var token:AsyncToken = commitService.getCommitData(config.locations.length);
			token.addResponder(new AsyncResponder(function(e:ResultEvent, t:Object):void{
				data = e.result as CommitDataVO;
				commitData.features = config.features;
				sendNotification(Messages.COMMIT_DATA_UPDATED, commitData);
			}, onFault));
		}
		
		public function commit(config:ConfigVO, actionCode:String):void {
			var envProxy:EnvironmentProxy = facade.retrieveProxy(EnvironmentProxy.NAME) as EnvironmentProxy;
			
			envProxy.saveEnvironment(EnvironmentProxy.ENVIRONMENT_PRODUCTION, config, function(url:String, source:String):void {
				var token:AsyncToken = commitService.commit(actionCode, config.locations.length);
				token.addResponder(new AsyncResponder(function(e:ResultEvent, token:AsyncToken):void{
					trace(' COMMITTED ');
					
					sendNotification(Messages.COMMITED);
					sendNotification(Messages.PRODUCTION_URL_UPDATED, url);
					sendNotification(Messages.WIDGETSOURCE_UPDATED, source);
				}, onFault));
			});
		}
		
		private function onFault(event:FaultEvent, token:Object):void {
			
			sendNotification(Messages.FAULT_MESSAGE, event.fault.faultString);
		}

	}
}