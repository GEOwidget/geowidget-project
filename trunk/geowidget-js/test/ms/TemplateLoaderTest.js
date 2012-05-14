/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('test.ms.TemplateLoaderTest', function(Y){
    Y.namespace("test.ms");
    
    Y.test.ms.TemplateLoaderTest = new Y.Test.Case({
    
        //name of the test case - if not provided, one is auto-generated
        name: "Template Loader Tests",
        
        createLoader: function(){
            return YUI.ms.TemplateLoader({
                urlMapper: function(url){
                    return 'test/templates/' + url;
                }
            });
        },
        
        //---------------------------------------------------------------------
        // Test methods - names must begin with "test"
        //---------------------------------------------------------------------
        
        testJs: function(){
			var that = this;
            var loader = this.createLoader();
            loader.loadTemplate('js.html', function(template){
                that.resume(function(){
                    var js = loader.applyTemplate('js.html').js;
                    eval(js);
                    Y.Assert.areEqual(3, a);
                });
            });
            that.wait(1000);
        },
        
        testNoJsInHTML: function(){
			var that = this;
            var loader = this.createLoader();
            loader.loadTemplate('js.html', function(template){
                that.resume(function(){
                    var html = loader.applyTemplate('js.html').html;
                    var jsRe = new RegExp("<script[^>]*>((.|\n|\r)*)<\/script>", "i");
                    var jsMatch = html.match(jsRe);
                    Y.assert(!jsMatch, "There should be no SCRIPT tag in the html part of a template");
                });
            });
            that.wait(1000);
        }
        
    });
}, '0.0.1', {
    requires: ['ms.TemplateLoader']
});
