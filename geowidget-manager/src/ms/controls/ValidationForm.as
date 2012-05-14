/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package ms.controls
{
	import com.adobe.utils.DictionaryUtil;
	
	import flash.utils.Dictionary;
	
	import ms.util.StringUtil;
	
	import mx.containers.Form;
	import mx.containers.FormItem;
	import mx.controls.TextArea;
	import mx.core.UIComponent;
	import mx.events.ValidationResultEvent;
	import mx.validators.Validator;

	public class ValidationForm extends Form
	{
		public function ValidationForm()
		{
			super();
		}

		private var _validators:Array = [];
		private var _validatorMessages:Dictionary = new Dictionary();
		
		public var errorTextHeight:int = 60;
		public var resetHeightAfterError:Boolean = true;

		private var _errors:TextArea;
		
		// after init we dont show an error, so the error text field must not be of any height
		private var _setErrorTextHeight:Boolean = false;
		
		override protected function createChildren():void {
			super.createChildren();
			_errors = new TextArea();
			_errors.styleName = 'errorText';
			_errors.visible = false;
			addChildAt(_errors, 0);
		}
		
		override protected function measure():void {
			_errors.measuredHeight = _setErrorTextHeight ? errorTextHeight : 0;
			super.measure();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			_errors.move(viewMetricsAndPadding.left, viewMetricsAndPadding.right);
			_errors.setActualSize(unscaledWidth - viewMetricsAndPadding.left - viewMetricsAndPadding.right, _setErrorTextHeight ? errorTextHeight : 0);
		}
		
		public function set validators(validators:Array):void {
			_validators = validators;
			for each(var validator:Validator in _validators) {
				validator.addEventListener(ValidationResultEvent.VALID, updateErrorText);
				validator.addEventListener(ValidationResultEvent.INVALID, updateErrorText);
			}
		}
		
		public function updateErrorText(event:ValidationResultEvent):void {
			_validatorMessages[event.currentTarget] = event;
			showErrorMessage(createErrorMessage(DictionaryUtil.getValues(_validatorMessages)));
		}

		public function isValid():Boolean {
			var validationsResultEvents:Array = Validator.validateAll(_validators);
			return validationsResultEvents.length==0;
		}
		
		public function showErrorMessage(msg:String):void {
			if(StringUtil.isEmpty(msg)) {
				_errors.visible = false;
				if(resetHeightAfterError) _setErrorTextHeight = false;
			} else {
				_setErrorTextHeight = true;
				_errors.visible = true;
				_errors.htmlText = msg;
			}
			invalidateSize();
			invalidateDisplayList();
		}
		
		private function createErrorMessage(validationsResultEvents:Array):String {
            var errors:Array = new Array();
            for each(var validationResultEvent:ValidationResultEvent in validationsResultEvents) {
            	if(validationResultEvent.type != ValidationResultEvent.VALID) {
            		var component:UIComponent = validationResultEvent.currentTarget.source;
	            	var formItem:FormItem = component.parent as FormItem;
	            	var label:String = null;
	            	if(formItem!=null)
	            		label = formItem.label;
	            	else if(component.name!=null)
            			label = component.name;
	            	if(label!=null)
	               		errors.push("<b>" + label + "</b> " + validationResultEvent.message);
	               	else {
	               		errors.push(validationResultEvent.message);
	               	}
             	}
            }
            return errors.join("<br/>");
		}

	}
}