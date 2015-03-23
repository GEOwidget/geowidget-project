# Introduction #

GEOwidget is the online toolkit to build breathtaking interactive maps like storefinders or directories within few clicks and without programming a single line of code.


# Details #

The GEOwidget application, from the user perspective, is split in two parts:

1) The online management interface: enter all locations which need to be displayed. Also, various features can be adjusted like the zoom function, the search bar, routing information, etc. The web application generates an iframe which can be pasted in the source code, where it needs to be displayed.

2) The widget displays the map with all information as configured. The widget uses a json config file which can be manipulated any time in order to make specific adjustments which may not be available through the web interface.

# Installation requirements #

**Web Interface // Management**
<br />Zend Server Community Environment 5.3, including PHP 5.2
(newer versions may work but have not been tested)
<br />MySQL 5.0 (or newer, not tested)
<br />PHPUnit 3.4.3 (or newer, not tested)
<br />GNU gettext

**Widget (Javascript)**
<br />Google API v2 key
<br />SUN JDK 6
<br />JSBuilder2 to minify JS code
<br />(http://dev.sencha.com/deploy/JSBuilder2/Readme.txt)

Important: You need to use a own web server, starting the Javascript
from the filesystem does not work