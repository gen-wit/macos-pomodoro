---
name: manual-style-orange
description: Use when designing or writing a printable user manual, setup guide or cheat sheet in the orange File Commander booklet style: warm paper, signal-orange accent, pixel-word headlines, hard shadows.
---

# Manual style guide

The visual system of the File Commander user manual, written down so any manual can reproduce it exactly. Everything here is already implemented in `assets/template.html`; this file explains *what* each piece is, *when* to use it, and *why* it looks the way it does.

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

---

## 1. Design DNA

A calm, printed-booklet feel with a retro-computing wink.

- **Warm paper, not white.** Every page, including margins, is `#f0ede4`. Cards and callouts sit on a slightly lighter `#faf7f0`, like paper on paper.
- **Ink, not grey.** Text and rules are near-black `#1a1a18`. Grey `#6b6a63` is only for secondary text (leads, captions, card descriptions, footer).
- **One loud colour.** Signal orange `#ff5a1f` marks what to look at first: the pixel word, eyebrows, step and contents numerals, the main callout. Green and amber appear only in small tags and code-block labels.
- **Pixel word.** Each page headline ends with (or contains) one word drawn in an orange 5×7 pixel font. It is the brand's fingerprint — never skip it, never use two per headline.
- **Hard shadows.** Raised things (screenshots, callouts, code blocks, diagram cards) get a solid offset shadow down-right, zero blur. Nothing has a soft drop shadow.
- **Square bullets, thick rules.** List bullets are small solid squares; table headers sit on a 0.7 mm ink rule; trio columns start with a 0.8 mm ink bar.
- **Letter-spaced uppercase micro-labels** (eyebrows, table headers, tags, footer) at 6.5–7.5 pt with 0.2–0.26 em tracking.
- **Air.** Generous margins, one topic per page, never crowded.

## 2. Page setup

| Property | Value |
|---|---|
| Size | A4 portrait |
| Margins | 20 mm top, 20 mm sides, 24 mm bottom |
| Page background | `#f0ede4` set in `@page` (so margins are paper-coloured too) plus `print-color-adjust: exact` |
| Footer left | product label, e.g. `FILE COMMANDER · USER MANUAL`: Avenir Next 7 pt, tracking .22em, muted |
| Footer right | page number, Avenir Next 700, 8.5 pt, ink |
| Cover | `@page :first` has zero margin and no footer |
| Page breaks | every `section.page` breaks before; `h1`/`h2` avoid breaking after; tables, figures, notes, cards and steps avoid breaking inside |

Built with Chrome: `--headless=new --no-pdf-header-footer --print-to-pdf`.

## 3. Colour tokens

| Token          | Hex       | Used for                                                                      |
| -------------- | --------- | ----------------------------------------------------------------------------- |
| `--bg`         | `#f0ede4` | page / paper                                                                  |
| `--card`       | `#faf7f0` | cards, callouts, keycaps, diagram cards                                       |
| `--ink`        | `#1a1a18` | text, rules, outlines, dark code background, ink tag                          |
| `--muted`      | `#6b6a63` | lead text, captions, card descriptions, footer label                          |
| `--line`       | `#d9d4c7` | thin row dividers (0.25 mm)                                                   |
| `--accent`     | `#ff5a1f` | pixel words, eyebrows, numerals, main callout border + shadow, icon highlight |
| `--green`      | `#2e8b57` | `CORE` tag                                                                    |
| `--amber`      | `#f0a030` | `EXTENDED` / `TIME SAVER` tag, code-block labels, warning callout             |
| inline code bg | `#e6e2d6` | `code` chips                                                                  |
| figure shadow  | `#c9c4b6` | screenshot / diagram offset shadow                                            |
| code shadow    | `#b9b4a6` | dark code-block offset shadow                                                 |
| code text      | `#f4f1e8` | text inside dark code blocks                                                  |

Keep orange rare: if more than three or four orange things compete on a page, demote some to ink.

## 4. Typography

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
| Eyebrow | 7.5 pt, 700, uppercase, .26em, orange |
| Table header | 6.8 pt, 700, uppercase, .22em, ink |
| Table body | 9.3 pt |
| Tag | 6.5 pt, 700, .2em, white on green / ink on amber / white on ink |
| Caption | 8 pt, muted |
| Keycap | SF Mono 700, 8 pt |
| Inline code | SF Mono 8.8 pt |
| Code block | SF Mono 8.6 pt / 1.55 |
| Step numeral | 14 pt, 700, orange |
| Contents numeral | 15 pt, 700, orange; entry 12 pt 600 |

## 5. Signature elements

**Pixel word** — `<span class="px">WORD</span>`. A script turns the text into an SVG of 5×7 squares (each cell 0.94 of a unit, so hairline gaps show between pixels), filled orange. Default height 0.8 em, inline with the headline; override with `data-h`. Supported: A–Z, 0–9, `- . ! ? &` and space. Choose a word that completes the headline's meaning: "Getting STARTED", "Make it YOURS", "Rules and ANSWERS". On the cover it is the product's second word, set on its own line under the bold first word ("File" / COMMANDER).

