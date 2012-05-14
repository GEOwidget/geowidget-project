/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package ms.util
{
	import mx.utils.StringUtil;
	
	public class StringUtil
	{
		public static function isEmpty(s:String):Boolean {
			return s==null || mx.utils.StringUtil.trim(s).length==0;	
		}

		public static function areEqual(a:String, b:String):Boolean {
			return (mx.utils.StringUtil.trim(a) == mx.utils.StringUtil.trim(b));	
		}

		public static function areEqualCaseInsensitive(a:String, b:String):Boolean {
			return (mx.utils.StringUtil.trim(a).toLocaleLowerCase() == mx.utils.StringUtil.trim(b).toLocaleLowerCase());	
		}

		private static function substituteTextDelimiter(value:String, textDelimiter:*):String {
			if(value.charAt(0)==textDelimiter && value.charAt(value.length-1)==textDelimiter) {
				var valueWithOutDelimiters:String = value.substr(1, value.length-2);
				var returnValue:String = valueWithOutDelimiters.replace(textDelimiter+textDelimiter, textDelimiter);
				return returnValue;
			} else {
				return value;
			}
		}
		
		private static function removeDelimiter(value:String, delimiter:*):String {
			if(value.charAt(value.length-1)==delimiter)
				return value.substr(0, value.length-1);
			else
				return value;
		}		
		
		public static function textSplit(str:String, delimiter:* = ",", textDelimiter:* = '"'):Array {
			var regex:String = '"([^"]|"{2,})*"(;|$)|[^;]*(;|$)';
			regex.replace('"', textDelimiter);
			regex.replace(';', delimiter);
			var values:Array = str.match(new RegExp(regex, "g"));
			for(var i:int=0; i<values.length; i++) {
				values[i] = removeDelimiter(values[i], delimiter);
				values[i] = substituteTextDelimiter(values[i], textDelimiter);
			}
			return values;
		}
		
		
		public static function template(str:String, obj:Object):String
		{
			if (str == null) return '';
			
			for(var key:String in obj) {
				str = str.replace(new RegExp("\\{"+key+"\\}", "g"), obj[key]);
			}
			
			return str;
		}
	}
}