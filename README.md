# luci-theme-mavxa

A minimal LuCI theme with graphite surfaces, a mint accent, light and dark modes, and readable forms and logs.

The first implementation provides a native LuCI shell, responsive navigation, dark/light/auto modes, forms, tables, dialogs, and log styling. It is based on OpenWrt's maintained 2020 theme layout. The signed APK has been installed and checked on OpenWrt 25.12.2 with Podkop 0.7.20.

It targets OpenWrt 25.12 with ucode templates. Other LuCI versions have not been tested.

![Native component preview](docs/preview-dark.jpg)

## Design

[Interactive prototype](https://p.superdesign.dev/draft/49d994d1-e518-46a2-922a-baf7dc203fa4) · [Superdesign canvas](https://superdesign.dev/teams/7468afe0-be48-46ce-94a1-4d0a32739a85/projects/b1e373c4-d977-43a8-8a80-e9708ca54228)

The prototype uses demo records and simulated connections. It describes the intended interface; it does not provide a router backend.

## Layout

```text
htdocs/luci-static/       Browser CSS and JavaScript
ucode/template/themes/   LuCI templates
root/etc/uci-defaults/   Theme registration
docs/                    Design decisions and implementation notes
tests/                   Targeted checks
dev/                     Offline component preview
Makefile                 OpenWrt package metadata
```

## Scope

Target OpenWrt 25.12 and its ucode-based LuCI templates first. Keep native navigation, forms, validation, permissions, and save/apply behavior. All new interface copy is English. A theme does not change the language of installed LuCI applications.

Subscription import and changes to Podkop routing belong in separate work. Log search and filtering from the prototype need a real LuCI view; CSS alone cannot implement them.

## Local preview and checks

No frontend build or npm dependencies are needed. Serve the repository root:

```sh
python -m http.server 8768 --bind 127.0.0.1
```

Open [the component preview](http://127.0.0.1:8768/dev/preview.html). It contains example LuCI markup and demo data, without a router connection. It does not exercise the LuCI menu RPC or real save/apply operations.

```sh
node --test tests/theme.test.mjs
node --check htdocs/luci-static/mavxa/theme.js
node --check htdocs/luci-static/resources/menu-mavxa.js
sh -n root/etc/uci-defaults/30_luci-theme-mavxa
```

## Install

Requires OpenWrt 25.12 with LuCI and `apk`. Run as root over SSH:

```sh
wget -O /tmp/install-mavxa.sh https://raw.githubusercontent.com/mavxa/luci-theme-mavxa/main/install.sh
sh /tmp/install-mavxa.sh
```

The installer downloads the latest signed APK, checks its SHA-256 checksum, and adds this project's public signing key to `/etc/apk/keys/`. It refuses to replace a different existing key. Installing that key trusts future packages signed by this project.

Choose **Mavxa** in **System → System → Language and Style**, then **Save & Apply**. Choose **English** there if needed. Installation preserves the selected theme, language, and network settings. No reboot is required. Keep Glass or another theme installed for rollback.

[Download the signed APK](https://github.com/mavxa/luci-theme-mavxa/releases/latest) · [Installation, updates and rollback](docs/install.md)

After the first installation, upload a release APK through **System → Software → Upload Package…** to update it, just as with other LuCI packages. You can also rerun the installer.

## Build and check

No frontend build or npm dependencies are needed. The standalone builder uses Docker and a pinned Alpine image with `apk mkpkg`:

```sh
./build-pkg.sh
./tests/package.test.sh
./tests/installer.test.sh
node --test tests/theme.test.mjs
```

Packages are written to `dist/`. Local and CI builds are unsigned by default. For a signed build, set `APK_SIGN_KEY` to an RSA private key outside this repository. Routers must trust the matching public key. Official release downloads use this project's signing key; CI artifacts are for development.

The OpenWrt SDK/buildroot path is also available through `Makefile`. Place this repository under `package/luci-theme-mavxa` with the LuCI feed installed, then run `make package/luci-theme-mavxa/compile V=s`. The SDK build has not been tested.

## Validation status

The APK installs on OpenWrt 25.12.2 with normal signature verification. Both ucode templates compile on that router. Automated checks cover theme switching, mobile navigation, registration, package contents and ownership, repeated installation, checksum failures, and signing-key changes.

Live checks cover Podkop 0.7.20 forms and dashboard, light/dark modes, and a 390px mobile layout with four URLTest entries. Router configuration hashes match the pre-install backup. Save/apply operations that change networking and a router reboot are outside these checks.

The theme styles native LuCI and Podkop views. The prototype's custom log filters, export, and simulated connection dashboard are not part of this package. OpenWrt 24.10/IPK is unsupported.

## Contributing

Use focused conventional commits, such as `feat:`, `fix:`, `docs:`, and `chore:`. Do not commit router backups, credentials, subscription links, or live configuration.

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE) for upstream attribution.
