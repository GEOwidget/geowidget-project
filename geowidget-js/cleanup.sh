#!/bin/sh
# clean up non-productive stuff
widgetdir=`dirname $0`
rm -fr $widgetdir/js/ms
rm -fr $widgetdir/js/geowidget
rm -fr $widgetdir/lib
rm -fr $widgetdir/playground
rm -fr $widgetdir/test
rm $widgetdir/build/geowidget-debug.js
rm $widgetdir/test.html
rm $widgetdir/build.jsb2
rm $widgetdir/build.sh
rm $widgetdir/debug.html
rm $widgetdir/index-debug.html
rm $widgetdir/JSBuilder2.jar
