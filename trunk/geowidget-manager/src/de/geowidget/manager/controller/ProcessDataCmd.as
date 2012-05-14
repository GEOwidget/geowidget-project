/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 package de.geowidget.manager.controller
{
	import de.geowidget.manager.model.FileProxy;
	import de.geowidget.manager.model.vo.ClusterVO;
	import de.geowidget.manager.model.vo.metadata.HTMLTemplateMetaVO;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ProcessDataCmd extends SimpleCommand
	{
		override public function execute(notification:INotification) : void{
			var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
			var template:HTMLTemplateMetaVO;
			switch(notification.getName()){
				case Messages.UPDATE_CLUSTER:
					fileProxy.config.clusters[0] = notification.getBody() as ClusterVO;
					sendNotification(Messages.CONFIG_UPDATED, fileProxy.config);
				break;
				case Messages.LOAD_CONFIG:
					fileProxy.loadConfig(notification.getBody());
				break;
				case Messages.LOAD_DEFAULT_TEMPLATES:
					fileProxy.loadDefaultTemplates();
				break;
			}
		}
	}
}