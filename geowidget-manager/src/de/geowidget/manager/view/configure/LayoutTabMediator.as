/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.view.configure
{
	import de.geowidget.manager.controller.Messages;
	import de.geowidget.manager.model.vo.ConfigVO;
	import de.geowidget.manager.utils.ColorUtil;
	import de.geowidget.manager.utils.FileUtil;
	import de.geowidget.manager.view.configure.components.LayoutTab;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gnu.as3.gettext.FxGettext;
	
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class LayoutTabMediator extends Mediator
	{
		public static const NAME:String = "LayoutTabMediator";
		
		private const mapTypes:Array = new Array(
			{label:FxGettext.gettext("Normal"), data:"NORMAL_MAP_TYPE"}, 
			{label:FxGettext.gettext("Physical"), data:"PHYSICAL_MAP_TYPE"}, 
			{label:FxGettext.gettext("Satellite"), data:"SATELLITE_MAP_TYPE"}, 
			{label:FxGettext.gettext("Hybrid"), data:"HYBRID_MAP_TYPE"},
			{label:FxGettext.gettext("OpenStreetMap"), data:"OSM_MAP_TYPE"});
		
		public function LayoutTabMediator(data:Object = null)
		{
			super(NAME,data);
			tab.positionIconSelector.addEventListener(MouseEvent.CLICK, handlePositionIconClick);
			tab.mapType.addEventListener(ListEvent.CHANGE, handleMapType);
			tab.borderSize.addEventListener(FlexEvent.VALUE_COMMIT, handleBorderSize);
			tab.borderColorPicker.addEventListener(FlexEvent.VALUE_COMMIT, handleBorderColor);
			tab.mapType.dataProvider = mapTypes;
			tab.sizeSelector.addEventListener("sizeChanged", handleSizeChanged);
			tab.showZoom.addEventListener(FlexEvent.VALUE_COMMIT, handleZoom);
			tab.showMapTypes.addEventListener(FlexEvent.VALUE_COMMIT, handleMapTypes);
			tab.showOverview.addEventListener(FlexEvent.VALUE_COMMIT, handleOverview);
		}
		
		public function get tab():LayoutTab{
			return viewComponent as LayoutTab;
		}

		private function handleZoom(e:Event):void {
			tab.config.features.showZoom = tab.showZoom.selected;
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		};
		
		private function handleMapTypes(e:Event):void {
			tab.config.features.showMapTypes = tab.showMapTypes.selected;
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		}
		
		private function handleOverview(e:Event):void {
			tab.config.features.showOverview = tab.showOverview.selected;
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		}
			
		private function handlePositionIconClick(e:Event):void{
			FileUtil.loadIcon(function(bitmap:Bitmap):void {
				tab.config.positionIcon.bitmap = bitmap;
				sendNotification(Messages.CONFIG_UPDATED, tab.config);
			});
		}
		
		private function handleSizeChanged(e:Event):void {
			tab.config.widgetWidth = tab.sizeSelector.widgetWidth;
			tab.config.widgetHeight = tab.sizeSelector.widgetHeight
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		}
		
		private function handleBorderColor(e:Event):void {
			tab.config.layout.border.color = ColorUtil.convertColor(tab.borderColorPicker.selectedColor);
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		}
		
		private function handleBorderSize(e:Event):void {
			tab.config.layout.border.size = tab.borderSize.value;
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		}
				
		private function handleMapType(e:Event):void {
			tab.config.layout.mapType = tab.mapType.selectedItem.data;
			sendNotification(Messages.CONFIG_UPDATED, tab.config);
		}
		
		override public function listNotificationInterests() : Array{
			return [Messages.CONFIG_UPDATED, Messages.INIT_DATA, Messages.CONFIG_LOADED];
		}
		
		override public function handleNotification(notification:INotification) : void{
			switch(notification.getName()){
				case Messages.CONFIG_UPDATED:
					tab.config = notification.getBody() as ConfigVO;
					var itemsToSelect:Array = mapTypes.filter(function(item:Object, index:int, a:Array):Boolean {
						if(tab.config.layout) {
							return item.data == tab.config.layout.mapType;
						} else {
							return false;
						}
					});
					if(itemsToSelect.length==1) {
						tab.mapType.selectedItem = itemsToSelect[0];
					}
				break;
				case Messages.INIT_DATA, Messages.CONFIG_LOADED:
					tab.sizeSelector.setValues(tab.config.widgetWidth, tab.config.widgetHeight);
					//	tab.sizeSelector.updatePresetValue();
					break;
			}
		}
		
	}
}