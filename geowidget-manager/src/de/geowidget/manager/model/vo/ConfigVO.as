/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.model.vo
{
	
	import de.geowidget.manager.model.vo.IconVO;

	/**
	 * comment here
	 */ 
	[Bindable]
	public class ConfigVO
	{
		
		[Embed(source='/assets/logo/logo.png')]
		private const logo1Class:Class;
		[Embed(source='/assets/logo/hqLogo.png')]
		private const logo2Class:Class;
		[Embed(source='/assets/logo/cluster.png')]
		private const logo3Class:Class;
		
		
		
		[Embed(source='/assets/logo/position.png')]
		private const visitorIconClass:Class;
		[Embed(source='/assets/logo/cluster.png')]
		private const clusterIconClass:Class;
		
		public var locale:String;
		public var name:String="";
		public var templates:BodyTemplatesVO = new BodyTemplatesVO();
		public var layout:LayoutVO = new LayoutVO();
		public var features:FeaturesVO = new FeaturesVO();
		public var bgColor:String = "#ffffff";
		public var widgetWidth:int = 400;
		public var widgetHeight:int = 400;
		public var positionIcon:IconVO = new IconVO("visitor",new visitorIconClass());
		public var locations:Array = new Array(); //for serialization
		public var icons:Array = new Array();		//for serialization
		public var images:Array = new Array(); 		// list of all images (Array of ImageVO)
		public var infotemplates:Array = new Array(); 		// list of all available templates (Array of HTMLTemplateVO)
		public var infoText:String;
		
		public var clusters:Array;  // right now there is only one instance of ClusterVO stored in this array
		
		public function ConfigVO()
		{
			
			icons = new Array();
			icons.push(new IconVO('icon_0', new logo1Class()));
			icons.push(new IconVO('icon_1', new logo2Class()));
			icons.push(new IconVO('icon_2', new logo3Class()));
			
			
			clusters = new Array();
			clusters.push(new ClusterVO("clustered", new clusterIconClass()));
			
		}		

	}
}