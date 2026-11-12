---
name: manual-style-green
description: Use when designing or writing a printable user manual, setup guide or cheat sheet in the green edition of the File Commander booklet style: sage paper, signal-green accent, forest and lime tags.
---

# Manual style guide — Green edition

The visual system of the File Commander user manual, recoloured in green. Layout, typography, components and voice are identical to the original (orange) edition; only the colour tokens and the colour rules that depend on them change. Everything here maps onto `assets/template.html` — swap the `:root` tokens listed in section 3 and the hard-coded hex values listed in section 11, and the template renders in this edition.

## Contents

1. Design DNA
2. Page setup
3. Colour tokens
4. Typography
5. Signature elements
6. Components (with when-to-use)
7. Icons and diagrams
8. Screenshots
9. Page structure and voice
10. Layout pitfalls and fixes
11. Converting the orange template

---

## 1. Design DNA

A calm, printed-booklet feel with a retro-computing wink — now on sage paper with a signal-green accent.

- **Sage paper, not white.** Every page, including margins, is `#ecf0e6`, a pale paper with a faint green cast. Cards and callouts sit on a slightly lighter `#f7f9f3`, like paper on paper.
- **Ink, not grey.** Text and rules are a green-black ink `#161c18`. Grey-green `#5f6a62` is only for secondary text (leads, captions, card descriptions, footer).
- **One loud colour.** Signal green `#138a43` marks what to look at first: the pixel word, eyebrows, step and contents numerals, the main callout. Forest `#0f5132` and lime `#b8d43a` appear only in small tags, code-block labels and the warning callout.
- **Pixel word.** Each page headline ends with (or contains) one word drawn in a green 5×7 pixel font. It is the brand's fingerprint — never skip it, never use two per headline.
- **Hard shadows.** Raised things (screenshots, callouts, code blocks, diagram cards) get a solid offset shadow down-right, zero blur, in a green-grey tint. Nothing has a soft drop shadow.
- **Square bullets, thick rules.** List bullets are small solid squares; table headers sit on a 0.7 mm ink rule; trio columns start with a 0.8 mm ink bar.
- **Letter-spaced uppercase micro-labels** (eyebrows, table headers, tags, footer) at 6.5–7.5 pt with 0.2–0.26 em tracking.
- **Air.** Generous margins, one topic per page, never crowded.

## 2. Page setup

| Property | Value |
|---|---|
| Size | A4 portrait |
| Margins | 20 mm top, 20 mm sides, 24 mm bottom |
| Page background | `#ecf0e6` set in `@page` (so margins are paper-coloured too) plus `print-color-adjust: exact` |
| Footer left | product label, e.g. `FILE COMMANDER · USER MANUAL`: Avenir Next 7 pt, tracking .22em, muted |
| Footer right | page number, Avenir Next 700, 8.5 pt, ink |
| Cover | `@page :first` has zero margin and no footer |
| Page breaks | every `section.page` breaks before; `h1`/`h2` avoid breaking after; tables, figures, notes, cards and steps avoid breaking inside |

Built with Chrome: `--headless=new --no-pdf-header-footer --print-to-pdf`.

## 3. Colour tokens

| Token          | Hex       | Replaces (orange edition) | Used for                                                                      |
| -------------- | --------- | ------------------------- | ----------------------------------------------------------------------------- |
| `--bg`         | `#ecf0e6` | `#f0ede4`                 | page / paper                                                                  |
| `--card`       | `#f7f9f3` | `#faf7f0`                 | cards, callouts, keycaps, diagram cards                                       |
| `--ink`        | `#161c18` | `#1a1a18`                 | text, rules, outlines, dark code background, ink tag                          |
| `--muted`      | `#5f6a62` | `#6b6a63`                 | lead text, captions, card descriptions, footer label                          |
| `--line`       | `#cfd8cb` | `#d9d4c7`                 | thin row dividers (0.25 mm)                                                   |
| `--accent`     | `#138a43` | `#ff5a1f`                 | pixel words, eyebrows, numerals, main callout border + shadow, icon highlight |
| `--forest`     | `#0f5132` | `--green` `#2e8b57`       | `CORE` tag                                                                    |
| `--lime`       | `#b8d43a` | `--amber` `#f0a030`       | `EXTENDED` / `TIME SAVER` tag, code-block labels, warning callout             |
| inline code bg | `#dde5d7` | `#e6e2d6`                 | `code` chips                                                                  |
| figure shadow  | `#bccab7` | `#c9c4b6`                 | screenshot / diagram offset shadow                                            |
| code shadow    | `#a9b8a5` | `#b9b4a6`                 | dark code-block offset shadow                                                 |
| code text      | `#eef3ea` | `#f4f1e8`                 | text inside dark code blocks                                                  |

