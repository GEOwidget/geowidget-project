#!/bin/sh
dir=`dirname $0`
java -Djava.endorsed.dirs=$dir -jar $dir/JSBuilder2.jar --projectFile $dir/build.jsb2 --homeDir $dir