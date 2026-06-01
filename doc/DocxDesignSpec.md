# DocxDesignSpec — Document Design and Typography for Learning Materials

**Version:** 1.0
**Applies to:** All student-facing `.docx` files produced by the pipeline
**Skill:** `anthropic-skills:docx`

---

## Purpose

This spec governs the visual design, typography, structure, and prose style of every Word
document delivered to students. Every generator that invokes `anthropic-skills:docx` for a
student-facing artifact MUST follow these rules.

**Governing principle:** Student-facing content must be concise and include ONLY training
material the student should read to learn. All administrative, pedagogical, and pipeline
references must never be presented to the student. If it does not help the student learn
the subject matter, it does not belong in a student-facing document.

**Applicable artifacts:** chapter docs, exercise briefs, exercise walkthroughs, exercise debriefs,
cheatsheets, quiz question/answer documents, capstone lab briefs, capstone debriefs, glossary.

**Not applicable to:** internal pipeline files (handoff JSON, manifest JSON, quiz JSON, YAML),
instructor guides (which may retain internal references), speaker-notes docs (which are
instructor-facing and may retain pedagogical metadata).

---

## 1. Document Structure and Hierarchy

### 1.1 Eliminate Technical Structural Characters

Do not use the section symbol (§) in headings, section markers, or any student-visible text.
Rely entirely on clean typography and clear heading hierarchy to distinguish sections.

| FORBIDDEN | REQUIRED |
|-----------|----------|
| § 5 The Automation Suitability Framework | The Automation Suitability Framework |
| § 3.2 Core Concepts | Core Concepts |

### 1.2 Remove Internal System Reference Codes

Eliminate all internal tracking IDs, alphanumeric abbreviations, and pipeline metadata from
student-facing text:

- **LO-IDs**: `LO-03.1`, `LO-07.2` must NEVER appear in student-facing content
- **Chapter slugs**: `ch02-automation-mindset` must be converted to clean titles
- **Section IDs**: `3.2`, `5.1` must not prefix headings (use heading levels instead)
- **Bloom tags**: `[Apply]`, `[Remember]`, `(Understand)` must NEVER appear in student text
- **Item IDs**: `ch03-q01`, `ex-02` must not appear in student-facing exercise or quiz text

Label objectives naturally within prose:

| FORBIDDEN | REQUIRED |
|-----------|----------|
| LO-03.1 (Remember): Recall and define... | **Learning Outcome:** Recall and define... |
| ch02-automation-mindset | The Automation Mindset |
| Exercise ch03-ex02 | Exercise 2 |

### 1.3 Implement Clean Headings

Use standard, clear headings without leading numbers, symbols, or internal codes. Set headings
apart using:

- **Font size** differentiation (H1 > H2 > H3)
- **Bold weight** for all headings
- **Consistent spacing** before and after heading text
- Word's built-in heading styles (`Heading1`, `Heading2`, `Heading3`) for proper TOC support

Headings should be descriptive and self-contained. A reader scanning headings alone should
understand the chapter's structure.

---

## 2. Layout, Elements, and Scannability

### 2.1 Utilize Clean Sidebars and Tables

Present structured content using well-formatted tables with:
- Light border color (`#C4C7C5` or similar neutral tone)
- Cell padding (top/bottom: 80+ DXA, left/right: 120+ DXA)
- `ShadingType.CLEAR` for cell backgrounds (never `SOLID`)
- `WidthType.DXA` for all width values (never `PERCENTAGE`)
- Bold header row text

Use horizontal rules (paragraph borders) to separate distinct content sections and prevent
dense blocks of text.

### 2.2 Format Bulleted Lists for Readability

Break complex information into scannable, individual bullet points. Apply the **bold-lead**
pattern: bold the initial keyword or phrase of each bullet to guide the eye.

| FORBIDDEN | REQUIRED |
|-----------|----------|
| Copy and paste the text directly into the terminal session. Always place a brief framing line before the transcript. | **Pasting the transcript:** Copy and paste the text directly into the terminal session. Always place a brief framing line before the transcript. |

Use Word's built-in numbering with `LevelFormat.BULLET`. Never use Unicode bullet characters
(`•`, `●`) manually inserted as text.

### 2.3 Apply Blockquotes for Highlights

Isolate important notes, distinct scenarios, conversational scripts, or side paths inside
styled blockquote paragraphs (indented with a left border or shaded background). This separates
secondary information from the core narrative flow.

