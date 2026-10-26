# luci-theme-mavxa

A minimal LuCI theme with graphite surfaces, a mint accent, light and dark modes, and readable forms and logs. The palette comes from [mavxa.ru](https://mavxa.ru).

This repository starts with the package layout and approved design direction. The LuCI implementation is in progress. Nothing has been installed on a router.

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
Makefile                 OpenWrt package metadata
```

## Scope

Target OpenWrt 25.12 and its ucode-based LuCI templates first. Keep native navigation, forms, validation, permissions, and save/apply behavior. All new interface copy is English. A theme does not change the language of installed LuCI applications.

Subscription import and changes to Podkop routing belong in separate work. Log search and filtering from the prototype need a real LuCI view; CSS alone cannot implement them.

## Contributing

Use focused conventional commits, such as `feat:`, `fix:`, `docs:`, and `chore:`. Do not commit router backups, credentials, subscription links, or live configuration.

## License

Apache-2.0. See [LICENSE](LICENSE).
