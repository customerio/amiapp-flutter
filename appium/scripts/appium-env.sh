#!/bin/sh

# Run as source ./scripts/appium-env.sh

set -e

export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

echo "\nJAVA_HOME=$JAVA_HOME"

export ANDROID_HOME=$ANDROID_SDK_ROOT

echo "\nANDROID_HOME=$ANDROID_HOME"

echo "\nAppium environment setup successfully"