Use blockquotes for:
- **Scenarios and worked examples** that set a narrative context
- **Important warnings or tips** that interrupt the main flow
- **Key takeaways** that summarize a section's main point

### 2.4 White Space and Visual Breathing Room

- Maintain consistent paragraph spacing (120+ DXA after body paragraphs)
- Add extra spacing before headings (240+ DXA before H2, 180+ DXA before H3)
- Never stack more than 3 body paragraphs without a visual break (heading, list, table,
  blockquote, or horizontal rule)
- Page breaks before major sections (H1, chapter titles)

---

## 3. Tone, Punctuation, and Prose Style

### 3.1 Avoid Em Dashes

Connect thoughts using periods, commas, semicolons, or standard conjunctions. Never use em
dashes (—) to join parenthetical thoughts or split sentences.

| FORBIDDEN | REQUIRED |
|-----------|----------|
| ...foundation — Tracy needs... | ...foundation. Tracy needs... |
| The tool — which runs locally — processes... | The tool, which runs locally, processes... |
| Start the session — and watch the output | Start the session and watch the output. |

### 3.2 Simplify Sentence Structure

Write direct, factual sentences:
- **Avoid** long, winding constructions with multiple subordinate clauses
- **Avoid** setup phrasing: "in conclusion", "furthermore", "it is worth noting that",
  "as mentioned earlier", "it should be noted"
- **Avoid** unnecessary adjectives and adverbs
- **Prefer** active voice over passive voice
- **Prefer** concrete subjects over abstract ones

### 3.3 Focus on the Audience

Write text that addresses the immediate context of the learner:
- **Never** use behind-the-scenes administrative or curriculum-tracking terminology
- **Never** reference internal pipeline concepts (gates, specs, evaluators, handoff JSON)
- **Never** mention Bloom's taxonomy, learning outcome IDs, or pedagogical framework names
- **Always** write as if speaking directly to the student about their work and goals

---

## 4. Typography Specifications

### 4.1 Font Stack

| Element | Font | Size (pt) | Weight | Color |
|---------|------|-----------|--------|-------|
| Document default | Arial | 12 | Normal | #1F1F1F |
| Heading 1 (chapter title) | Arial | 16 | Bold | #1F1F1F |
| Heading 2 (section) | Arial | 14 | Bold | #1F1F1F |
| Heading 3 (subsection) | Arial | 12 | Bold | #1F1F1F |
| Body text | Arial | 12 | Normal | #1F1F1F |
| Table header text | Arial | 11 | Bold | #1F1F1F |
| Table body text | Arial | 11 | Normal | #1F1F1F |
| Code / monospace | Consolas | 10 | Normal | #1F1F1F |
| Blockquote text | Arial | 11 | Normal | #444444 |

