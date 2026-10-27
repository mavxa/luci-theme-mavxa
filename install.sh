#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
set -eu

fail() { printf '%s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || fail 'Run this installer as root on the router.'
command -v apk >/dev/null || fail 'OpenWrt 25.12 with apk is required.'
command -v wget >/dev/null || fail 'wget is required.'
apk info -e luci-base >/dev/null 2>&1 || fail 'Install LuCI before installing this theme.'
# shellcheck source=/dev/null
. /etc/openwrt_release
case "$DISTRIB_RELEASE" in
	25.12.*) ;;
	*) fail 'This release supports OpenWrt 25.12 only.' ;;
esac

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM
base_url=https://github.com/mavxa/luci-theme-mavxa/releases/latest/download

for file in luci-theme-mavxa.apk luci-theme-mavxa.apk.sha256 mavxa-apk.rsa.pub; do
	wget -q -O "$work_dir/$file" "$base_url/$file"
done
(cd "$work_dir" && sha256sum -c luci-theme-mavxa.apk.sha256)

key_path=/etc/apk/keys/mavxa-apk.rsa.pub
if [ -e "$key_path" ]; then
	cmp -s "$key_path" "$work_dir/mavxa-apk.rsa.pub" || fail 'The existing signing key differs. Review the key change before continuing.'
else
	mkdir -p /etc/apk/keys
	cp "$work_dir/mavxa-apk.rsa.pub" "$key_path"
	chmod 644 "$key_path"
fi

apk add --no-network "$work_dir/luci-theme-mavxa.apk"
printf '\nInstalled. Select Mavxa in System > System > Language and Style.\n'
printf 'The active theme, language and network settings have been preserved.\n'