**Eyebrow** — small orange line above every page title: `01 · Overview`, optionally followed by a tag. The cover eyebrow reads `A USER MANUAL · VERSION 1.0` (or `A SETUP MANUAL · <MONTH YEAR>`).

**Tags** — tiny pills after the eyebrow marking the kind of section: green `CORE` (essentials), amber `EXTENDED` / `TIME SAVER` (optional extras), ink `PRINT ME` / `ONCE` (reference or one-off).

**Hard shadows** — screenshot/diagram: 0.4 mm ink border, 2.5 mm radius, `1.6mm 1.6mm 0 #c9c4b6`. Callout: 0.5 mm accent border, 3 mm radius, `1.8mm 1.8mm 0` in the border colour. Code block: `1.5mm 1.5mm 0 #b9b4a6`. Elements with a shadow get a right margin of ~1.5–1.8 mm so the shadow is not clipped.

**Keycaps** — `<kbd>`: card background, 0.3 mm ink border with a thicker 0.6 mm bottom edge (looks pressable), 1.2 mm radius. Write combinations as separate keys: `<kbd>⌘</kbd><kbd>P</kbd>`, or with a `+` between when the sentence reads better.

**Square bullets** — `ul li::before` is a 1.6 mm solid ink square.

## 6. Components

All of these are live in the template. Use the class names exactly.

| Component | Markup | Use it for |
|---|---|---|
| Cover | `section.cover` with `.logo`, `.eyebrow`, `h1`, `.px.px-big`, `.sub`, `.rule`, `.foot` | First page. Logo top-right 17 mm (app icon `img/icon.png`, or an inline SVG icon in the card style). Content vertically centred. |
| Contents | `ol.toc` with `<li>Title <small>one-line description</small></li>` | Page 2. Numbers come from CSS. |
| Section opener | `.eyebrow` + `h1` with pixel word + optional `p.lead` | Top of every section page. |
| Steps | `ol.steps > li > div` | Any ordered procedure. Big orange numerals, thin dividers. Code blocks may sit inside a step. Continue numbering after an interruption with `<ol class="steps" start="5">`. |
| Table | `table` with `th` header row | Key/action lists, settings, troubleshooting. First column is `nowrap`, 42 mm wide — ideal for keys and short labels. |
| Wrapping table | `table.wrap` | When first-column labels are long phrases (setting names, problems). Allows wrapping, 52 mm wide. |
| Inline code | `<code>` | File names, commands, values. |
| Code block | `<pre data-label="BUILD IT">…</pre>` | Commands to type. The label prints in amber caps above the code. |
| Callout | `.note` (orange), `.note.ink`, `.note.amber` | Orange: the one thing not to miss on the page. Ink: a calm tip or safety net. Amber: warnings and gotchas. Start with a bold lead-in sentence: `<b>Settings are kept for you.</b> …`. Max one or two per page. |
| Cards | `.cards` (3-up) or `.cards.two` with `.card` → `svg` + `b` + `span` | Three headline features in the overview; side-by-side options. Bold inside the description: plain `<b>` inside the `span` (the stylesheet keeps it inline). |
| Trio | `.trio > div > h4 + ul` | Three short fact columns (requirements, platform notes). Orange uppercase `h4`, thick ink bar on top. |
| Figure | `figure > img + figcaption`; `figure.sm` for 60 % width | Screenshots. |
| Pair | `.pair` with two figures | Before/after, two states, two themes. |
| Diagram | `figure > .diagram > svg` + `figcaption` | Architecture or flow drawn inline. Same frame and shadow as screenshots, card background. |
| Cheat sheet | `section.page.sheet` + `.cols` (two columns of `h2` + compact tables) | One printable reference page. |
| Closing line | `<p style="margin-top:5mm;font-size:9pt;color:var(--muted)">` | Product · version · platform · repo, at the end of the last page. |

## 7. Icons and diagrams

**Card icons** — inline SVG, `viewBox="0 0 48 48"`, `fill="none" stroke="#1a1a18" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"`. Simple line drawings of the concept (panels, keyboard, bin, lock, devices). Exactly **one** element in orange (`#ff5a1f`, stroke or fill) as the highlight — the selected row, the key being pressed, the lid of the bin. Rendered at 11 mm.

**Diagrams** — inline SVG inside `.diagram`. Use the same vocabulary: rounded rectangles in card colour with 2 px ink stroke and bold 13 px labels; one dark ink block (`#1a1a18`, radius 10) for the central system with an amber letter-spaced label and light text; ink connector lines with small solid arrowheads; at most one orange pill label. Font family Avenir Next in the SVG. Keep diagrams sparse — five to eight shapes.

## 8. Screenshots

- Put them in `img/`, PNG, captured at 2× so they stay sharp in print.
- Default full width; `figure.sm` (60 %) or an inline `style="width:52%"` on the `img` for tall or simple screens, so a page fits a figure plus explanation.
- Always add a one-sentence `figcaption` saying what to notice.
- When there are no real screenshots (for a third-party app, say), prefer a diagram, a settings table, or icon cards over mock screenshots.

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
