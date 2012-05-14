/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.model.vo
{
	import de.geowidget.manager.utils.EffectUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import com.adobe.images.PNGEncoder;
	
	[Bindable]
	[RemoteClass(alias="vo.ImageVO")]
	public class ImageVO extends EventDispatcher
	{

		public function ImageVO(id:String=null, bitmap:Bitmap=null)
		{
			this.bitmap = bitmap;
			this.id = id;
		}

		[Transient]
		public var bitmap:Bitmap;
		
		public var id:String;
		
		public function get height():Number {
			return bitmap.height; // + EffectUtil.ROLLOVER_HEIGTH;
		}
		public function get width():Number {
			return bitmap.width; // + EffectUtil.ROLLOVER_WIDTH;
		}
		
		public function get image():String {
			return "images/" + id + ".png";
		}
		
		public function createServerImage():Array {
			var image:BitmapData = bitmap.bitmapData;//EffectUtil.enlargeImage(bitmap.bitmapData, EffectUtil.ROLLOVER_WIDTH, EffectUtil.ROLLOVER_HEIGTH);
			// each server icon consists of a pair (filename, encoded PNG)
			var images:Array = [
				[this.image, PNGEncoder.encode(image)] ];

			return images;
		}
		
	}
}