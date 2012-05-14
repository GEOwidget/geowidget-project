/**
 * @author Marco Alionso Ramirez, marco@onemarco.com
 * @url http://onemarco.com
 * @version 1.0
 * This code is public domain
 */

/**
 * The Tooltip class is an addon designed for the Google Maps GMarker class. 
 * @constructor
 * @param {LatLng} latLng
 * @param {String} text
 * @param {Number} padding
 */
function Tooltip(text, padding){
	this.text_ = text;
	this.padding_ = padding;
}

Tooltip.prototype = new GOverlay();

Tooltip.prototype.initialize = function(map){
	var div = document.createElement("div");
	div.appendChild(document.createTextNode(this.text_));
	div.className = 'gw-tooltip';
	div.style.position = 'absolute';
	div.style.visibility = 'hidden';
	map.getPane(G_MAP_MARKER_SHADOW_PANE).appendChild(div);
	this.map_ = map;
	this.div_ = div;
	var that = this;
	google.maps.Event.addDomListener(div, 'click', function() {
		google.maps.Event.trigger(that, 'click');
	});
};

Tooltip.prototype.remove = function(){
	this.div_.parentNode.removeChild(this.div_);
};

Tooltip.prototype.copy = function(){
	return new Tooltip(this.latLng_,this.text_,this.padding_);
};

Tooltip.prototype.setLatLng = function(latLng) {
	this.latLng_ = latLng;	
	this.redraw(true);
};

Tooltip.prototype.redraw = function(force){
	if (!force || !this.latLng_) {
		return;
	}
	var markerPos = this.map_.fromLatLngToDivPixel(this.latLng_);
	var xPos = Math.round(markerPos.x - this.div_.clientWidth / 2);
	var yPos = markerPos.y - this.div_.clientHeight - this.padding_;
	this.div_.style.top = yPos + 'px';
	this.div_.style.left = xPos + 'px';
};

Tooltip.prototype.show = function(){
	this.div_.style.visibility = 'visible';
};

Tooltip.prototype.hide = function(){
	this.div_.style.visibility = 'hidden';
};