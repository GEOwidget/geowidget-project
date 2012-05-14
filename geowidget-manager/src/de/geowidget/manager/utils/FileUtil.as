/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.utils
{
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import gnu.as3.gettext.FxGettext;
	
	import ms.util.DisplayHelper;
	
	import mx.controls.Alert;

	public class FileUtil
	{
		public function FileUtil()
		{
		}
		
		public static const FILETYPE_TEXT:int = 0;
		public static const FILETYPE_IMAGE:int = 1;
		
		public static const IMAGES_FILE_FILTER:FileFilter = new FileFilter(FxGettext.gettext("Image file (*.png,*.gif,*.jpeg,*.jpg)"), "*.png;*.gif;*.jpeg;*.jpg");
		
		public static var uploadPoint:URLRequest = new URLRequest("/amf/upload.php");
		
		public static function loadIcon(callback:Function):void {
			browseAndLoadFile(function(bitmap:Bitmap):void {
				if(bitmap.width<=128 && bitmap.height<=128)	
					callback(bitmap);		
				else
					Alert.show(FxGettext.gettext("Please select a smaller logo. The size of the logo must not exceed 128x128 pixels."));
			}, [IMAGES_FILE_FILTER], FILETYPE_IMAGE);
		}
		
		public static function loadImage(callback:Function):void {
			browseAndLoadFile(function(bitmap:Bitmap):void {
				if(bitmap.width<=2048 && bitmap.height<=2048)
					callback(bitmap);		
				else
					Alert.show(FxGettext.gettext("Please select a smaller image. The size of the logo must not exceed 500x500 pixels."));
			}, [IMAGES_FILE_FILTER], FILETYPE_IMAGE);
		}
		
		public static function browseAndLoadFile(callback:Function, typeFilter:Array=null, fileType:int=FILETYPE_TEXT):void {
			var file:FileReference = new FileReference();
			file.addEventListener(Event.SELECT, function(event:Event):void {
				file.removeEventListener(Event.SELECT, arguments.callee);
				DisplayHelper.trackProgress(FxGettext.gettext("loading"), file);
				loadFile(callback, file, fileType);
			});
			file.browse(typeFilter);	
		}
		
		public static function loadFile(callback:Function, file:FileReference, fileType:int=FILETYPE_TEXT):void {
			file.addEventListener(IOErrorEvent.IO_ERROR, ErrorHandler.getIOErrorHandler());
			file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(e:DataEvent):void {
				file.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, arguments.callee);
				var status:XML = XML(e.data);
				if(Number(status.@code) == 0){
					var urlReq:URLRequest = new URLRequest(status.@message.toString());
					switch(fileType) {
						case FILETYPE_IMAGE:
							var loader:Loader = new Loader();
							loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
								loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
								callback(loader.content as Bitmap);
							});
							loader.load(urlReq);
							break;
						case FILETYPE_TEXT:
							var urlloader:URLLoader = new URLLoader();
							urlloader.addEventListener(Event.COMPLETE, function(e:Event):void {
								urlloader.removeEventListener(Event.COMPLETE, arguments.callee);
								callback(urlloader.data as String);		
							});
							urlloader.load(urlReq);
							break;
					}
					trace('file uploaded');
				}else{
					Alert.show(FxGettext.gettext("Your file load failed as the following error occured: ") + status.@message, FxGettext.gettext("Error"));
				}
			});
			
			file.upload(uploadPoint);
		}
		
	}
}