Keep titles and headings black (#1F1F1F) for readability. Do not use colored headings.

### 4.2 Page Setup

- **Page size:** US Letter (12,240 x 15,840 DXA)
- **Margins:** 1 inch all sides (1,440 DXA)
- **Content width:** 9,360 DXA
- **Line spacing:** ~1.15x (276 DXA line rule)
- **Paragraph spacing:** 120 DXA after body paragraphs

### 4.3 Headers and Footers

- **Header:** Course title or chapter title (left-aligned, 10pt, gray)
- **Footer:** Page number (centered or right-aligned)
- Use paragraph borders for header/footer rules, not tables

---

## 5. Structural Components in docx-js

### 5.1 Heading Styles

Override Word's built-in styles using exact IDs. Include `outlineLevel` for TOC support:

```javascript
{ id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal",
  run: { size: 32, bold: true, font: "Arial" },
  paragraph: { spacing: { before: 240, after: 240 }, outlineLevel: 0 } }
```

### 5.2 Tables

**Every table MUST fill the full content width of 9,360 DXA** (US Letter, 1-inch margins), so
columns are readable and the table is not bunched on the left.

The single most common defect is a `columnWidths` / `tblGrid` that does not match the cells.
With fixed layout, Word lays the table out from `columnWidths` (the `tblGrid`), NOT from the
cell widths, so wrong values there collapse the whole table even when the table width and the
cell widths are correct. Never emit placeholder grid values such as `100`.

Always set ALL of the following, and keep them mutually consistent:
- `layout: TableLayoutType.FIXED` (column widths are honored exactly)
- Table `width`: `{ size: 9360, type: WidthType.DXA }` (never `WidthType.PERCENTAGE`)
- `columnWidths`: an array of DXA integers, one entry per column, that **sums to exactly 9360**
  and whose entries **equal the per-column cell widths**. `columnWidths.length` MUST equal the
  number of columns.
- Each cell `width`: `{ size: <that column's width>, type: WidthType.DXA }`, matching the
  corresponding `columnWidths` entry
- Cell `margins` for readable padding (top/bottom ≥ 80 DXA, left/right ≥ 120 DXA)
- `ShadingType.CLEAR` for any cell shading
- Light borders (`#C4C7C5`, size 1)

Choose column proportions that sum to 9,360. Examples: 2 cols `[4680, 4680]`; 3 equal
`[3120, 3120, 3120]`; 3 with a narrow first column `[2160, 3600, 3600]`; 4 equal
`[2340, 2340, 2340, 2340]`. For N equal columns use `floor(9360 / N)` and add the remainder to
the last column so the total is exactly 9,360.

Minimal correct shape (docx-js):
```javascript
new Table({
  layout: TableLayoutType.FIXED,
  width: { size: 9360, type: WidthType.DXA },
  columnWidths: [2160, 3600, 3600],                 // one entry per column; sums to 9360
  rows: rows.map(cells => new TableRow({
    children: cells.map((c, i) => new TableCell({
      width: { size: [2160, 3600, 3600][i], type: WidthType.DXA },  // == columnWidths[i]
      margins: { top: 80, bottom: 80, left: 120, right: 120 },
      children: [ /* paragraphs */ ],
    })),
  })),
})
```

python-docx equivalent: set `table.autofit = False`, force fixed layout, and set the SAME twips
value on `table.columns[i].width` AND every `cell.width` in that column, with the per-column
values summing to 9,360 twips.

**Self-check before saving any docx that contains a table:** for every table, the `tblGrid`
column widths MUST sum to the table width (9,360) and equal the cell widths. A table whose grid
sums to materially less than 9,360 will render narrow and left-aligned. Reject and rebuild it.

### 5.3 Lists

Always use `LevelFormat.BULLET` or `LevelFormat.DECIMAL` numbering config. Never manually
insert bullet characters as text runs.

### 5.4 Images

Every `ImageRun` must include:
- `type` parameter (png, jpg, etc.)
- `altText` with all three fields: `title`, `description`, `name`
- Appropriate `transformation` sizing

---

## 6. Anti-Patterns Checklist

Before submitting any student-facing docx, verify NONE of these appear:

**Administrative / pipeline references (MUST be zero):**
- [ ] Section symbol (§) anywhere in text
- [ ] LO-IDs (LO-01.1, LO-03.2, LO-NN.n, etc.)
- [ ] Bloom level labels ([Apply], [Remember], bloom_level, "Bloom's taxonomy", etc.)
- [ ] Chapter slugs (ch02-automation-mindset)
- [ ] Item IDs (ch03-q01, ex-02, exercise_id)
- [ ] Exercise IDs or internal identifiers of any kind
- [ ] Section number prefixes on headings (3.2, 5.1)
- [ ] YAML front-matter or code-style metadata blocks
- [ ] Time budgets (est_minutes, time_box_minutes)
- [ ] Assessment metadata (assessment_mode, estimated_difficulty, remediation_link)
- [ ] Pipeline terminology ("gate", "evaluator", "handoff", "spec", "manifest")
- [ ] Pedagogical framework names ("Bloom's taxonomy", "Concrete-Pictorial-Abstract")
- [ ] File format references ("see the JSON", "handoff.json", "quiz.json")
- [ ] Any content not directly useful for learning the subject matter

**Prose style (MUST be zero):**
- [ ] Em dashes (—)
- [ ] Unicode bullet characters used as plain text
- [ ] Setup phrasing ("in conclusion", "furthermore", "it is worth noting")
- [ ] Bloom taxonomy references ("this is an Apply-level exercise")
- [ ] Generic placeholders ("a user", "the system") not replaced by domain vocabulary

**Technical formatting (MUST be zero):**
- [ ] `WidthType.PERCENTAGE` on any table
- [ ] Any table whose `columnWidths` / `tblGrid` does not sum to 9,360 DXA, or does not match the
      cell widths (renders narrow and left-aligned instead of filling the page)
- [ ] Placeholder grid values (e.g. `columnWidths: [100, 100, ...]`)
- [ ] `ShadingType.SOLID` on any table cell
- [ ] Tables used as dividers or in headers/footers
- [ ] Missing alt text on any image
