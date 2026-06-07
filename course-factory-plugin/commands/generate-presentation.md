---
name: generate-presentation
description: Slide-by-slide generation instructions for the chapter slide deck, including per-slide content rules, Bloom badge format, retrieval slide structure, speaker-notes section template, Mayer principle application, and the slide manifest JSON format passed to anthropic-skills:pptx. Invoked by presentation-generator.
---

# Generate Presentation — Detailed Instructions

---

## PERSONALIZATION PROTOCOL — DO THIS BEFORE BUILDING THE SLIDE MANIFEST

A slide deck is a presentation artifact — the learner sees it alongside an instructor or on a
screen. If the slides show generic company names, placeholder entities, and abstract scenarios,
the cohort immediately perceives the course as off-the-shelf. Every slide must reflect the
learner's actual domain.

### Before building the manifest, pin this context:

```
protagonist      = personalization_plan.running_example_per_chapter[chapter_slug].protagonist
protagonist_role = personalization_plan.running_example_per_chapter[chapter_slug].protagonist_role
domain_context   = personalization_plan.running_example_per_chapter[chapter_slug].domain_context
vocab            = personalization_plan.vocabulary_substitutions
scenario         = the assigned scenario for this chapter (title, entities, artifacts)
fk_target        = personalization_plan.reading_register.fk_grade_target
tone             = personalization_plan.reading_register.tone
```

### Personalization rules for every slide:

1. **Titles use domain conclusions, not domain-neutral conclusions.**
   A conclusion slide title must name the domain system or domain action when relevant:
   - BAD:  "Context injection outperforms few-shot for dynamic data"
   - GOOD: "Context injection gives {vocab.system} the live {vocab.item} data it needs"

2. **Body text uses domain vocabulary throughout.**
   Every ≤ 40-word body must use at least 1 domain-specific noun from `vocab`.
   The learner should be able to point to the slide and say "that's my system."

3. **The worked example slide names the protagonist and their goal:**
   - BAD:  "Worked Example: Prompt Chain" 
   - GOOD: "Worked Example: How {protagonist} automates {domain_context}"

4. **Retrieval prompt slides frame the question in the protagonist's situation:**
   - BAD:  "What happens when the context window is full?"
   - GOOD: "Before {protagonist} runs the nightly batch — what does {vocab.system} do when
            the {vocab.item} list exceeds the context limit?"

5. **Speaker notes reference the domain for instructor facilitation:**
   Every cohort sidebar discussion question should mention the protagonist's role:
   "Ask the room: 'In your team's {vocab.process}, how often does this scenario come up?'"

6. **Diagrams use domain entity names as node labels**, not generic terms:
   - BAD node labels: "Input", "Process", "Output", "User", "System"
   - GOOD node labels: "{vocab.item}", "{vocab.process}", "{vocab.system}", "{protagonist_role}"

### Slide body vocabulary checklist (run before generating manifest):

Scan each slide's `body_text`. Replace:
- "a user" / "the user" → `protagonist` + `protagonist_role`
- "the system" → `vocab.system`
- "an item" / "the item" → `vocab.item`
- "the process" → `vocab.process`
- "consider this scenario" → "In {domain_context}…"
- "Example:" → "In {vocab.system}:" or "When {protagonist}…"

---

## Visual Design System — Global Rules

### 1. Visual Hierarchy & Typography

* **Slide Dimensions:** Force standard modern widescreen aspect ratio (16:9).
* **Font Selection:** Use a clean, professional sans-serif pairing. Use Arial or Calibri as safe cross-platform system fonts, or specific enterprise font stacks. Never use more than two font families per deck.
* **Color Palette Constraints:** Define a strict 4-color palette programmatically:
  * **Primary/Background:** Light/White background for content readability.
  * **Text/Base:** Dark Charcoal/Off-Black (`#22252A`) — avoid `#000000` for text to reduce eye strain.
  * **Secondary/Muted:** Medium Slate Gray (`#6A737D`) for metadata, slide numbers, and labels.
  * **Accent:** One distinct brand color (`#005A9E`) used only for focal points and active labels.
* **Whitespace Deficit Correction:** Maintain a mandatory minimum 10% margin on all sides of the slide. Do not fill empty spaces with decorative shapes, lines, or icons. Whitespace must be treated as an intentional layout tool to drive clarity.

### 2. Header and Metadata Standardization

