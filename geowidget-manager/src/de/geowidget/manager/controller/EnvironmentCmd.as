/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 package de.geowidget.manager.controller
{
	import de.geowidget.manager.model.CommitProxy;
	import de.geowidget.manager.model.EnvironmentProxy;
	import de.geowidget.manager.model.FileProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class EnvironmentCmd extends SimpleCommand
	{
		
		override public function execute(notification:INotification) : void
		{
			var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
			var envProxy:EnvironmentProxy = facade.retrieveProxy(EnvironmentProxy.NAME) as EnvironmentProxy;
			var commitProxy:CommitProxy = facade.retrieveProxy(CommitProxy.NAME) as CommitProxy;
			switch(notification.getName()){
				case Messages.PREVIEW_REQUEST:
					envProxy.preview(fileProxy.config);
				break;
				case Messages.COMMIT_REQUEST:
					commitProxy.commit(fileProxy.config, notification.getBody() as String);
				break;
				case Messages.LOAD_WIDGET:
					envProxy.load();
				break;
				case Messages.SAVE_WIDGET:
					envProxy.save(fileProxy.config);
				break;
				case Messages.REMOVE_WIDGET:
					envProxy.remove();
				break;
			}
		}
		
	}
}