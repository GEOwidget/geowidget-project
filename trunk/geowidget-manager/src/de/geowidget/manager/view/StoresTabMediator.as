/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.view
{
	
	import de.geowidget.manager.controller.Messages;
	import de.geowidget.manager.itemrenderer.CountryDataGridItemRenderer;
	import de.geowidget.manager.itemrenderer.TextDataGridItemRenderer;
	import de.geowidget.manager.model.FileProxy;
	import de.geowidget.manager.model.SessionProxy;
	import de.geowidget.manager.model.vo.LocationVO;
	import de.geowidget.manager.view.components.StoresTab;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gnu.as3.gettext.FxGettext;
	import gnu.as3.gettext._FxGettext;
	
	import ms.controls.DeleteItemDataGridRenderer;
	import ms.util.ItemRendererHelper;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class StoresTabMediator extends Mediator
	{
		public static const NAME:String = "StoreTabMediator";
		
		private var _editedCellValue:Object;

		[Bindable]
		private var fx:_FxGettext = FxGettext;
		
		private var _sessionProxy:SessionProxy;
		private var _fileProxy:FileProxy;
		
		private var scrollToLastItem:Boolean = false;
		
		public function StoresTabMediator( viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			//init();
		}
		
		public function get tab():StoresTab
		{
			return viewComponent as StoresTab;
		}
		
		override public function listNotificationInterests() : Array
		{
			return [Messages.CONFIG_UPDATED];
		}
		
		//protected function init():void
		override public function onRegister():void
		{
			
			_sessionProxy = facade.retrieveProxy(SessionProxy.NAME) as SessionProxy;
			_fileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
			
			tab.addEventListener(FlexEvent.UPDATE_COMPLETE, function(event:FlexEvent):void {
				updateDataGridHeight();
			});
			
			tab.addRowBtn.addEventListener(MouseEvent.CLICK, addRow);
			tab.dataGrid.addEventListener(FlexEvent.UPDATE_COMPLETE, handleDataGridUpdateComplete);
			tab.deleteColumn.itemRenderer = ItemRendererHelper.createRendererWithProperties(DeleteItemDataGridRenderer, {editCallback: handleRowEdit, deleteCallback: handleRowDelete});
			tab.countryColumn.itemRenderer = ItemRendererHelper.createRendererWithProperties(CountryDataGridItemRenderer, {sessionProxy: _sessionProxy});
			
			tab.cityColumn.itemRenderer = ItemRendererHelper.createRendererWithProperties(TextDataGridItemRenderer, {dataField: 'city' });
			tab.postalCodeColumn.itemRenderer = ItemRendererHelper.createRendererWithProperties(TextDataGridItemRenderer, {dataField: 'postalCode' });
			tab.streetColumn.itemRenderer = ItemRendererHelper.createRendererWithProperties(TextDataGridItemRenderer, {dataField: 'street' });
			
			tab.dataGrid.addEventListener(MouseEvent.DOUBLE_CLICK, handleDoubleClick);
			
			BindingUtils.bindProperty(tab, 'locations', _fileProxy, 'locations');
			updateDataGridHeight();
			
		}
		
		override public function handleNotification(notification:INotification) : void{
			switch(notification.getName()){
				case Messages.CONFIG_UPDATED:
					
					updateDataGridHeight();
					
				break;
			}
		}
		
		private function updateDataGridHeight():void {
			
			var locationsLength:Number = _fileProxy.locations.length;
			
			var dgHeaderHeight:Number = tab.dataGrid.headerHeight + 5;
			
			var dataGridHeight:Number = dgHeaderHeight + tab.dataGrid.rowHeight * locationsLength;
			
			
			var dataGridMaxHeight:Number = tab.dataGridContainer.height - tab.dataGridControls.height;
			
			if(dataGridMaxHeight < dgHeaderHeight)
			{
				dataGridMaxHeight = dgHeaderHeight;
			}
			
			if(dataGridHeight < dataGridMaxHeight)
			{
				tab.dataGrid.height = dataGridHeight;
			}
			else
			{
				tab.dataGrid.height = dataGridMaxHeight;
			}
			
			tab.dataGridControls.y = tab.dataGrid.height;
			
		}
		
		private function handleRowEdit(location:Object):void {
			sendNotification(Messages.EDIT_LOCATION, location);
		}

		private function handleRowDelete(location:Object):void {
			sendNotification(Messages.DELETE_LOCATION, location);
		}
		
		private function handleCountryChange(location:LocationVO):void {
			sendNotification(Messages.UPDATE_LOCATION, location);
		}
		
		private function handleLocationChange(location:LocationVO):void {
			sendNotification(Messages.UPDATE_LOCATION, location);
		}
		
		private function handleDoubleClick(e:Event):void{
			sendNotification(Messages.EDIT_LOCATION, tab.dataGrid.selectedItem as LocationVO);
		}

		private function addRow(e:Event):void{
			scrollToLastItem = true;
			sendNotification(Messages.ADD_LOCATION);
		}
		
		private function handleDataGridUpdateComplete(e:FlexEvent):void
		{
			if(scrollToLastItem)
			{
				if(tab.dataGrid.dataProvider != null)
				{
					var currLen:uint = tab.dataGrid.dataProvider.length - 1;
	                tab.dataGrid.scrollToIndex(currLen);
	   			}
				
				scrollToLastItem = false;
			}
		}
				
	}
}