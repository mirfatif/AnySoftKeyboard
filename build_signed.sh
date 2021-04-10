#!/bin/bash -e
set -o pipefail

KEYSTORE=~/AndroidProjects/AnySoftKeyboard.jks
[ -f "$KEYSTORE" ]

stopDaemon() {
	read -r -p 'Stop daemon? (y/N) ' key
	[ "$key" = y -o "$key" = Y ] || return 0
	gradlew --stop
}

trap stopDaemon EXIT

! git status --porcelain | grep . || exit
bash -x scripts/ci/ci_check.sh
#gradlew testDebugUnitTest

rm -rf build-logging/ buildSrc/build/ ime/dictionaries/jnidictionaryv1/.cxx/ \
	ime/dictionaries/jnidictionaryv2/.cxx/ \
	addons/languages/english/pack/src/main/res/raw/ \
	addons/languages/english/pack/src/main/res/values/english_words_dict_array.xml

read -r -s -p 'KeyStore password: ' KEYSTORE_PASS
echo
[ -n "$KEYSTORE_PASS" ]

gradlew \
	clean \
	googleJavaFormat \
	:addons:languages:english:apk:assembleRelease \
	-Pandroid.injected.signing.store.file=$KEYSTORE \
	-Pandroid.injected.signing.store.password=$KEYSTORE_PASS \
	-Pandroid.injected.signing.key.alias=key0 \
	-Pandroid.injected.signing.key.password=$KEYSTORE_PASS \
	-Pandroid.injected.signing.v1-enabled=true \
	-Pandroid.injected.signing.v2-enabled=true

adb shell true || {
	sleep 1
	adb shell true
}
adb install outputs/apks/release/addons-languages-english-apk-1.apk
