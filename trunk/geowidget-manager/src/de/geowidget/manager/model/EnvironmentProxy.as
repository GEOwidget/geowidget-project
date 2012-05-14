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
	import de.geowidget.manager.model.vo.ClusterVO;
	import de.geowidget.manager.model.vo.ConfigVO;
	import de.geowidget.manager.model.vo.IconVO;
	import de.geowidget.manager.model.vo.ImageVO;
	import de.geowidget.manager.model.vo.LocationVO;
	import de.geowidget.manager.model.vo.UserVO;
	import de.geowidget.manager.model.vo.metadata.HTMLTemplateMetaVO;
	
	import mx.rpc.AsyncResponder;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class EnvironmentProxy extends Proxy
	{
		public static const NAME:String = "EnvironmentProxy";
		
		public static const ENVIRONMENT_PREVIEW:String = "preview";
		public static const ENVIRONMENT_TEST:String = "test";
		public static const ENVIRONMENT_PRODUCTION:String = "production";
		
		// this will be injected from other place
		public var widgetService:RemoteObject;
		public var commitService:RemoteObject;
		
		public function EnvironmentProxy()
		{
			super(NAME);
		}
		
		/**
		 * Generates for each icon in the ConfigVO a PNG and returns them in an Array
		 * @param config
		 * @return generated icons as PNG
		 */
		private function generateServerIconsFromConfig(config:ConfigVO):Array {
			
			var result:Array = new Array();
			var icon:IconVO;
			
			for(var i:int = 0; i<config.icons.length; i++)
			{
				icon = config.icons[i] as IconVO;
				result = result.concat(icon.createServerIcon());
			}
			
			result = result.concat(config.positionIcon.createServerIcon());
			result = result.concat((config.clusters[0] as ClusterVO).createServerIcon());
			
			return result;
		}
		
		private function generateServerImagesFromConfig(config:ConfigVO):Array {
			
			var result:Array = new Array();
			var image:ImageVO;
			
			for(var i:int = 0; i<config.images.length; i++)
			{
				image = config.images[i] as ImageVO;
				result = result.concat(image.createServerImage());
			}
			
			return result;
		}
		
		private function generateServerTemplatesFromConfig(config:ConfigVO):Array {
			
			var result:Array = new Array();
			var template:HTMLTemplateMetaVO;
			
			for(var i:int = 0; i<config.infotemplates.length; i++)
			{
				template = config.infotemplates[i] as HTMLTemplateMetaVO;
				result = result.concat(template.createServerTemplate());
			}
			
			return result;
		}
		
		public function saveEnvironment(environment:String, config:ConfigVO, callback:Function):void {
			// TODO check whether sessions still exists
			
			var sessionProxy:SessionProxy = facade.retrieveProxy(SessionProxy.NAME) as SessionProxy;
			
			var user:UserVO = sessionProxy.user;
			
			for each(var location:LocationVO in config.locations)
			{
				
				if(location.iconVO != null)
				{
					location.icon = location.iconVO.id;
				}
				else
				{
					location.icon = null;
				}
				
				if(location.imageVO != null)
				{
					location.image = location.imageVO.id;
					location.imageURL = user.folder + '/' + environment + '/' + location.imageVO.image;
				}
				else
				{
					location.image = null;
					location.imageURL = null;
				}
				
				var locationTemplates:Array = new Array();
				if(location.infoWindowTemplateVOs != null)
				{
					for(var i:int=0; i<location.infoWindowTemplateVOs.length; i++) {
						locationTemplates.push(location.infoWindowTemplateVOs[i].filename);
					}
				}
				location.templates = locationTemplates;
				
			}
			
			config.locale = user.getLocale(); // add the user's locale to the config
			
			var icons:Array = generateServerIconsFromConfig(config);
			var images:Array = generateServerImagesFromConfig(config);
			var templates:Array = generateServerTemplatesFromConfig(config);
			
			var token:AsyncToken = widgetService.saveWidget(environment, templates, JSON.encode(config));
			token.addResponder(new AsyncResponder(function(e:ResultEvent, token:AsyncToken):void{
				widgetService.saveImages(environment, icons, images);
				var widgetSource:String = e.result.code as String;
				var url:String = e.result.url as String;
				callback(url, widgetSource);
			}, onFault));
		}
		
		public function load():void {
			var token:AsyncToken = widgetService.loadWidget();
			token.addResponder(new AsyncResponder(function(event:ResultEvent, t:Object):void {
				var obj:String = event.result.json as String;
				// the config is delivered as JSON from the server for two reasons 
				// 1. the Zend_AMF implementation was not able to serialize a full ConfigVO
				// 2. the server needs to store the config as JSON anyway for the widget
				if(obj!=='undefined' && obj!=='null') {
					var demoUrl:String = event.result.demoUrl as String;
					var json:Object = JSON.decode(obj);
					sendNotification(Messages.LOAD_CONFIG, json);
					sendNotification(Messages.TEST_URL_UPDATED, demoUrl);
				}
			}, onFault));
		}
		
		public function save(config:ConfigVO):void {
			saveEnvironment(ENVIRONMENT_TEST, config, function(url:String, source:String):void {
				sendNotification(Messages.WIDGET_SAVED, url);
				var commitProxy:CommitProxy = facade.retrieveProxy(CommitProxy.NAME) as CommitProxy;
				commitProxy.updateCommitData(config);
			});
		}

		public function remove():void
		{
			var token:AsyncToken = widgetService.removeWidget([ENVIRONMENT_TEST, ENVIRONMENT_PREVIEW]);
			token.addResponder(new AsyncResponder(function(e:ResultEvent, token:AsyncToken):void {
				
				sendNotification(Messages.RESTART_APP);
				
			}, onFault));
		}
		
		public function preview(config:ConfigVO):void {
			saveEnvironment(ENVIRONMENT_PREVIEW, config, function(url:String, source:String):void {
				sendNotification(Messages.PREVIEW_URL_UPDATED, url);
			});
		}
		
		private function onFault(event:FaultEvent, token:Object):void {
			
			sendNotification(Messages.FAULT_MESSAGE,event.fault.faultString);
		}

	}
}