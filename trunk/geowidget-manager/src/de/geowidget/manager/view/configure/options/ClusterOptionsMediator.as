/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.view.configure.options
{
	import de.geowidget.manager.controller.Messages;
	import de.geowidget.manager.model.vo.ConfigVO;
	import de.geowidget.manager.utils.ColorUtil;
	import de.geowidget.manager.utils.FileUtil;
	import de.geowidget.manager.view.configure.components.options.ClusterOptions;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ClusterOptionsMediator extends Mediator
	{
		public static const NAME:String = "ClusterOptionsMediator";

		public function ClusterOptionsMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);

			component.gridSize.addEventListener(FlexEvent.VALUE_COMMIT, handleGridSize);
			component.fontSize.addEventListener(FlexEvent.VALUE_COMMIT, handleFontSize);
			component.fontColorPicker.addEventListener(Event.CHANGE, handleFontColor);
			component.clusterIcon.addEventListener(MouseEvent.CLICK, handleIconClick);
		}
		
		public function get component():ClusterOptions {
			return viewComponent as ClusterOptions;
		}
		
		private function handleIconClick(e:Event):void{
			FileUtil.loadIcon(function(bitmap:Bitmap):void {
				component.cluster.bitmap = bitmap;
				sendNotification(Messages.UPDATE_CLUSTER, component.cluster);
			});
		}
		
		private function handleFontColor(e:Event):void {
			component.cluster.color = ColorUtil.convertColor(component.fontColorPicker.selectedColor);
			sendNotification(Messages.UPDATE_CLUSTER, component.cluster);
		}

		private function handleFontSize(e:Event):void {
			component.cluster.fontSize = component.fontSize.value;
			sendNotification(Messages.UPDATE_CLUSTER, component.cluster);
		}		

		private function handleGridSize(e:Event):void {
			component.cluster.gridSize = component.gridSize.value;
			sendNotification(Messages.UPDATE_CLUSTER, component.cluster);
		}		
		
		override public function listNotificationInterests() : Array{
			return [Messages.CONFIG_UPDATED];
		}
		
		override public function handleNotification(notification:INotification) : void{
			switch(notification.getName()){
				case Messages.CONFIG_UPDATED:
					component.cluster = (notification.getBody() as ConfigVO).clusters[0];
					break;
			}
		}
	}
}