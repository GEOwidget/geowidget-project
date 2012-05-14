/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package ms.util
{
	public class CSVUtil
	{
		public function CSVUtil()
		{
		}
		
		public static function CSV2JSON(csv:String, keys:Array, trimmer:Function=null, delimiter:* = ",", textDelimiter:* = '"'):Object {
			var result:Object = {}
			var values:Array = ms.util.StringUtil.textSplit(csv, delimiter, textDelimiter);
			for(var i:int=0; i<values.length; i++) {
				var key:String = keys[i];
				var value:String = values[i];
				if(trimmer!=null) {
					value = trimmer(value);
				}
				result[key] = value;
			}
			return result;
		}		
			
		public static function CSVs2JSON(csvs:Array, keys:Array, delimiter:* = ",", textDelimiter:* = '"'):Array {
			var result:Array = new Array();
			for each(var csv:String in csvs) {
				var json:Object = CSVUtil.CSV2JSON(csv, keys, null, delimiter, textDelimiter);
				result.push(json);
			}				
			return result;
		}

		public static function CSVs2JSONHeaderAsKeys(csvs:Array, trimmer:Function=null, delimiter:* = ",", textDelimiter:* = '"'):Object {
			var result:Array = new Array();
			var keys:Array = StringUtil.textSplit(csvs[0], delimiter, textDelimiter);
			for(var i:int=1; i<csvs.length; i++) {
				var csv:String = csvs[i];
				var json:Object = CSVUtil.CSV2JSON(csv, keys, trimmer, delimiter, textDelimiter);
				result.push(json);
			}				
			return {
				keys: keys,
				result: result
			};
		}

	}
}