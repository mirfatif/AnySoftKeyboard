#!/bin/bash -e
set -o pipefail

stopDaemon() {
	read -r -p 'Stop daemon? (y/N) ' key
	[ "$key" = y -o "$key" = Y ] || return 0
	gradlew --stop
}

trap stopDaemon EXIT

read -t 5 -r -p 'Do cleanup? (y/N): ' key || :
if [ "$key" = y -o "$key" = Y ]; then
	CLEAN=clean
	rm -rf build-logging/ buildSrc/build/ ime/dictionaries/jnidictionaryv1/.cxx/ \
		ime/dictionaries/jnidictionaryv2/.cxx/ \
		addons/languages/{english,urdu}/pack/src/main/res/raw/ \
		addons/languages/{english,urdu}/pack/src/main/res/values/*_words_dict_array.xml
fi
echo

gradlew $CLEAN googleJavaFormat :ime:app:assembleDebug :addons:languages:urdu:apk:assembleDebug

adb shell true || {
	sleep 1
	adb shell true
}
adb install outputs/apks/debug/ime-app-1.apk
adb install outputs/apks/debug/addons-languages-urdu-apk-1.apk
