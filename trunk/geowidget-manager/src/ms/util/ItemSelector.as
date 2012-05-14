/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package ms.util
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import gnu.as3.gettext.FxGettext;
	import gnu.as3.gettext._FxGettext;
	
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.core.Application;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	public class ItemSelector extends VBox
	{
		private var _header:String;
		private var _items:Array;
		private var _callback:Function;
		private var _labelFunction:Function;
		
		private var _label:Label;
		private var _itemList:List;
		private var _close:Button = new Button();
		[Bindable]
		private var fx:_FxGettext = FxGettext;
		
		public function ItemSelector(header:String, items:Array, callback:Function, labelFunction:Function)
		{
			super();
			_header = header;
			_items = items;
			_callback = callback;
			_labelFunction = labelFunction;
		}
		
		public static function selectItem(header:String, items:Array, callback:Function, labelFunction:Function=null, parent:DisplayObject=null):void
		 {
			var selector:ItemSelector = new ItemSelector(header, items, callback, labelFunction);
		 	if(parent==null) {
				PopUpManager.addPopUp(selector, Application.application as DisplayObject, true);	
				PopUpManager.centerPopUp(selector);
			} else
				PopUpManager.addPopUp(selector, parent, true);	
		}
		
		protected override function createChildren():void {
			super.createChildren();
			_label = new Label();
			_label.text = _header;
			_label.styleName = "header";
			addChild(_label);
			_itemList = new List();
			_itemList.dataProvider = _items;
			_itemList.styleName = "items";
			
				
			
			if(_labelFunction!=null)
				_itemList.labelFunction = _labelFunction;
			var that:ItemSelector = this;
			_itemList.addEventListener(ListEvent.CHANGE, function(event:ListEvent):void {
				_callback(_itemList.selectedItem);
				PopUpManager.removePopUp(that);
			});
			addChild(_itemList);

			_close.label = fx.gettext("Close");
			_close.labelPlacement = "center";
			_close.addEventListener(MouseEvent.CLICK, close);
			
			addChild(_close);
			
			var footer:Label = new Label();
			footer.styleName = "footer";
			footer.text = fx.gettext("(Please use mouse to select an item, ESC for cancel)");
			addChild(footer);
			
			addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent):void {
				if(event.keyCode==Keyboard.ESCAPE)
					close(null);
			});
			
			stage.focus = this;
		}
		
		/********************************************************
		 * Method for closing popup
		 * @value e <MouseEvent>
		 */
		private function close(e:MouseEvent):void{
			PopUpManager.removePopUp(this);
		}
		
		
		
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			_itemList.width = _label.width;
			_itemList.height = _itemList.measureHeightOfItems();
			_close.width = _label.width;
			
		}

	}
}