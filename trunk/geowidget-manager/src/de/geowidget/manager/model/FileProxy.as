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
	import de.geowidget.manager.model.vo.*;
	import de.geowidget.manager.model.vo.metadata.HTMLTemplateMetaVO;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import gnu.as3.gettext.FxGettext;
	
	import ms.util.ObjectUtil;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class FileProxy extends Proxy
	{
		
		[Embed(source='/assets/templates/template_streetview.png')]
		private const templateStreetViewClass:Class;
		[Embed(source='/assets/templates/template_store.png')]
		private const templateStoreClass:Class;
		[Embed(source='/assets/templates/template_office.png')]
		private const templateOfficeClass:Class;
		[Embed(source='/assets/templates/template_custom.png')]
		private const templateCustomClass:Class;
		
		public static const NAME:String = "FileProxy";
		
		[Bindable]
		public var locations:ArrayCollection = new ArrayCollection();
		
		public function FileProxy()
		{
			super(NAME, new ConfigVO());
		}
		
		/**
		 * loads the templates for the first time, if user has no widget saved  
		 */
		public function loadDefaultTemplates(cleanConfig:Boolean=true):void
		{
			var sessionProxy:SessionProxy = facade.retrieveProxy(SessionProxy.NAME) as SessionProxy;
			var user:UserVO = sessionProxy.user;
			
			if(cleanConfig) {
				config.infotemplates = new Array();
			}
			
			var templatesBaseUrl:String = '/flash/templates/' + user.getLocale() + '/';
			var templatesBaseDir:String = '{root}/templates/';
			
			var htmlTemplateVO:HTMLTemplateMetaVO;

			htmlTemplateVO = loadHtmlTemplate(templatesBaseDir + '_streetview.html', templatesBaseUrl + 'streetview.html');
			config.infotemplates.push(htmlTemplateVO);
			
			htmlTemplateVO = loadHtmlTemplate(templatesBaseDir + '_store.html', templatesBaseUrl + 'store.html');
			config.infotemplates.push(htmlTemplateVO);
			
			htmlTemplateVO = loadHtmlTemplate(templatesBaseDir + '_office.html', templatesBaseUrl + 'office.html');
			config.infotemplates.push(htmlTemplateVO);
			
			if(cleanConfig) {
				setTemplatesPreview();
			}
		}
		
		/**
		 * Set label and preview of InfoWindowTemplateVO object
		 * 
		 */
		private function setTemplatesPreview():void
		{
			var htmlTemplateVO:HTMLTemplateMetaVO;
			
			for each(htmlTemplateVO in config.infotemplates)
			{
				switch(htmlTemplateVO.filename)
				{
					case '{root}/templates/_streetview.html':
						htmlTemplateVO.previewBitmap = new templateStreetViewClass(); 
						break;
					case '{root}/templates/_store.html':
						htmlTemplateVO.previewBitmap = new templateStoreClass();
						break;
					case '{root}/templates/_office.html':
						htmlTemplateVO.previewBitmap = new templateOfficeClass();
						break;
					default:
						htmlTemplateVO.previewBitmap = new templateCustomClass();
						break;
				}
			}
			
		}
		
		private function loadHtmlTemplate(filename:String, url:String=null):HTMLTemplateMetaVO
		{
			if(url==null) {
				// if url is not defined parse it from the filename	
				var sessionProxy:SessionProxy = facade.retrieveProxy(SessionProxy.NAME) as SessionProxy;
				var user:UserVO = sessionProxy.user;
				var widgetUrl:String = user.folder + '/' + EnvironmentProxy.ENVIRONMENT_TEST;
				url = filename.replace('{root}', widgetUrl);
			}
			trace('Loading Template: ' + url);
			
			var htmlTemplate:HTMLTemplateMetaVO = new HTMLTemplateMetaVO();
			htmlTemplate.filename = filename;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				loader.removeEventListener(Event.COMPLETE, arguments.callee);
				htmlTemplate.parseHTML(loader.data);
			});
			
			loader.load(new URLRequest(url));
			return htmlTemplate;
		}
		
		public function get config():ConfigVO{
			return data as ConfigVO;
		}
		
		public function set config(vo:ConfigVO):void{
			data  = vo;
		}
		
		private function typeConvertLocations(locs:Array):void{
			
			var sessionProxy:SessionProxy = facade.retrieveProxy(SessionProxy.NAME) as SessionProxy;
			
			locations.removeAll();
			
			var entriesToProcess:Array = new Array();
			
			for each(var loc:Object in locs){
				
				var location:LocationVO = new LocationVO();
				// we assume loaded coordinates are ok
				location.geoStatus = new GeoStatusVO(GeoStatusVO.CODE_OK);
				// and set country to germany (if no country is set)
				location.country = 'DE';

				ObjectUtil.copyProperties(loc, location);

				if(loc.geoStatus) {
					location.geoStatus.possibilities = new Array();
					for each(var placemarkObj:Object in loc.geoStatus.possibilities) {
						var placemark:PlacemarkVO = new PlacemarkVO();
						ObjectUtil.copyProperties(placemarkObj, placemark);
						location.geoStatus.possibilities.push(placemark);
					} 
				} 
				
				locations.addItem(location);
			}
			
			config.locations = locations.source;
			sendNotification(Messages.CONFIG_UPDATED, config);
		}
		
		public function loadConfig(obj:Object):void{
			var sessionProxy:SessionProxy = facade.retrieveProxy(SessionProxy.NAME) as SessionProxy;
			var user:UserVO = sessionProxy.user;
			var widgetUrl:String = user.folder + '/' + EnvironmentProxy.ENVIRONMENT_TEST;
			
			// as the config is delivered as JSON, it must be converted to a ConfigVO type
			var configObj:ConfigVO = new ConfigVO();
			ObjectUtil.copyProperties(obj, configObj);
			this.config = configObj;

			// do type conversion of locations
			typeConvertLocations(obj.locations);
			// type conversion icons and generate map of icons for lookup by icon id			
			var objIcons:Array = obj.icons;
			config.icons = new Array();
			var icons:Object = { };
			
			for(var i:int = 0; i< objIcons.length; i++)
			{
				var iconVO:IconVO = new IconVO();
				ObjectUtil.copyProperties(objIcons[i], iconVO);
				loadBitmap(iconVO, widgetUrl + '/' + objIcons[i].image);
				icons[iconVO.id] = iconVO;
				config.icons.push(iconVO);
			}
			
			// set transient icon object for each location (for faster lookup)
			for each(var locationVO:LocationVO in config.locations)
			{
				if(locationVO.icon != null &&
					// if metadata was removed 
					icons[locationVO.icon] != undefined)
				{
					locationVO.iconVO = icons[locationVO.icon];
				}
			}
			
			// type conversion images and generate map of images for lookup by image id		
			var images:Object = { };
			var objImages:Array = obj.images;
			config.images = new Array();
			
			if(objImages) {
				for(i=0; i<objImages.length; i++)
				{
					var imageVO:ImageVO = new ImageVO();
					ObjectUtil.copyProperties(objImages[i], imageVO);
					loadImageBitmap(imageVO, widgetUrl + '/' + objImages[i].image);
					images[imageVO.id] = imageVO;
					config.images.push(imageVO);
				}
				
				// set transient image object for each location (for faster lookup)
				for each(locationVO in config.locations)
				{
					if(locationVO.image != null &&
						// if metadata was removed
						images[locationVO.image] != undefined)
					{
						locationVO.imageVO = images[locationVO.image];
					}
				}
			}
			
			// load position icon from the server
			loadBitmap(config.positionIcon, widgetUrl + '/' + config.positionIcon.image);

			var templates:Object = {};
			config.infotemplates = new Array();
			
			if(obj.infotemplates) {
				for(i=0; i< obj.infotemplates.length; i++)
				{
					var templateFilename:String = obj.infotemplates[i].filename;
					var templateVO:HTMLTemplateMetaVO = loadHtmlTemplate(templateFilename);
					templates[templateFilename] = templateVO;
					config.infotemplates.push(templateVO);
				}
				
				for each(locationVO in config.locations)
				{
					if(locationVO.templates != null && locationVO.templates.length > 0)
					{
						locationVO.infoWindowTemplateVOs = new Array();
						for(i=0; i<locationVO.templates.length; i++) {
							var templateFilename:String = String( locationVO.templates[i] );
							locationVO.infoWindowTemplateVOs.push(templates[templateFilename]);
						}
					}
				}
			} else {
				// no templates defined in json (old format) - parse all used templates and add default templates
				for each(locationVO in config.locations)
				{
					if(locationVO.templates != null && locationVO.templates.length > 0)
					{
						locationVO.infoWindowTemplateVOs = new Array();
						for(i=0; i<locationVO.templates.length; i++) {
							var templateFilename:String = String( locationVO.templates[i] );
							if(!templates[templateFilename]) {
								var templateVO:HTMLTemplateMetaVO = loadHtmlTemplate(templateFilename);
								templates[templateFilename] = templateVO;
								config.infotemplates.push(templateVO);
							}
							locationVO.infoWindowTemplateVOs.push(templates[templateFilename]);
						}
					}
				}
				loadDefaultTemplates(false);
				ExternalInterface.call("alert", FxGettext.gettext("As part of our latest update we have simplified the template handling of GEOwidget.\\nNow you can choose from a selection of predefined templates for your infowindow.\\nFor your existing locations your old templates are used. Please check the templates of your locations."));
			}
			setTemplatesPreview(); 

			sendNotification(Messages.CONFIG_LOADED);
		}
		
		public function removeRow(item:LocationVO):void {
			
			// remove from model
			var index:int = locations.getItemIndex(item);
			locations.removeItemAt(index);
			config.locations = locations.source;
			sendNotification(Messages.CONFIG_UPDATED, config);
		}
		
		/**
		 * add empty row - location
		 */ 
		public function addLocation(location:LocationVO):void{
			locations.addItem(location);
			
			config.locations = locations.source;
			sendNotification(Messages.CONFIG_UPDATED,config);
		}
		
		/**
		 * send initial data to all actors, ensure to call this last in the 
		 * initializing process
		 */
		public function initData():void{
			locations = new ArrayCollection();
			data = new ConfigVO();
			
			sendNotification(Messages.CONFIG_UPDATED, this.config);
			sendNotification(Messages.INIT_DATA);
		}
		
		private function loadBitmap(icon:IconVO, url:String):void {
			trace('Loading Bitmap: ' + url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void  {
				icon.bitmap = (Bitmap(e.target.content));
			});
			loader.load(new URLRequest(url));
		}
		
		private function loadImageBitmap(image:ImageVO, url:String):void {
			trace('Loading Image: ' + url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void  {
				image.bitmap = (Bitmap(e.target.content));
			});
			loader.load(new URLRequest(url));
		}
		
	}
}