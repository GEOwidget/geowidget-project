/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('ms.Behaviours', function(Y){
    YUI.namespace("ms");
    
    YUI.ms.Behaviours = function(){
        var that = {};
        
        that.setInfoText = function(element, infoText, infoClass){
            infoClass = infoClass || 'yui-info-text';
            element = Y.get('#' + element);
            var value = element.get('value');
            if (value === '') {
                element.set('value', infoText);
                element.addClass(infoClass);
            }
            
            var onBlur = function(e){
                value = e.target.get('value');
                if (value === '') {
                    e.target.set('value', infoText);
                    e.target.addClass(infoClass);
                }
            };
            
            var onFocus = function(e){
                e.target.removeClass(infoClass);
                if (value === '') {
                    e.target.set('value', '');
                }
            };
            element.on('focus', onFocus);
            element.on('blur', onBlur);
        };
        return that;
    }();
}, '0.0.1', {
    requires: ['node']
});
