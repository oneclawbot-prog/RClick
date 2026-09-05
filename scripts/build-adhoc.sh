#!/bin/bash
# 无开发者证书时：本地编译 Release 版，ad-hoc 签名并安装到 /Applications
set -euo pipefail
cd "$(dirname "$0")/.."
xcodebuild -project RClick.xcodeproj -scheme RClick -configuration Release \
  -destination 'platform=macOS' -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build | grep -E "error:|BUILD"
APP=build/Build/Products/Release/RClick.app
codesign --force --sign - --entitlements FinderSyncExt/FinderSyncExt.entitlements "$APP/Contents/PlugIns/FinderSyncExt.appex"
codesign --force --sign - --entitlements RClick/RClick.entitlements "$APP"
osascript -e 'quit app "RClick"' 2>/dev/null || true
rm -rf /Applications/RClick.app
cp -R "$APP" /Applications/RClick.app
pluginkit -a /Applications/RClick.app/Contents/PlugIns/FinderSyncExt.appex
pluginkit -e use -i cn.wflixu.RClick.FinderSyncExt
open /Applications/RClick.app
echo "已安装并启动 /Applications/RClick.app"
