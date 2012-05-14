/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package ms.util
{
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	public class ItemRendererHelper
	{
		public function ItemRendererHelper()
		{
		}

		public static function createRendererWithProperties(renderer:Class, properties:Object = null):IFactory {
		  var factory:ClassFactory = new ClassFactory(renderer); 
		  factory.properties = properties;
		  return factory;
		}
		
		/**
		 * Creates a callback that removes items of the provided ArrayCollection
		 * @param model ArrayCollection that should be used as model
		 * @return Function that deletes an item from the model
		 */
		public static function createRemoveCallback(model:ArrayCollection):Function {
			return function(item:Object):void {
	     		// remove from model
				if(model != null){
	     			var index:int = model.getItemIndex(item);
	     			model.removeItemAt(index);
				}
	     	};
		}
	}
}