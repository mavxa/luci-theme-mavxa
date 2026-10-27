#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
version=$(sed -n 's/^PKG_VERSION:=//p' "$project_dir/Makefile")
release=$(sed -n 's/^PKG_RELEASE:=//p' "$project_dir/Makefile")

docker run --rm --network=none -v "$project_dir:/src:ro" \
	-e "PACKAGE=luci-theme-mavxa-${version}-r${release}.apk" \
	alpine:3.23@sha256:ff7f0c727dd796aa36787bfcd9a64bf35a6ce72a73451b3359fde849b6703d63 \
	sh -eu -c '
		mkdir -p /fixtures /fake
		cp "/src/dist/$PACKAGE" /fixtures/luci-theme-mavxa.apk
		cp /src/keys/mavxa-apk.rsa.pub /fixtures/
		(cd /fixtures && sha256sum luci-theme-mavxa.apk > luci-theme-mavxa.apk.sha256)
		printf "DISTRIB_RELEASE=25.12.2\n" > /etc/openwrt_release
		printf "#!/bin/sh\ncase \"\$1\" in info) exit 0;; add) printf \"%%s\\\\n\" \"\$*\" >> /tmp/apk-calls;; esac\n" > /fake/apk
		printf "#!/bin/sh\ncp \"/fixtures/\${4##*/}\" \"\$3\"\n" > /fake/wget
		chmod +x /fake/apk /fake/wget
		export PATH="/fake:$PATH"
		sh /src/install.sh >/tmp/installer-output
		cmp /etc/apk/keys/mavxa-apk.rsa.pub /fixtures/mavxa-apk.rsa.pub
		grep -q "add --no-network" /tmp/apk-calls
		if grep -q "allow-untrusted" /tmp/apk-calls; then exit 1; fi
		test ! -e /etc/config/luci
		sh /src/install.sh >/tmp/installer-output
		printf "changed-key\n" > /etc/apk/keys/mavxa-apk.rsa.pub
		if sh /src/install.sh >/tmp/installer-output 2>&1; then exit 1; fi
		grep -q "existing signing key differs" /tmp/installer-output
		cp /fixtures/mavxa-apk.rsa.pub /etc/apk/keys/mavxa-apk.rsa.pub
		printf "corruption" >> /fixtures/luci-theme-mavxa.apk
		if sh /src/install.sh >/tmp/installer-output 2>&1; then exit 1; fi
		test "$(wc -l < /tmp/apk-calls)" -eq 2
		printf "Installer repeat, changed-key and corrupt-download checks passed.\n"
	'
