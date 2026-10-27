#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
version=$(sed -n 's/^PKG_VERSION:=//p' "$project_dir/Makefile")
release=$(sed -n 's/^PKG_RELEASE:=//p' "$project_dir/Makefile")

docker run --rm --network=none -v "$project_dir/dist:/packages:ro" \
	-e "PACKAGE=luci-theme-mavxa-${version}-r${release}.apk" \
	alpine:3.23@sha256:ff7f0c727dd796aa36787bfcd9a64bf35a6ce72a73451b3359fde849b6703d63 \
	sh -eu -c '
		mkdir -p /empty /verify
		apk mkpkg --compat 3.0.0 --info name:luci-base --info version:0 --info arch:noarch \
			--files /empty --output /tmp/luci-base-0.apk
		apk --root /verify --initdb --no-network --no-scripts --allow-untrusted \
			add /tmp/luci-base-0.apk "/packages/$PACKAGE"
		test -f /verify/www/luci-static/mavxa/cascade.css
		test -f /verify/www/luci-static/mavxa/theme.js
		test -f /verify/www/luci-static/resources/menu-mavxa.js
		test -f /verify/usr/share/ucode/luci/template/themes/mavxa/header.ut
		test -f /verify/usr/share/ucode/luci/template/themes/mavxa/footer.ut
		test -x /verify/etc/uci-defaults/30_luci-theme-mavxa
		test ! -e /verify/etc/config/luci
		test ! -e /verify/etc/config/podkop
		test "$(stat -c %u /verify/www/luci-static/mavxa/theme.js)" = 0
		printf "APK install and file ownership checks passed.\n"
	'
