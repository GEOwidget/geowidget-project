/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 package de.geowidget.manager.controller
{
	import de.geowidget.manager.ServiceLocator;
	import de.geowidget.manager.model.CommitProxy;
	import de.geowidget.manager.model.EnvironmentProxy;
	import de.geowidget.manager.model.FileProxy;
	import de.geowidget.manager.model.SessionProxy;
	import de.geowidget.manager.view.AppBarMediator;
	import de.geowidget.manager.view.WelcomeMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartCmd extends SimpleCommand
	{
		override public function execute(notification:INotification) : void{
			var app:geowidget = notification.getBody() as geowidget;
			
			var sessionProxy:SessionProxy = new SessionProxy();
			//this will be replaced later by DI
			sessionProxy.sessionService = ServiceLocator.getInstance().getSessionService();
			facade.registerProxy(sessionProxy);
			sessionProxy.getUser();
			sessionProxy.getCountryList();
			
			var envProxy:EnvironmentProxy = new EnvironmentProxy();
			envProxy.widgetService = ServiceLocator.getInstance().getWidgetService();
			envProxy.commitService = ServiceLocator.getInstance().getCommitService();
			facade.registerProxy(envProxy);
			
			var fileProxy:FileProxy = new FileProxy();
			facade.registerProxy(fileProxy);
			fileProxy.initData();
			
			var commitProxy:CommitProxy = new CommitProxy();
			commitProxy.commitService = ServiceLocator.getInstance().getCommitService();
			facade.registerProxy(commitProxy);
			
			facade.registerMediator(new AppBarMediator(app.appBar));
			facade.registerMediator(new WelcomeMediator(app.welcomeContainer));
			
		}
	}
}