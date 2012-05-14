/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager
{
	import de.geowidget.manager.controller.EndCmd;
	import de.geowidget.manager.controller.EnvironmentCmd;
	import de.geowidget.manager.controller.FaultCmd;
	import de.geowidget.manager.controller.LocationDataCmd;
	import de.geowidget.manager.controller.Messages;
	import de.geowidget.manager.controller.ProcessDataCmd;
	import de.geowidget.manager.controller.RestartAppCmd;
	import de.geowidget.manager.controller.SessionCmd;
	import de.geowidget.manager.controller.StartCmd;
	
	import mx.core.Application;
	
	import org.puremvc.as3.multicore.patterns.facade.*;
	
	public class AppFacade extends  Facade
	{
		public static const NAME:String = 'de.geowidget.manager';
		private static var index:int = 1;
		
		public function AppFacade()
		{
			super(NAME + (index++).toString() );
		}
		
		public static const STARTUP:String = "app starts";
		public static const SHUTUP:String = "app shut up";
		
		public function init(app:Application):void{
			sendNotification(STARTUP,app);
		}		
		
		override protected function initializeController() : void{
			super.initializeController();
			registerCommand(SHUTUP, EndCmd);
			registerCommand(STARTUP, StartCmd);
			registerCommand(Messages.ADD_LOCATION, LocationDataCmd);
			registerCommand(Messages.LOAD_CONFIG, ProcessDataCmd);			
			registerCommand(Messages.LOAD_DEFAULT_TEMPLATES, ProcessDataCmd);
			registerCommand(Messages.PREVIEW_REQUEST, EnvironmentCmd);
			registerCommand(Messages.COMMIT_REQUEST, EnvironmentCmd);
			registerCommand(Messages.LOAD_WIDGET, EnvironmentCmd);
			registerCommand(Messages.SAVE_WIDGET, EnvironmentCmd);
			registerCommand(Messages.REMOVE_WIDGET, EnvironmentCmd);
			registerCommand(Messages.LOGOUT_REQUEST, SessionCmd);
			registerCommand(Messages.DELETE_LOCATION, LocationDataCmd);
			registerCommand(Messages.UPDATE_LOCATION, LocationDataCmd);
			registerCommand(Messages.UPDATE_CLUSTER, ProcessDataCmd);
			registerCommand(Messages.RESTART_APP, RestartAppCmd);
			registerCommand(Messages.FAULT_MESSAGE, FaultCmd);
			registerCommand(Messages.EDIT_LOCATION, LocationDataCmd);
			
		}
		
	}
}