* **Structural Anchors:** Every slide must feature a consistent top layout anchor. Place the Slide Title in a prominent bold font size (24pt to 28pt) at the exact same coordinates across all content slides.
* **Metadata Integration:** Contextual labels, learning objectives, and chapter markers must be separated from the main title text. Place them as small, muted eyebrow text (10pt to 12pt) directly above the title, or anchored uniformly in the header zone.
* **Slide Tracking:** Include slide tracking indicators strictly in a single uniform location, such as the bottom right corner or integrated cleanly into the top metadata track.

### 3. Layout Switching & Component-Driven Architectures

To prevent repetitive, single-column layouts, the generation tool must programmatically choose from three structural layouts based on the content payload:

**Layout A: The Split-Screen Column Layout (For Frameworks & Profiles)**

* **Trigger:** Use when the slide text contains 2 to 4 distinct categories, definitions, or parallel concepts.
* **Execution:** Divide the available horizontal slide width into equal columns based on the count. Calculate explicit bounding box coordinates mathematically, leaving a clear gap between columns. Do not use standard text boxes with bullet points; use distinct column text containers with bold titles and clean vertical text flow.

**Layout B: Structured Technical Tables (For Data & Complex Comparisons)**

* **Trigger:** Use when text lists alternate between concept names, rules, definitions, and short execution examples.
* **Execution:** Abandon paragraphs or multi-level indented bullet points. Programmatically construct an explicit table element. Format the header row with a subtle background fill and bold text. Ensure all cell text has appropriate inner padding to keep the content highly scannable.

**Layout C: Ordered Linear Timesteps (For Sequential Processes)**

* **Trigger:** Use when the slide content represents a numbered sequence, workflow, or chronological process steps.
* **Execution:** Create a clear left-to-right horizontal train or a top-to-bottom list using distinct content blocks. Clearly isolate the step number from the description body text by applying a distinct visual treatment to the digits.

### 4. Text Formatting and ASCII Clean-up

* **Clean Structural Elements:** Explicitly ban the generation of markdown code block artifacts, raw file paths, JSON extensions, raw console brackets, tree structures, or raw ASCII box-drawing characters (`┌───┐`, `│`, `└───┘`) directly inside slide text boxes.
* **Geometric Transformations:** If the underlying text contains a workflow or tree structure, the code must parse that content and render it using clean native slide columns, tables, or structural blocks.
* **Scannability Optimization:** Ensure all body copy uses bold styling for the first two to three critical words of a line or bullet point. This guides the user's eye immediately to the core takeaway.

---

## python-pptx Implementation Guide

Apply this code structural logic when generating slides via the pptx skill:

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

# 1. Establish strict layout constants
SLIDE_WIDTH = Inches(13.333)
SLIDE_HEIGHT = Inches(7.5)

COLOR_PRIMARY_TEXT = RGBColor(0x22, 0x25, 0x2A)  # Charcoal
COLOR_MUTED_TEXT = RGBColor(0x6A, 0x73, 0x7D)    # Slate Gray
COLOR_ACCENT = RGBColor(0x00, 0x5A, 0x9E)        # Accent Blue

FONT_TITLE = "Arial"
FONT_BODY = "Calibri"

def apply_text_styling(paragraph, font_name, size, color, bold=False, alignment=PP_ALIGN.LEFT):
    paragraph.font.name = font_name
    paragraph.font.size = Pt(size)
    paragraph.font.color.rgb = color
    paragraph.font.bold = bold
    paragraph.alignment = alignment

# 2. Universal Header Logic (Enforces Whitespace and Alignment)
def add_slide_header(slide, title_text, eyebrow_text=None, tracking_text=None):
    # Eyebrow/Metadata Tracker
    if eyebrow_text:
        eb_box = slide.shapes.add_textbox(Inches(1.0), Inches(0.4), Inches(9.0), Inches(0.4))
        tf_eb = eb_box.text_frame
        tf_eb.word_wrap = True
        p_eb = tf_eb.paragraphs[0]
        p_eb.text = eyebrow_text.upper()
        apply_text_styling(p_eb, FONT_BODY, 11, COLOR_MUTED_TEXT, bold=True)
    
    # Standardized Title Location
    title_box = slide.shapes.add_textbox(Inches(1.0), Inches(0.7), Inches(9.0), Inches(0.8))
    tf_title = title_box.text_frame
    tf_title.word_wrap = True
    p_title = tf_title.paragraphs[0]
    p_title.text = title_text
    apply_text_styling(p_title, FONT_TITLE, 26, COLOR_PRIMARY_TEXT, bold=True)
    
    # Slide Tracking Indicator
    if tracking_text:
        track_box = slide.shapes.add_textbox(Inches(11.0), Inches(0.4), Inches(1.333), Inches(0.4))
        tf_track = track_box.text_frame
        p_track = tf_track.paragraphs[0]
        p_track.text = tracking_text
        apply_text_styling(p_track, FONT_BODY, 11, COLOR_MUTED_TEXT, alignment=PP_ALIGN.RIGHT)

