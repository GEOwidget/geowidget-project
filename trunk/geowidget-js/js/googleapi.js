/*
 * Copyright (C) 2009-12 Marcus Schiesser, Gelnhausen, Germany and SaaS Web Internet Solutions GmbH, Karlsruhe, Germany
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
var keys = [
	{host:'dev.geowidget.de',	key:'ABQIAAAAquIIHMFUJg94ExRueMgLfBQT-YiGEB2Gh-_MXOPH4FbMzkpMNxQaFQ_LWi9LWk3A1bA-uLTk7OWlaA'},
	{host:'test.geowidget.de',	key:'ABQIAAAAquIIHMFUJg94ExRueMgLfBQrrcHSCvucis2GhA4yAO0HhMoSIBRDz7GR2o4NCrOPAtM4CLTHnURtOA'},
	{host:'www.geowidget.de',	key:'ABQIAAAAquIIHMFUJg94ExRueMgLfBTceWMOXjWxcZqMNC-vk45-XsWusxSHwZOoCqexHZahq2sTWDWaDqoGFQ'},
	{host:'localhost',			key:'ABQIAAAAM_iR3JdmhqNVovC7QQ9juhT2yXp_ZAY8_ufC3CFXhHIE1NvwkxSeILkh3ftHaT2yiMgGIRR0ua-sDg'},
	{host:'www.geo-widget.com',	key:'ABQIAAAAquIIHMFUJg94ExRueMgLfBR-kRC07XFp324TiKggNrQD8CXEsRQyV5UNXR7D-s5_55cmrhh2NSdNSw'}
];

var host = location.host;

for(var i=0; i<keys.length; i++) {
	if(keys[i].host === host) {
		document.write('<script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=' + keys[i].key + '" type="text/javascript"></scri' + 'pt>');
		break;
	}
}
