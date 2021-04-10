#!/bin/bash -e
set -o pipefail

stopDaemon() {
	read -r -p 'Stop daemon? (y/N) ' key
	[ "$key" = y -o "$key" = Y ] || return 0
	gradlew --stop
}

trap stopDaemon EXIT

rm -rf build-logging/ buildSrc/build/ ime/dictionaries/jnidictionaryv1/.cxx/ \
	ime/dictionaries/jnidictionaryv2/.cxx/ \
	addons/languages/english/pack/src/main/res/raw/ \
	addons/languages/english/pack/src/main/res/values/english_words_dict_array.xml

gradlew clean googleJavaFormat :addons:languages:english:apk:assembleDebug

adb shell true || {
	sleep 1
	adb shell true
}
adb install outputs/apks/debug/addons-languages-english-apk-1.apk
