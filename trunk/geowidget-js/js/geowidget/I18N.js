/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
YUI().add('geowidget.I18N', function(Y){
    YUI.namespace("geowidget.I18N");
    
    var _locales = {
    	'de_DE': {
	    	"directionsManager.removeRoute": 'Um die Route zu entfernen, klicken Sie hier.',
    		"geoUtil.multiplePlaces": "Es wurden mehrere Orte gefunden. Meinten Sie...",
    		"geoUtil.noAddress": "Leider keine Adresse gefunden. Versuchen Sie es bitte nocheinmal.",
    		"geoUtil.error": "Fehler:",
    		"geoUtil.tryAgain": "Bitte probieren Sie es später noch einmal."
    	},
    	'en_US': {
	    	"directionsManager.removeRoute": 'To remove the route, click here.',
    		"geoUtil.multiplePlaces": "More than one place found. Did you mean...",
    		"geoUtil.noAddress": "No address found. Please try again.",
    		"geoUtil.error": "Error:",
    		"geoUtil.tryAgain": "Please try again later."
    	},
    	'en_GB': {
	    	"directionsManager.removeRoute": 'To remove the route, click here.',
    		"geoUtil.multiplePlaces": "More than one place found. Did you mean...",
    		"geoUtil.noAddress": "No address found. Please try again.",
    		"geoUtil.error": "Error:",
    		"geoUtil.tryAgain": "Please try again later."
    	}    	
    };

    YUI.geowidget.I18N.getText = function(key) {
    	var selectedLocale = YUI.geowidget.Model.config.locale;
    	var locale = _locales[selectedLocale];
    	return locale[key] ? locale[key] : key;
    }
	
}, '0.0.1', {
});