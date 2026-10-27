#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
version=$(sed -n 's/^PKG_VERSION:=//p' "$project_dir/Makefile")
release=$(sed -n 's/^PKG_RELEASE:=//p' "$project_dir/Makefile")
mkdir -p "$project_dir/dist"

set --
if [ -n "${APK_SIGN_KEY:-}" ]; then
	test -r "$APK_SIGN_KEY"
	set -- --mount "type=bind,source=$APK_SIGN_KEY,target=/signing.key,readonly"
fi

docker run --rm --network=none \
	"$@" \
	-v "$project_dir:/src:ro" -v "$project_dir/dist:/out" \
	-e "PKG_VERSION=$version" -e "PKG_RELEASE=$release" \
	-e "OWNER_UID=$(id -u)" -e "OWNER_GID=$(id -g)" \
	alpine:3.23@sha256:ff7f0c727dd796aa36787bfcd9a64bf35a6ce72a73451b3359fde849b6703d63 \
	sh -eu -c '
		mkdir -p /pkg/files/www /pkg/files/usr/share/ucode/luci/template/themes
		cp -R /src/htdocs/. /pkg/files/www/
		cp -R /src/root/. /pkg/files/
		cp -R /src/ucode/template/themes/mavxa /pkg/files/usr/share/ucode/luci/template/themes/
		mkdir -p /pkg/files/usr/share/licenses/luci-theme-mavxa
		cp /src/LICENSE /src/NOTICE /pkg/files/usr/share/licenses/luci-theme-mavxa/
		package="luci-theme-mavxa-${PKG_VERSION}-r${PKG_RELEASE}.apk"
		set --
		if [ -f /signing.key ]; then
			set -- --sign-key /signing.key
		fi
		apk mkpkg "$@" --compat 3.0.0 \
			--info name:luci-theme-mavxa \
			--info "version:${PKG_VERSION}-r${PKG_RELEASE}" \
			--info "description:Minimal graphite and mint theme for LuCI" \
			--info arch:noarch --info license:Apache-2.0 \
			--info origin:luci-theme-mavxa \
			--info url:https://github.com/mavxa/luci-theme-mavxa \
			--info maintainer:mavxa --info depends:luci-base \
			--script post-install:/src/root/etc/uci-defaults/30_luci-theme-mavxa \
			--script post-upgrade:/src/root/etc/uci-defaults/30_luci-theme-mavxa \
			--script post-deinstall:/src/scripts/post-deinstall.sh \
			--files /pkg/files --output "/out/$package"
		cd /out
		sha256sum "$package" > "$package.sha256"
		chown "$OWNER_UID:$OWNER_GID" "$package" "$package.sha256"
	'

printf 'Built dist/luci-theme-mavxa-%s-r%s.apk\n' "$version" "$release"