Keep the accent rare: if more than three or four green things compete on a page, demote some to ink.

**Why these greens.** The accent `#138a43` is a saturated, slightly blue-leaning green, so it reads as "signal" against the yellow-leaning sage paper instead of blending into it. It has 3.8:1 contrast on paper and 4.2:1 on cards — better than the orange edition's 2.7:1. Forest and lime sit either side of it in lightness, so the three tag colours stay distinct even though they share a hue. White on forest is 9.4:1; ink on lime is 10.3:1.

**Warnings without amber.** Lime takes over amber's job. Because lime is close to the accent's hue, the warning callout relies on its bold lead-in sentence ("**Back up first.** …") as much as on colour — never leave a lime callout without one.

## 4. Typography

Unchanged from the orange edition except for the colour column.

Font stack: `"Avenir Next", "Avenir", -apple-system, "Helvetica Neue", sans-serif`. Monospace: `"SF Mono", Menlo, monospace`.

| Element | Size / weight / tracking |
|---|---|
| Body | 9.8 pt / 1.55 line height |
| Cover title | 64 pt, 700, −0.035em, line height 1 |
| Cover pixel word | 64 pt font-size with `data-h="1.0"` (pixel height = 1 em) |
| Cover subtitle | 11.5 pt, ink, max-width 118 mm |
| Page title `h1` | 25 pt, 700, −0.025em, line height 1.12 |
| `h2` | 13 pt, 700, −0.01em, 8 mm space above |
| Lead paragraph | 11.5 pt, muted, max-width 150 mm |
| Eyebrow | 7.5 pt, 700, uppercase, .26em, green accent |
| Table header | 6.8 pt, 700, uppercase, .22em, ink |
| Table body | 9.3 pt |
| Tag | 6.5 pt, 700, .2em, white on forest / ink on lime / white on ink |
| Caption | 8 pt, muted |
| Keycap | SF Mono 700, 8 pt |
| Inline code | SF Mono 8.8 pt |
| Code block | SF Mono 8.6 pt / 1.55 |
| Step numeral | 14 pt, 700, green accent |
| Contents numeral | 15 pt, 700, green accent; entry 12 pt 600 |

## 5. Signature elements

**Pixel word** — `<span class="px">WORD</span>`. A script turns the text into an SVG of 5×7 squares (each cell 0.94 of a unit, so hairline gaps show between pixels), filled with the green accent `#138a43`. Default height 0.8 em, inline with the headline; override with `data-h`. Supported: A–Z, 0–9, `- . ! ? &` and space. Choose a word that completes the headline's meaning: "Getting STARTED", "Make it YOURS", "Rules and ANSWERS". On the cover it is the product's second word, set on its own line under the bold first word ("File" / COMMANDER).

**Eyebrow** — small green line above every page title: `01 · Overview`, optionally followed by a tag. The cover eyebrow reads `A USER MANUAL · VERSION 1.0` (or `A SETUP MANUAL · <MONTH YEAR>`).

**Tags** — tiny pills after the eyebrow marking the kind of section: forest `CORE` (essentials), lime `EXTENDED` / `TIME SAVER` (optional extras), ink `PRINT ME` / `ONCE` (reference or one-off).

