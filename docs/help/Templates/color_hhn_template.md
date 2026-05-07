# HHN Corporate Blue Farbpalette

Diese Farbpalette ist aus der bereitgestellten **HHN-PowerPoint-Vorlage** und dem offiziellen Auftritt der **Hochschule Heilbronn** abgeleitet. Sie kombiniert das klassische **HHN-Dunkelblau** mit kühlen **Cyan- und Petrol-Tönen**, neutralen Grauwerten und sparsamen Akzentfarben für Diagramme, Markierungen und Präsentationen.

## Farben

| Name | Farbe | Hex | RGB | Verwendungsidee |
|---|---:|---|---|---|
| HHN Dark Blue | ![#002896](https://placehold.co/24x24/002896/002896.png) | `#002896` | `rgb(0, 40, 150)` | Hauptfarbe, Titelfolien, Logos, seriöser Hochschulauftritt |
| HHN Blue Medium | ![#667ec0](https://placehold.co/24x24/667ec0/667ec0.png) | `#667ec0` | `rgb(102, 126, 192)` | Sekundärblau, Zwischenflächen, Diagramme, dezente Hervorhebung |
| HHN Blue Light | ![#99a8d6](https://placehold.co/24x24/99a8d6/99a8d6.png) | `#99a8d6` | `rgb(153, 168, 214)` | Helle Flächen, Infoboxen, ruhige Hintergründe |
| HHN Cyan | ![#009fd5](https://placehold.co/24x24/009fd5/009fd5.png) | `#009fd5` | `rgb(0, 159, 213)` | Frischer Akzent, technische Themen, Links, Callouts |
| HHN Teal | ![#009ba6](https://placehold.co/24x24/009ba6/009ba6.png) | `#009ba6` | `rgb(0, 155, 166)` | Akzentfarbe, Kapiteltrenner, Icons, Diagrammfarbe |
| HHN Petrol | ![#00727f](https://placehold.co/24x24/00727f/00727f.png) | `#00727f` | `rgb(0, 114, 127)` | Dunkler Sekundärton, Footer, technische Sektionen, Kontrastflächen |
| Light Cyan | ![#60c6ef](https://placehold.co/24x24/60c6ef/60c6ef.png) | `#60c6ef` | `rgb(96, 198, 239)` | Heller Akzent, Diagramme, Flächen mit freundlicher Wirkung |
| Light Teal | ![#7fcbd3](https://placehold.co/24x24/7fcbd3/7fcbd3.png) | `#7fcbd3` | `rgb(127, 203, 211)` | Sekundärer heller Akzent, Hintergrundflächen, Infografiken |
| HHN Orange | ![#ff9e00](https://placehold.co/24x24/ff9e00/ff9e00.png) | `#ff9e00` | `rgb(255, 158, 0)` | Warmer Akzent, Highlights, wichtige Zahlen, sparsam einsetzen |
| HHN Yellow | ![#ffcb0e](https://placehold.co/24x24/ffcb0e/ffcb0e.png) | `#ffcb0e` | `rgb(255, 203, 14)` | Aufmerksamkeit, Marker, Status, Diagramm-Kontrast |
| HHN Green | ![#64b32c](https://placehold.co/24x24/64b32c/64b32c.png) | `#64b32c` | `rgb(100, 179, 44)` | Positive Werte, Nachhaltigkeit, SmartGrow/HydroBox, Erfolg |
| HHN Lime | ![#b4cc00](https://placehold.co/24x24/b4cc00/b4cc00.png) | `#b4cc00` | `rgb(180, 204, 0)` | Frischer Pflanzen-/Innovationsakzent, Diagramme, sekundäre Highlights |
| HHN Berry | ![#ab0042](https://placehold.co/24x24/ab0042/ab0042.png) | `#ab0042` | `rgb(171, 0, 66)` | Starker Kontrast, Warnung, kritische Punkte, sehr sparsam einsetzen |
| HHN Pink | ![#dc3769](https://placehold.co/24x24/dc3769/dc3769.png) | `#dc3769` | `rgb(220, 55, 105)` | Diagrammfarbe, Highlight, kreative Akzente |
| Dark Gray | ![#747474](https://placehold.co/24x24/747474/747474.png) | `#747474` | `rgb(116, 116, 116)` | Fließtext, Subheadlines, Footer-Text |
| Light Gray | ![#bcbcbc](https://placehold.co/24x24/bcbcbc/bcbcbc.png) | `#bcbcbc` | `rgb(188, 188, 188)` | Linien, Trennflächen, dezente Rahmen |
| White | ![#ffffff](https://placehold.co/24x24/ffffff/ffffff.png) | `#ffffff` | `rgb(255, 255, 255)` | Hintergrund, Negativlogo, Text auf dunklen Flächen |
| Black | ![#000000](https://placehold.co/24x24/000000/000000.png) | `#000000` | `rgb(0, 0, 0)` | Maximaler Kontrast, selten für reinen Text verwenden |

## CSS-Variablen

```css
:root {
  --color-hhn-blue: #002896;
  --color-hhn-blue-medium: #667ec0;
  --color-hhn-blue-light: #99a8d6;
  --color-hhn-cyan: #009fd5;
  --color-hhn-teal: #009ba6;
  --color-hhn-petrol: #00727f;
  --color-light-cyan: #60c6ef;
  --color-light-teal: #7fcbd3;
  --color-hhn-orange: #ff9e00;
  --color-hhn-yellow: #ffcb0e;
  --color-hhn-green: #64b32c;
  --color-hhn-lime: #b4cc00;
  --color-hhn-berry: #ab0042;
  --color-hhn-pink: #dc3769;
  --color-dark-gray: #747474;
  --color-light-gray: #bcbcbc;
  --color-white: #ffffff;
  --color-black: #000000;
}
```

## Tailwind-orientierte Benennung

```css
colors: {
  hhnblue: "#002896",
  hhnbluemedium: "#667ec0",
  hhnbluelight: "#99a8d6",
  hhncyan: "#009fd5",
  hhnteal: "#009ba6",
  hhnpetrol: "#00727f",
  lightcyan: "#60c6ef",
  lightteal: "#7fcbd3",
  hhnorange: "#ff9e00",
  hhnyellow: "#ffcb0e",
  hhngreen: "#64b32c",
  hhnlime: "#b4cc00",
  hhnberry: "#ab0042",
  hhnpink: "#dc3769",
  darkgray: "#747474",
  lightgray: "#bcbcbc",
  white: "#ffffff",
  black: "#000000",
}
```

## Mögliche Rollen im Design

| Rolle | Farbe |
|---|---|
| Primary | `#002896` HHN Dark Blue |
| Primary Soft | `#667ec0` HHN Blue Medium |
| Primary Light | `#99a8d6` HHN Blue Light |
| Secondary / Technical | `#009fd5` HHN Cyan |
| Secondary Dark | `#00727f` HHN Petrol |
| Accent Cool | `#009ba6` HHN Teal |
| Accent Warm | `#ff9e00` HHN Orange |
| Highlight / Marker | `#ffcb0e` HHN Yellow |
| Positive / Sustainability | `#64b32c` HHN Green |
| Fresh / Growth | `#b4cc00` HHN Lime |
| Alert / Critical | `#ab0042` HHN Berry |
| Creative Accent | `#dc3769` HHN Pink |
| Text Secondary | `#747474` Dark Gray |
| Lines / Borders | `#bcbcbc` Light Gray |
| Background | `#ffffff` White |

## Beispiel-Kombination für HHN-Präsentationen

- **Seriöser Hochschulauftritt:** `#002896`, `#ffffff`, `#747474`, `#bcbcbc`
- **Technik und Forschung:** `#002896`, `#009fd5`, `#00727f`, `#60c6ef`
- **Innovation und Transfer:** `#002896`, `#009ba6`, `#ff9e00`, `#ffcb0e`
- **Nachhaltigkeit / SmartGrow / HydroBox:** `#002896`, `#64b32c`, `#b4cc00`, `#009ba6`
- **Diagramme mit mehreren Kategorien:** `#002896`, `#009fd5`, `#00727f`, `#ff9e00`, `#64b32c`, `#dc3769`
- **Warnung oder kritischer Punkt:** `#ab0042` nur sparsam verwenden

## Mini Style Guide

```css
body {
  background-color: #ffffff;
  color: #747474;
}

.slide-title {
  background-color: #002896;
  color: #ffffff;
}

.section-header {
  background-color: #00727f;
  color: #ffffff;
}

.button-primary {
  background-color: #002896;
  color: #ffffff;
}

.button-secondary {
  background-color: #009fd5;
  color: #ffffff;
}

.accent-bar {
  background-color: #009ba6;
}

.highlight-warm {
  color: #ff9e00;
}

.highlight-positive {
  color: #64b32c;
}

.alert {
  color: #ab0042;
}

.card-soft {
  background-color: #f7f8fb;
  border: 1px solid #bcbcbc;
}
```

## Empfehlung für Präsentationsfolien

| Folientyp | Hintergrund | Headline | Akzent | Text |
|---|---|---|---|---|
| Titelfolie | `#002896` | `#ffffff` | `#009fd5` oder `#ff9e00` | `#ffffff` |
| Inhaltsfolie | `#ffffff` | `#002896` | `#009ba6` | `#747474` |
| Kapiteltrenner | `#00727f` | `#ffffff` | `#7fcbd3` | `#ffffff` |
| Technische Folie | `#ffffff` | `#002896` | `#009fd5` | `#747474` |
| Diagrammfolie | `#ffffff` | `#002896` | mehrere Akzentfarben | `#747474` |
| Warn-/Problemfolie | `#ffffff` | `#002896` | `#ab0042` | `#747474` |