# 3. Dynamic Column Generation Logic (Layout A)
def create_split_columns(slide, items_data):
    """
    items_data expected format: [{"title": "SKILL", "body_lines": ["Line 1...", ...]}, ...]
    """
    count = len(items_data)
    left_margin = Inches(1.0)
    top_margin = Inches(2.0)
    total_width = SLIDE_WIDTH - (left_margin * 2)
    gap = Inches(0.4)
    
    # Calculate uniform width dynamically based on item count
    col_width = (total_width - (gap * (count - 1))) / count
    
    for i, item in enumerate(items_data):
        col_left = left_margin + i * (col_width + gap)
        box = slide.shapes.add_textbox(col_left, top_margin, col_width, Inches(4.5))
        tf = box.text_frame
        tf.word_wrap = True
        
        # Column Header
        p_header = tf.paragraphs[0]
        p_header.text = item["title"]
        apply_text_styling(p_header, FONT_TITLE, 14, COLOR_ACCENT, bold=True)
        p_header.space_after = Pt(12)
        
        # Column Body Text
        for line in item["body_lines"]:
            p_line = tf.add_paragraph()
            p_line.text = line
            apply_text_styling(p_line, FONT_BODY, 13, COLOR_PRIMARY_TEXT)
            p_line.space_after = Pt(6)
