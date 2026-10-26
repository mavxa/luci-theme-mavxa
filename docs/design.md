# Design direction

Keep the approved layout from the [prototype](https://p.superdesign.dev/draft/49d994d1-e518-46a2-922a-baf7dc203fa4). Use English throughout new theme controls and documentation.

| Token | Dark | Light |
| --- | --- | --- |
| Background | `#09090b` | `#fafafa` |
| Surface | `#18181b` | `#f4f4f5` |
| Border | `#27272a` | `#e4e4e7` |
| Text | `#e4e4e7` | `#18181b` |
| Secondary text | `#a1a1aa` | `#52525b` |
| Accent text | `#00d294` | `#007a53` |
| Accent fill | `#00bb7f` | `#00bb7f` |

Use system sans-serif for controls and system monospace for addresses, numbers, and logs. Keep text readable at 14px, borders thin, and corners between 6px and 8px. Avoid decorative gradients, blur, large shadows, and remote fonts.

Preserve LuCI's native pages and permission checks. Forms, validation messages, dropdowns, tables, and dialogs must remain usable with third-party applications such as Podkop.

On mobile, collapse navigation into a drawer, keep touch targets at least 44px, and scroll wide tables inside their own container. Logs should wrap long messages and allow text selection.

The prototype's connection list, log filters, and failover history are simulated. Do not present them as implemented features of the theme.
