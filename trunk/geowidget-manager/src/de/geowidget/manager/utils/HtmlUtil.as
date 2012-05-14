/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.utils
{
	public class HtmlUtil
	{
		public function HtmlUtil()
		{
		}
		
		private static function getRegExValue(result:Object):String {
			if(result is Array && (result as Array).length>=2) {
				return (result as Array)[1];
			} else
				return null;
		}
		
		private static function createTagRE(tag:String, className:String):RegExp {
			return new RegExp("<" + tag + "[^>]+class[^>]*=[^>]*'[^>]*" + className + "[^>]*'[^>]*>(.*?)<\/[^>]*" + tag + "[^>]*>", "i");
		}
		
		private static function createTagQuoteRE(tag:String, className:String):RegExp {
			return new RegExp("<" + tag + '[^>]+class[^>]*=[^>]*"[^>]*' + className + '[^>]*"[^>]*>(.*?)<\/[^>]*' + tag + "[^>]*>", "i");
		}
		
		public static function getTag(tag:String, className:String, html:String):String {
			// check html with ' as attribute delimiter
			var result:String = getRegExValue(createTagRE(tag, className).exec(html));
			if(result) {
				return result;
			} else {
				// check html with " as attribute delimiter
				return getRegExValue(createTagQuoteRE(tag, className).exec(html));
			}
		}
		
		public static function removeTag(tag:String, className:String, html:String):String {
			return html.replace(createTagRE(tag, className), "").replace(createTagQuoteRE(tag, className), "");
		}
	}
}