```

---

## Slide Types and Their Rules

### Title Slide (S1)

```
Title: {chapter title}
Subtitle: {course title} | Chapter {N}
Body (1-liner): {one-sentence summary of the chapter's core skill}
No Bloom badge | No LO reference
```

### Learning Outcomes Slide (S2)

```
Title: "By the end of this chapter, you will be able to…"
Body: bullet list of Bloom-verbed LOs with IDs visible
  • [LO-NN.1] {verb} {object} [Bloom: {level}]
  • [LO-NN.2] ...
```

Rules: no more than 7 LOs; if > 7, list only the 4 most important and note "(+ N more in the doc)"

### Agenda Slide (S3)

```
Title: "Today's Journey"
Body: list of section names from chapter_doc_outline
  1. {section heading} [badge: {Bloom tier}]
  2. ...
```

### Prior-Chapter Recap (S4, omit ch01)

```
Title: "Quick Recall: Chapter {N-1}"
Body: ONE retrieval question (not the answer)
  "In Chapter {N-1}, you learned to {LO verb + object}.
   Before we continue — {specific retrieval question}?"
```

Speaker notes: include the expected answer and how to handle common wrong answers.

### Vocabulary & Mental Model (S5)

```
Title: "New Terms + Mental Model"
Body:
  {term 1}: {6-word definition}
  {term 2}: {6-word definition}
  [diagram of the mental model — see diagram rules below]
```

### Concept Slide Template

```
[Top-right: Bloom badge] [Bottom-right: LO-ID]
Title: {Conclusion statement — verb + assertion} ← REQUIRED
Body: ≤ 40 words making ONE point
  [Optional: 1 diagram (C4/sequence/ER/flowchart)]
  [Optional: ≤ 3-item list (if > 3 items → progressive disclosure)]
```

Title checklist:
- ✓ "Filters reduce noise before it reaches the model"
- ✓ "Context injection outperforms few-shot for dynamic data"
- ✗ "Types of Prompts" (topic, not conclusion)
- ✗ "Prompt Engineering Techniques" (topic noun phrase)

### Retrieval Prompt Slide (every 5–7 concept slides)

```
Title: "Pause & Recall" (or a topical variant)
Body: ONE question — no answer
  "{specific retrieval or self-explanation question}?"
```

Speaker notes: full answer + facilitation guidance for cohort mode; solo sidebar gives
"write the answer before continuing."

### Worked Example Slide

```
Title: "Worked Example: {scenario title}"
Body: ≤ 40 words framing the problem
  "Given: {brief description of starting state}"
  "Goal: {what we want to produce}"
[Diagram: before → after state, or solution flowchart]
```

Speaker notes: full narrated walkthrough (paraphrased from doc, NOT verbatim).

### "Try This Now" Slide

```
Title: "Your Turn"
Body:
  Open: {exercise_filename from exercise_manifest}
  Time box: {exercise time_box_minutes} minutes
  Goal: {exercise success_criteria}
```

### Common Pitfalls Slide

```
Title: "What Goes Wrong (and How to Fix It)"
Body: 2–3 pitfalls in a table or list
  ⚠ {pitfall 1}: {one-line symptom} → {one-line fix}
  ⚠ {pitfall 2}: ...
```

### Recap Slide

```
Title: "Can You…?"
Body: retrieval cues as questions (not answers)
  • Can you {LO-01.1 verb + object in question form}?
  • Can you {LO-01.2}?
  • Can you explain why {core concept}?
```

Speaker notes: expected answers per LO.

### Quiz Cue / Next Up Slide (SN+1)

```
Title: "Ready to Test Yourself?"
Body:
  Quiz: {quiz_filename}
  Passing: 80% | Retry: Form B available
  Next chapter: {brief teaser 1–2 sentences}
```

---

## Diagram Rules

For every diagram in the deck:

1. Determine the diagram type from the content:
   - System architecture → C4 diagram
   - Process or data flow → sequence diagram
   - Data relationships → ER diagram
   - Decision logic → flowchart

2. Write the Mermaid source (include in slide manifest as `diagram.mmd_source`):
```mermaid
sequenceDiagram
  Actor->>System: sends request
  System-->>Actor: returns result
```

3. Alt text must describe:
   - The shapes (boxes, arrows, nodes)
   - The relationships (what flows from what to what)
   - NOT just "sequence diagram" or "architecture"

4. Contrast rule: in the alt text, note intended colors. The actual color palette
   must ensure ≥ 4.5:1 contrast against the slide background. If uncertain, note:
   "Use theme default high-contrast palette."

---

## Slide Manifest JSON for anthropic-skills:pptx

Pass this to the pptx skill:

```json
{
  "template": "default",
  "color_palette": {
    "primary": "#FFFFFF",
    "accent": "#005A9E",
    "background": "#FFFFFF",
    "text": "#22252A",
    "muted": "#6A737D"
  },
  "font_config": {
    "title_font": "Arial",
    "title_size_pt": 26,
    "body_font": "Calibri",
    "body_size_pt": 13
  },
  "slides": [
    {
      "slide_number": 1,
      "type": "title",
      "title": "...",
      "subtitle": "...",
      "body": "...",
      "bloom_badge": null,
      "lo_ref": null,
      "diagram": null,
      "word_count": <int>
    },
    {
      "slide_number": 5,
      "type": "concept",
      "title": "{conclusion statement}",
      "body": "{≤40 words}",
      "bloom_badge": "Apply",
      "lo_ref": "LO-03.2",
      "diagram": {
        "mmd_source": "graph TD\n  A --> B",
        "alt_text": "{shapes and relationships described}",
        "type": "flowchart"
      },
      "word_count": <int>
    }
  ]
}
```

---

## Speaker Notes Section Template

Compose one section per slide, then invoke `anthropic-skills:docx` to produce `slides-notes.docx`:

```markdown
## Slide S{NN} — {short title}
**Timing:** [explain: N min] | [discuss: N min] | [click-through: N s]
**Bloom:** {bloom_level}
**LO ref:** {lo_ref}

### Cohort sidebar
- Ask the room: "{domain-grounded discussion question that references the protagonist's role
  or the cohort's professional_context — e.g. 'In your team's {vocab.process}, has this 
  situation come up? What did you do?'}"
- Likely misconception: "{misconception from chapter_pitfalls — named by its domain name, not
  by its error code}" — correct it by: "{domain-grounded correction}"
- If they're stuck: "{domain-specific hint — reference the system or scenario they know}"

### Solo sidebar
- If working alone, {specific domain-grounded self-study action — e.g. "open your team's
  {vocab.system} and find a real {vocab.item} that matches this scenario. How would this
  step apply to it?" — not just "write the answer".}

### Speaker script
{One paragraph (3–6 sentences) the trainer can read or paraphrase.
Must NOT duplicate the slide body text verbatim.
Must connect the slide content to the chapter's running example, naming the protagonist
and the domain system. Must use the register from personalization_plan.reading_register.tone.
Example opening: "Sara deals with this every morning — before she can run the receiving batch,
she has to decide which exceptions get cleared automatically and which need a human review.
That's exactly what context injection solves for {vocab.system}..."}
```

Both `### Cohort sidebar` and `### Solo sidebar` are REQUIRED on every slide.
Both MUST reference domain vocabulary — no generic facilitation questions allowed.
