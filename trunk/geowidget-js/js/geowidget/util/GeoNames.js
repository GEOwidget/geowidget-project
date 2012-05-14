/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * YUI.geowidget.util.GeoNames.search()
 * argv.name		(string)	- place name only(Important:urlencoded utf8) - required
 * argv.maxRows		(integer)	- the maximal number of rows in the document returned by the service. Default is 100, the maximal allowed value is 1000
 * argv.startRow	(integer)	- Used for paging results. If you want to get results 30 to 40, use startRow=30 and maxRows=10. Default is 0.
 * argv.country		(string : country code, ISO-3166)	- Default is all countries. The country parameter may occur more then once, example: country=FR&country=GP
 * argv.lang		(string ISO-636 2-letter language code; en,de,fr,it,es)	- place name and country name will be returned in the specified language. Default is English. Feature classes and codes are only available in English and Bulgarian.
 * argv.isNameRequired	(boolean)	- At least one of the search term needs to be part of the place name. Example : A normal seach for Berlin will return all places within the state of Berlin. If we only want to find places with 'Berlin' in the name we se the parameter isNameRequired to 'true'. The difference to the name_equals parameter is that this will allow searches for 'Berlin, Germany' as only one search term needs to be part of the name.
 */
YUI().add('geowidget.util.GeoNames', function(Y){
    YUI.namespace("geowidget.util");
    
    YUI.geowidget.util.GeoNames = function(){
        var that = {};
        var geoDataSource = new Y.DataSource.Get({
            source: "http://ws.geonames.org/searchJSON?"
        });
        
        that.search = function(argv, callback){
            var data = [];
            
            argv['style'] = 'SHORT';
            
            for (var each in argv) 
                if (argv.hasOwnProperty(each)) {
                    data.push(encodeURIComponent(each) + '=' + encodeURIComponent(argv[each]));
                }
            
            data = data.join('&');
            
            geoDataSource.sendRequest(data, {
                success: function(result){
                    callback(result.data);
                },
                
                failure: function(result){
                    alert("Could not retrieve data from geonames.org: " + result.error.message);
                    callback({});
                }
            });
        }
        
        return that;
    }();
}, '0.0.1', {
    //requires: ['io', 'json-parse', 'datasource']
    requires: ['datasource-get']
});


