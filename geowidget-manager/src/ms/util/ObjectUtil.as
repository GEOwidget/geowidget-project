/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package ms.util
{
	import mx.core.ClassFactory;

	public class ObjectUtil
	{
		public function ObjectUtil()
		{
		}

		public static function copyProperties(fromObject:Object, toObject:Object):void {
			for(var key:String in fromObject) {
				
				copyProperty(fromObject[key], toObject, key);
			}
		}
		
		private static function copyProperty(value:*, toObject:Object, key:*):void {
			try {			
				if ( value is String ) {
						toObject[key] = value;
				} else if ( value is Number ) {
					toObject[key] = value;
				} else if ( value is Boolean ) {
					toObject[key] = value;
				} else if ( value is Array ) {
					// call the helper method to convert an array
					for(var i:int=0; i<value.length; i++) {
						copyProperty(value[i], toObject[key], i);
					}
				} else if ( value is Object && value != null ) {
					copyProperties(value, toObject[key]);
				} else
	            	toObject[key] = null;	
		   }catch(e:Error) {
		   }
		}
		
		/**
		 * delete a dynamic property from an object
		 */ 
		public static function deleteProperty(object:Object,propertyName:String):void{
			try{
				if(object.hasOwnProperty(propertyName))
					delete object[propertyName];
			}catch(e:Error){
				trace(e.message);
			}
		}
		
		/**
		 * rename a dynamic property of an object
		 */
		public static function renameProperty(object:Object,oldProperty:String,newProperty:String):void{
			try{
				var oldValue:* = object[oldProperty];
				deleteProperty(object,oldProperty);
				object[newProperty] = oldValue;
			}catch(e:Error){
				trace(e.message);
			}	
		}
		
		public static function convertTypeInArray(inArray:Array, clazz:Class):Array {
			var cf:ClassFactory = new ClassFactory(clazz);
			var ret:Array = new Array();
			for each(var obj:Object in inArray){
				var newObj:* = cf.newInstance();
				ObjectUtil.copyProperties(obj, newObj);
				ret.push(newObj);
			}
			return ret;
		}
	}
}