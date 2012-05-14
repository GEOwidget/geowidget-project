/**
 * based on URL parser from http://www.netlobo.com/url_query_string_javascript.html
 */
YUI.namespace("ms");

YUI.ms.URLParser = function(){
    var that = {};
    that.parse = function(name, phpCompatibility){
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS);
        var results = regex.exec(window.location.href);
        if (results === null) {
            return "";
        }
        else {
            var uri = results[1];
            if (phpCompatibility) {
                // some old implementations interpret a + as a space 
                // but according to RFC 3986 a space should be encoded as %20
                uri = results[1].replace(/\+/g, '%20');
            }
            return decodeURIComponent(uri);
        }
    };
	return that;
}();
