/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
 package de.geowidget.manager.model.vo.metadata
{
	import de.geowidget.manager.utils.HtmlUtil;
	
	import flash.display.Bitmap;

	[Bindable]
	[RemoteClass(alias="vo.metadata.HTMLTemplateMetaVO")]
	public class HTMLTemplateMetaVO
	{
		public function HTMLTemplateMetaVO(filename:String=null)
		{
			this.filename = filename;
		}
		
		[Transient]
		public var html:String; 

		public var filename:String;

		[Transient]
		public var label:String;

		[Transient]
		public var previewBitmap:Bitmap; 
		
		[Transient]
		public function get isSaved():Boolean {
			return filename!=null;
		}
		
		public function parseHTML(html:String):void {
			// retrieve title tag
			this.label = HtmlUtil.getTag('span', 'title', html);
			// remove title tag
			this.html = HtmlUtil.removeTag('span', 'title', html);
			// remove infowindow wrapper
			this.html = this.html.replace(/<div class="infowindow">[\r\n\s\t]*/, '');
			this.html = this.html.replace(/[\r\n\s\t]*<\/div>$/, '');
		}
		
		public function createServerTemplate():Array {
			return [[filename, label, html]];
		}
		
	}
}