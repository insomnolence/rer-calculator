# Brand pack

This folder is an optional, **gitignored** override for the app's visual
identity. Only this README and `.gitkeep` are tracked; everything else you put
here stays on your machine and can never be pushed by accident.

With no pack present the app renders the neutral identity defined by
`Brand.generic` in `lib/branding.dart`. Add a `brand.json` here and the app
picks it up at startup instead:

```json
{
  "appTitle": "RER Calculator",
  "primary": "#00A3E0",
  "secondary": "#8DC63F",
  "background": "#BAE9FC",
  "wordmark": "assets/brand/wordmark.png",
  "icon": "assets/brand/icon.png"
}
```

| Key          | Meaning                                                  |
| ------------ | -------------------------------------------------------- |
| `appTitle`   | Window / app bar title                                    |
| `primary`    | App bar, focus rings, drawn logo                          |
| `secondary`  | Accent colour                                             |
| `background` | Scaffold background                                       |
| `wordmark`   | Wide logo above the calculator. Omit to draw the built-in |
| `icon`       | Square app bar mark. Omit to draw the built-in paw        |

Colours accept `#RRGGBB`, `#AARRGGBB` or `0xAARRGGBB`. Any key you leave out
falls back to the generic value, and a malformed file falls back entirely --
the app will still open.

Assets are bundled at build time, so run `flutter run` again after adding or
changing files here.
