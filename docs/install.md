# Installation

Use OpenWrt 25.12 with LuCI and `apk`. This package uses ucode templates and does not support OpenWrt 24.10/IPK. It has been tested on OpenWrt 25.12.2 with Podkop 0.7.20.

## First installation

Connect to the router over SSH as root:

```sh
wget -O /tmp/install-mavxa.sh https://raw.githubusercontent.com/mavxa/luci-theme-mavxa/main/install.sh
sh /tmp/install-mavxa.sh
```

The installer downloads the latest release, verifies the APK checksum, installs the public signing key, and calls `apk add`. A different existing project key stops installation. The key allows the router to verify packages signed by this project. The installer preserves the active theme, language, and network settings.

Open LuCI and go to **System → System → Language and Style**. Set **Design** to **Mavxa** and press **Save & Apply**. Set **Language** to **English** if wanted. Reload the page; use a hard refresh if the browser still shows old styles.

The header button cycles through **Dark**, **Light**, and **Auto**. This preference belongs to the current browser. Keep another theme installed, such as Glass.

## Install through LuCI

For the first GUI installation, add the signing key over SSH once:

```sh
wget -O /tmp/mavxa-apk.rsa.pub https://raw.githubusercontent.com/mavxa/luci-theme-mavxa/main/keys/mavxa-apk.rsa.pub
mkdir -p /etc/apk/keys
if [ -e /etc/apk/keys/mavxa-apk.rsa.pub ]; then
    cmp /etc/apk/keys/mavxa-apk.rsa.pub /tmp/mavxa-apk.rsa.pub
else
    cp /tmp/mavxa-apk.rsa.pub /etc/apk/keys/mavxa-apk.rsa.pub
    chmod 644 /etc/apk/keys/mavxa-apk.rsa.pub
fi
```

Stop if `cmp` reports different keys. Review the change before replacing a trusted key.

Download `luci-theme-mavxa.apk` from [Releases](https://github.com/mavxa/luci-theme-mavxa/releases/latest). In **System → Software**, choose **Upload Package…**, select the APK, and confirm installation. Then select Mavxa under **Language and Style**. Use the signed release APK; development artifacts from Actions are unsigned.

## Update

Rerun the installer, or upload the newer signed APK through **Software → Upload Package…**. The installer does not switch the active theme or language. Refresh LuCI after updating.

## Return to Glass

Choose **Glass** in **System → System → Language and Style**, then **Save & Apply**. If LuCI cannot open, use SSH:

```sh
uci set luci.main.mediaurlbase='/luci-static/glass'
uci commit luci
```

Refresh LuCI. Glass must still be installed. You can then remove Mavxa:

```sh
apk del luci-theme-mavxa
```

For another fallback theme, replace `/luci-static/glass` with its registered path. Switch themes before removing the active theme package.

## What this package changes

The package adds static assets, LuCI templates, and the Mavxa theme registration. It does not configure Podkop subscriptions, select proxy servers, restart network services, or implement new log filters. English labels in third-party applications depend on their installed translations.
