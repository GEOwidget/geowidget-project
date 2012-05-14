/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.model.vo
{
	
	import de.geowidget.manager.utils.GeoHelper;
	
	import ms.util.StringUtil;
	
	[Bindable]
	public class LocationVO
	{
		public function LocationVO()
		{
			templates = new Array();
			infoWindowTemplateVOs = new Array();
		}
		
		public var geoStatus:GeoStatusVO;
		
		public var lat:Number = 0;
		public var lng:Number = 0;
				
		public var street:String;
		public var postalCode:String;
		public var city:String;
		public var country:String;

		public var phone1:String;
		public var phone2:String;
		public var fax:String;
		public var email:String;
		public var websiteURL:String;
		public var name:String;
		public var custom:String;
		
		[Transient]
		public var infoWindowTemplateVOs:Array; // Array of HTMLTemplateMetaVO
		
		public var templates:Array; // Array of filenames of the templates (which are stored transient above)
		
		[Transient]
		public var iconVO:IconVO;
		// icon id
		public var icon:String;
		
		[Transient]
		public var imageVO:ImageVO;
		// image id
		public var image:String;
		// full image url
		public var imageURL:String;
		
		
		private function hasSameHumanValues(location:LocationVO):Boolean 
		{
			var hasSameCity:Boolean = StringUtil.areEqualCaseInsensitive(city, location.city);
			var hasSamePostalCode:Boolean = StringUtil.areEqualCaseInsensitive(postalCode, location.postalCode);
			var hasSameStreet:Boolean = isSameStreet(street, location.street);
			
			return hasSameCity && hasSamePostalCode && hasSameStreet;
		}

		private function isSameStreet(a:String, b:String):Boolean {
			if(a!=null && b!=null) {
				a = a.replace("str.", "straße");	
				b = b.replace("str.", "straße");	
				a = a.replace("strasse", "straße");	
				b = b.replace("strasse", "straße");
				a = a.replace("Str.", "Straße");	
				b = b.replace("Str.", "Straße");	
				a = a.replace("Strasse", "Straße");	
				b = b.replace("Strasse", "Straße");
			}
			return StringUtil.areEqualCaseInsensitive(a, b);	
		}
		
		public function isGeoStatusCommitable():Boolean {
			return geoStatus!=null && (geoStatus.code==GeoStatusVO.CODE_OK || geoStatus.code==GeoStatusVO.CODE_UNCERTAIN_OK);
		}
		
		public function copyFromLocation(location:LocationVO):void {
			// copy data from selected location
			city = location.city;
			lat = location.lat;
			lng = location.lng;
			postalCode = location.postalCode;
			street = location.street;
			country = location.country;
			
			iconVO = location.iconVO;
			icon = location.icon;
			
			imageVO = location.imageVO;
			image = location.image;
			imageURL = location.imageURL;
			
			name = location.name;
			phone1 = location.phone1;
			phone2 = location.phone2;
			fax = location.fax;
			email = location.email;
			websiteURL = location.websiteURL;
			custom = location.custom;
			
			infoWindowTemplateVOs = (location.infoWindowTemplateVOs!=null) ? (location.infoWindowTemplateVOs.concat()) : null;
			// templates only contains string, so a shallow copy is sufficient
			templates = (location.templates!=null) ? (location.templates.concat()) : null;
			
			
			geoStatus = location.geoStatus;
		}
		
		public static function isDynamicProperty(name:String):Boolean {
			return false; // now there are not any dynamic properties
		}
		
		public function doGeoLookup(callback:Function):void {
			geoStatus = new GeoStatusVO(GeoStatusVO.CODE_LOADING);
			
			/*
			trace(' street: ' + street);
			trace(' p.c: ' + postalCode);
			trace(' city: ' + city);
			trace(' country: ' + country);
			*/
			
			GeoHelper.getInstance().retrievePlacemarkGoogle(street, postalCode, city, country, function(result:Object):void {
				
				var geoStatusNew:GeoStatusVO = new GeoStatusVO(GeoStatusVO.CODE_LOADING);

				if(result is Array) 
				{
					var possibilities:Array = result as Array;
					possibilities = possibilities.filter(function(item:*, index:int, array:Array):Boolean {
						return country == PlacemarkVO(array[index]).country;
					});
					if(possibilities.length==0) {
						geoStatusNew.code = GeoStatusVO.CODE_ERROR;
					} else {
						geoStatusNew.code = GeoStatusVO.CODE_UNCERTAIN;
						geoStatusNew.possibilities = result as Array;
					}
				}
				else if(result is PlacemarkVO)
				{
					var placemark:PlacemarkVO = PlacemarkVO(result);
					if(placemark.faultCode!=null) {
						geoStatusNew.code = GeoStatusVO.CODE_ERROR;
					} else if(placemark.country != country)
					{
						geoStatusNew.code = GeoStatusVO.CODE_ERROR;
					} else {
						lat = placemark.lat;
						lng = placemark.lng;
						geoStatusNew.code = GeoStatusVO.CODE_OK;
					}
				}
				
				// data binding process...
				geoStatus = geoStatusNew;
				callback();
				
			});
			
		}

	}
}