**Hard shadows** — screenshot/diagram: 0.4 mm ink border, 2.5 mm radius, `1.6mm 1.6mm 0 #bccab7`. Callout: 0.5 mm border, 3 mm radius, `1.8mm 1.8mm 0` in the border colour. Code block: `1.5mm 1.5mm 0 #a9b8a5`. Elements with a shadow get a right margin of ~1.5–1.8 mm so the shadow is not clipped.

**Keycaps** — `<kbd>`: card background, 0.3 mm ink border with a thicker 0.6 mm bottom edge (looks pressable), 1.2 mm radius. Write combinations as separate keys: `<kbd>⌘</kbd><kbd>P</kbd>`, or with a `+` between when the sentence reads better.

**Square bullets** — `ul li::before` is a 1.6 mm solid ink square.

## 6. Components

All of these are live in the template. Use the class names exactly.

| Component | Markup | Use it for |
|---|---|---|
| Cover | `section.cover` with `.logo`, `.eyebrow`, `h1`, `.px.px-big`, `.sub`, `.rule`, `.foot` | First page. Logo top-right 17 mm (app icon `img/icon.png`, or an inline SVG icon in the card style). Content vertically centred. |
| Contents | `ol.toc` with `<li>Title <small>one-line description</small></li>` | Page 2. Numbers come from CSS. |
| Section opener | `.eyebrow` + `h1` with pixel word + optional `p.lead` | Top of every section page. |
| Steps | `ol.steps > li > div` | Any ordered procedure. Big green numerals, thin dividers. Code blocks may sit inside a step. Continue numbering after an interruption with `<ol class="steps" start="5">`. |
| Table | `table` with `th` header row | Key/action lists, settings, troubleshooting. First column is `nowrap`, 42 mm wide — ideal for keys and short labels. |
| Wrapping table | `table.wrap` | When first-column labels are long phrases (setting names, problems). Allows wrapping, 52 mm wide. |
| Inline code | `<code>` | File names, commands, values. |
| Code block | `<pre data-label="BUILD IT">…</pre>` | Commands to type. The label prints in lime caps above the code. |
| Callout | `.note` (green), `.note.ink`, `.note.lime` | Green: the one thing not to miss on the page. Ink: a calm tip or safety net. Lime: warnings and gotchas. Start with a bold lead-in sentence: `<b>Settings are kept for you.</b> …`. Max one or two per page. |
| Cards | `.cards` (3-up) or `.cards.two` with `.card` → `svg` + `b` + `span` | Three headline features in the overview; side-by-side options. Bold inside the description: plain `<b>` inside the `span` (the stylesheet keeps it inline). |
| Trio | `.trio > div > h4 + ul` | Three short fact columns (requirements, platform notes). Green uppercase `h4`, thick ink bar on top. |
| Figure | `figure > img + figcaption`; `figure.sm` for 60 % width | Screenshots. |
| Pair | `.pair` with two figures | Before/after, two states, two themes. |
| Diagram | `figure > .diagram > svg` + `figcaption` | Architecture or flow drawn inline. Same frame and shadow as screenshots, card background. |
| Cheat sheet | `section.page.sheet` + `.cols` (two columns of `h2` + compact tables) | One printable reference page. |
| Closing line | `<p style="margin-top:5mm;font-size:9pt;color:var(--muted)">` | Product · version · platform · repo, at the end of the last page. |

Keep `.note.amber` as an alias of `.note.lime` in the stylesheet, so manuals written for the orange edition still render.

## 7. Icons and diagrams

**Card icons** — inline SVG, `viewBox="0 0 48 48"`, `fill="none" stroke="#161c18" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"`. Simple line drawings of the concept (panels, keyboard, bin, lock, devices). Exactly **one** element in green (`#138a43`, stroke or fill) as the highlight — the selected row, the key being pressed, the lid of the bin. Rendered at 11 mm.

**Diagrams** — inline SVG inside `.diagram`. Use the same vocabulary: rounded rectangles in card colour with 2 px ink stroke and bold 13 px labels; one dark ink block (`#161c18`, radius 10) for the central system with a lime letter-spaced label and light text; ink connector lines with small solid arrowheads; at most one green pill label. Font family Avenir Next in the SVG. Keep diagrams sparse — five to eight shapes.

