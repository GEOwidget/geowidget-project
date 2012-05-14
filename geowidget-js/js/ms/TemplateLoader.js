/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('ms.TemplateLoader', function(Y){
    YUI.namespace("ms");
    
    YUI.ms.TemplateLoader = function(config){
        config = config ||
        {};
        
        var that = {};
        
        var map = {};
        
        var urlMapper = config.urlMapper ||
        function(url){
            return url;
        };
        
        that.getTemplate = function(url){
            url = urlMapper(url);
            if (map[url] === undefined) {
                throw new Error('undefined template: ' + url);
            }
            else {
                return map[url];
            }
        };
        
        that.loadTemplate = function(url, callback){
            url = urlMapper(url);
            if (map[url] === undefined) {
                Y.io(url, {
                    on: {
                        success: function(id, xhr){
                            var template = xhr.responseText;
                            map[url] = template;
                            callback(template);
                        }
                    }
                });
            }
            else {
                callback(map[url]);
            }
        };
        
        that.loadTemplates = function(urls, callback){
            var count = 0;
            if (urls.length === 0) {
                callback();
            }
            Y.Array.each(urls, function(url){
                that.loadTemplate(url, function(){
                    count++;
                    if (count === urls.length) {
                        callback();
                    }
                });
            });
        };
        
        var getValue = function(node){
            if (node !== null) {
				var val = node.get('innerHTML');
				node.remove();
				return val;
			}
			else {
				return undefined;
			}
        };
        
        that.applyTemplate = function(url, object){
            var templateString = that.getTemplate(url);
            // get javascript from template
            var jsRe = new RegExp("<script[^>]*>((.|\n|\r)*)<\/script>", "i");
            var jsMatch = templateString.match(jsRe);
            // remove it
            if (jsMatch) {
                templateString = templateString.replace(jsRe, "");
            }
            var template = Y.Node.create(templateString);
            var title = getValue(template.query('.title'));
            var html = pure.autoRender(Y.Node.getDOMNode(template), object);
            return {
                title: title,
                html: html,
                js: jsMatch ? jsMatch[1] : undefined
            };
        };
        
        return that;
    };
}, '0.0.1', {
    requires: ['io', 'node']
});
