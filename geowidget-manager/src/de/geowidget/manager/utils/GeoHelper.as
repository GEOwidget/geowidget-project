/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.geowidget.manager.utils
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.services.ClientGeocoder;
	import com.google.maps.services.ClientGeocoderOptions;
	import com.google.maps.services.GeocodingEvent;
	import com.google.maps.services.Placemark;
	
	import de.geowidget.manager.model.vo.PlacemarkVO;
	
	import gnu.as3.gettext.FxGettext;
	import gnu.as3.gettext._FxGettext;
	
	import ms.util.ItemSelector;
	import ms.util.URLHelper;
	
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class GeoHelper
	{
		private static var _instance:GeoHelper;
		private static var fx:_FxGettext = FxGettext;
		
		private var _language:String;
		
		public function GeoHelper()
		{
			_language = "de";
		}
		
		public static function getInstance():GeoHelper {
			if(_instance==null)
				_instance = new GeoHelper();
			return _instance;
		}
		
		
	    public function createRandomLatLng(map:Map):LatLng {
	        var bounds:LatLngBounds = map.getLatLngBounds();
	        var southWest:LatLng = bounds.getSouthWest();
	        var northEast:LatLng = bounds.getNorthEast();
	        var lngSpan:Number = northEast.lng() - southWest.lng();
	        var latSpan:Number = northEast.lat() - southWest.lat();
	        var newLat:Number = southWest.lat() + (latSpan * Math.random());
	        var newLng:Number = southWest.lng() + (lngSpan * Math.random());
	        return new LatLng(newLat, newLng);
	    }

		public function retrievePlacemark(address:String, callback:Function, showFault:Boolean=true):void {
			 var geocoder:ClientGeocoder = new ClientGeocoder(new ClientGeocoderOptions({countryCode: "DE"}));
			  geocoder.addEventListener(GeocodingEvent.GEOCODING_SUCCESS,
			      function(event:GeocodingEvent):void {
			        var placemarks:Array = event.response.placemarks;
			        if (placemarks.length==1) {
			        	var placemark:Placemark = placemarks[0] as Placemark;
			        	callback(placemark);
			        } else if (placemarks.length > 1) {
			        	ItemSelector.selectItem(fx.gettext("Multiple places found. Did you mean..."), placemarks, callback, 
			        	function(placemark:Object):String {
			        		return (placemark as Placemark).address;
			        	});
			        } else
		        		Alert.show(fx.gettext("Sorry, no address found. Please try again."));
			      });
			  geocoder.addEventListener(GeocodingEvent.GEOCODING_FAILURE,
			        function(event:GeocodingEvent):void {
			        	if(showFault)
			        		Alert.show(fx.gettext("Sorry, no address found. Please try again."));
			        });
			  geocoder.geocode(address);			
		}
		
		public function retrievePlacemarkYahoo(street:String, zip:String, city:String, callback:Function):void {
			var service:HTTPService = new HTTPService();
			service.url = "http://local.yahooapis.com/MapsService/V1/geocode";
			service.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var result:Object = event.result.ResultSet.Result;
				callback(result);
			});
			service.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				callback(event.fault);
			});
			var params:Object = {street: street, zip: zip, city: city, country: "DE", appid: "YD-9G7bey8_JXxQP6rxl.fBFGgCdNjoDMACQA--"};
			service.url += "?" + URLHelper.buildURL(params);
			service.send();
		}
		
		/*
		private function createLatLngObj(placemark:XML):LocationVO  {
			
			var ret:LocationVO = new LocationVO();
			
			var addressXml:XML = placemark.address_component.(type[0].toString() == 'country')[0];
			
			if(addressXml != null)
			{
				ret.country = addressXml.short_name.toString();
			}
			
			var address:String = placemark.formatted_address.toString();
			
			var parts:Array = address.split(",");
			
			// get postalcode and city if available
			if(parts.length>=2) {
				// remove country, we already have the country code
				parts.pop();
				switch(ret.country) {
					case 'DE':
						if(parts.length>=2) {
							ret.street = parts.shift();
						}
						var postalCity:Array = parts.shift().match(/( \d{5} )?(\S+)/);
						ret.postalCode = postalCity[1] ? StringUtil.trim(postalCity[1]) : undefined;
						ret.city = postalCity[2];
					break;
					case 'US':
						if(parts.length>=3) {
							ret.street = parts.shift();
						}
						ret.city = parts.shift();
						ret.postalCode = parts.shift();
					break;
					default:
						if(parts.length>=2) {
							ret.street = parts.shift();
						}
						ret.city = StringUtil.trim(parts.join(","));
					break;
				}
			}
			
			// retrieve lat/lng values
			ret.lat = Number( placemark.geometry.location.lat.toString() );
			ret.lng = Number( placemark.geometry.location.lng.toString() );
			
			
			return ret;
			
			
		}
		*/
		
		private function createLatLngObj(placemark:Object, ... args):PlacemarkVO  {
			var ret:PlacemarkVO = new PlacemarkVO();
			var country:Object = placemark.addressDetails.Country;
			// parse country code
			if(country) {
				ret.country = country.CountryNameCode;
			}
			// retrieve lat/lng values
			ret.lat = placemark.point.lat();
			ret.lng = placemark.point.lng();
			// retrieve postalcode and street
			ret.label = placemark.address;
			return ret;
		}
		
		public function setGeocoderLanguage(language:String):void {
			_language = language;
		}
		
		/*
		public function retrievePlacemarkGoogle(street:String, zip:String, city:String, country:String, callback:Function):void
		{
			
			var service:HTTPService = new HTTPService();
			
			service.resultFormat = "e4x";
			service.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				
				var xml:XML = event.result as XML;
				
				var placemarks:XMLList = xml.result;
				var placemark:XML;
				
		        if (placemarks.length() == 1)
		        {
		        	placemark = placemarks[0];
		        	callback(createLatLngObj(placemark));
		        }
		        else if (placemarks.length() > 1) 
		        {
		        	var placemarks_arr:Array = new Array();
		        	
		        	for each(placemark in placemarks)
		        	{
		        		placemarks_arr.push(createLatLngObj(placemark));
		        	}
		        	
		        	callback(placemarks_arr);
		        	
		        }
		        else
		        {
		        	callback(new Fault("NO_ADDRESS", fx.gettext("Sorry, no address found. Please try again.")));
		        }
		        
			});
			service.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				callback(new Fault("NO_ADDRESS", fx.gettext("Sorry, no address found. Please try again.")));
			});
			
			var address:String = street + ", " + zip + " " + city;
			
			var serviceUrl:String = "http://maps.google.com/maps/api/geocode/xml?";
			
			serviceUrl += 'address=' + address + '&';
			serviceUrl += 'region=' + country + '&';
			serviceUrl += 'language=' + _language + '&';
			serviceUrl += 'sensor=false';
			
			service.url = '/amf/redirect.php?' + serviceUrl;
			
			service.send();
			
		}*/
		
		public function retrievePlacemarkGoogle(street:String, zip:String, city:String, countryCode:String, callback:Function):void {
			 var geocoder:ClientGeocoder = new ClientGeocoder(new ClientGeocoderOptions({countryCode: countryCode, language: _language}));
			  geocoder.addEventListener(GeocodingEvent.GEOCODING_SUCCESS,
			      function(event:GeocodingEvent):void {
			        var placemarks:Array = event.response.placemarks;
			        if (placemarks.length==1) {
			        	var placemark:Placemark = placemarks[0] as Placemark;
			        	callback(createLatLngObj(placemark));
			        } else if (placemarks.length > 1) {
			        	callback(placemarks.map(createLatLngObj));
			        } else {
			        	var faultPlace:PlacemarkVO =new PlacemarkVO();
			        	faultPlace.faultCode = "NO_ADDRESS";
			        	callback(faultPlace);
			        }
			      });
			  geocoder.addEventListener(GeocodingEvent.GEOCODING_FAILURE,
			        function(event:GeocodingEvent):void {
			        	var faultPlace:PlacemarkVO =new PlacemarkVO();
			        	faultPlace.faultCode = "NO_ADDRESS";
			        	callback(faultPlace);
			        }
			  );
			  
			  var address:String = street + ", " + zip + " " + city;
			  
			  geocoder.geocode(address);
		}
		

	}
}