## 8. Screenshots

- Put them in `img/`, PNG, captured at 2× so they stay sharp in print.
- Default full width; `figure.sm` (60 %) or an inline `style="width:52%"` on the `img` for tall or simple screens, so a page fits a figure plus explanation.
- Always add a one-sentence `figcaption` saying what to notice.
- When there are no real screenshots (for a third-party app, say), prefer a diagram, a settings table, or icon cards over mock screenshots.
- Screenshots of apps with a strong green UI can merge with the accent; if that happens, keep the figure's ink border and let the caption carry the "what to notice" rather than adding more green.

## 9. Page structure and voice

**Section page pattern:** eyebrow (`NN · Name` + tag) → `h1` with pixel word → lead paragraph (optional) → content blocks under `h2`s → at most one or two callouts.

**Contents** lists sections 1…N with a short description each, right-aligned and muted.

**Voice:** plain, direct, second person ("Press **F5** to copy."). Short sentences. Bold the UI labels the reader must find (`<b>Settings › Remotely Save</b>`), using `›` for menu paths. Name things exactly as the UI does. Each callout opens with a bold summary sentence. Troubleshooting is a two-column table: *Problem* in the reader's words, *What to do* as an instruction.

**Cover subtitle:** one or two sentences — what it is and what the manual covers.

## 10. Layout pitfalls and fixes

| Symptom (seen in the rendered PDF) | Fix |
|---|---|
| A section spills one callout or one step onto an otherwise empty page | Tighten that section: merge a short `h2` into the lead, fold a two-step list into a sentence, collapse related table rows into one, shrink a figure with `.sm`. Or move the callout earlier. Do not shrink the base font. |
| Bold words inside a card description jump to their own line | Make sure the stylesheet still has `.card span b { display: inline; … }` (the template does). |
| First table column too wide, text crushed on the right | Use `table.wrap`, or shorten the labels. |
| Gap or missing letter in a pixel word | Character not in the pixel font; reword using A–Z, 0–9, `- . ! ? &`. |
| Shadow cut off at the right edge | Keep the ~1.5–1.8 mm right margin on elements with shadows (the template sets it). |
| Colours missing in the PDF | Keep `-webkit-print-color-adjust: exact; print-color-adjust: exact` on `html`. |
| Images missing | Paths are relative to `manual.html`; build from the file URL as `build.sh` does. |
| Heading stranded at the bottom of a page | `h2 { break-after: avoid }` is set; if it still happens, add `style="break-before:page"` to that `h2`, as the original does for long sections. |
| Leftover orange in the PDF | A hex value was hard-coded outside `:root` — search the template for the values in section 11. |

## 11. Converting the orange template

1. Replace the `:root` block in `assets/template.html` with:

```css
:root {
  --bg: #ecf0e6;
  --card: #f7f9f3;
  --ink: #161c18;
  --muted: #5f6a62;
  --line: #cfd8cb;
  --accent: #138a43;
  --forest: #0f5132;
  --lime: #b8d43a;
  --green: var(--forest);  /* old name, kept for compatibility */
  --amber: var(--lime);    /* old name, kept for compatibility */
}
```

2. Search the template (and any manual's inline SVGs) for these hard-coded values and replace them:

| Find | Replace with |
|---|---|
| `#ff5a1f` | `#138a43` |
| `#1a1a18` | `#161c18` |
| `#f0ede4` | `#ecf0e6` |
| `#faf7f0` | `#f7f9f3` |
| `#e6e2d6` | `#dde5d7` |
| `#c9c4b6` | `#bccab7` |
| `#b9b4a6` | `#a9b8a5` |
| `#f4f1e8` | `#eef3ea` |
| `#2e8b57` | `#0f5132` |
| `#f0a030` | `#b8d43a` |

3. Check that the pixel-word script reads its fill from `--accent` (or replace its hard-coded orange with `#138a43`).
4. Render one PDF and look for anything still orange — usually a card icon's highlight stroke.
