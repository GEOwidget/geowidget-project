# Introduction #

Here you can find the most frequent questions related to GEOwidget and the answers to them.


# Details #

**What Google API Version are you using?**
<br />Google API version 2 is currently used.

**Where can I add my API key(s) to use GEOwidget?**
<br />Please edit the file /trunk/geowidget-js/js/googleapi.js

var keys = [
> {host:'dev.geowidget.de',       key:'ABQIAAAAquIIHMFUJg94ExRueMgLfBQT-YiGEB2Gh-_MXOPH4FbMzkpMNxQaFQ\_LWi9LWk3A1bA-uLTk7OWlaA'},
>_<br />{host:'test.geowidget.de',      key:'ABQIAAAAquIIHMFUJg94ExRueMgLfBQrrcHSCvucis2GhA4yAO0HhMoSIBRDz7GR2o4NCrOPAtM4CLTHnURtOA'},
> <br />{host:'www.geowidget.de',       key:'ABQIAAAAquIIHMFUJg94ExRueMgLfBTceWMOXjWxcZqMNC-vk45-XsWusxSHwZOoCqexHZahq2sTWDWaDqoGFQ'}
];

Just replace hosts and the keys as you need.

**Can GEOwidget handle multiple languages?**
<br />Yes it is possible to have multiple languages. The current code (online manager) is only in english though. The [gettext](http://www.gnu.org/software/gettext/) library is used for that purpose.