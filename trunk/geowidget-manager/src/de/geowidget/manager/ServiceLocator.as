/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager
{
	import mx.rpc.remoting.RemoteObject;
	
	public class ServiceLocator
	{
		private static var _instance:ServiceLocator;
	
		public function ServiceLocator()
		{
			
		}

		public static function getInstance():ServiceLocator {
			if(_instance==null) {
				_instance = new ServiceLocator();
			}
			return _instance;
		}
		
		public function getSessionService():RemoteObject {
			var userService:RemoteObject = new RemoteObject('FilialServer');
			userService.source = "SessionService";
    		userService.requestTimeout = 30;
			return userService;
		}

		public function getWidgetService():RemoteObject {
			var userService:RemoteObject = new RemoteObject('FilialServer');
			userService.source = "WidgetService";
    		userService.requestTimeout = 30;
			return userService;
		}
		
		public function getCommitService():RemoteObject {
			var userService:RemoteObject = new RemoteObject('FilialServer');
			userService.source = "CommitService";
			userService.requestTimeout = 30;
			return userService;
		}

	}
}