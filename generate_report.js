const fs = require("fs");
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        Header, Footer, AlignmentType, HeadingLevel, BorderStyle, WidthType,
        ShadingType, PageNumber, PageBreak, LevelFormat } = require("docx");

// ── Color palette ──
const DARK_BLUE = "1B3A5C";
const MEDIUM_BLUE = "2E75B6";
const LIGHT_BLUE = "D5E8F0";
const HEADER_BG = "1B3A5C";
const HEADER_TEXT = "FFFFFF";
const ROW_EVEN = "F2F7FB";
const ROW_ODD = "FFFFFF";
const ACCENT_RED = "C0392B";
const DARK_GRAY = "333333";
const MED_GRAY = "666666";
const LIGHT_GRAY = "E8E8E8";

const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const borders = { top: border, bottom: border, left: border, right: border };
const noBorder = { style: BorderStyle.NONE, size: 0 };
const noBorders = { top: noBorder, bottom: noBorder, left: noBorder, right: noBorder };

const cellMargins = { top: 60, bottom: 60, left: 100, right: 100 };

// ── Helper: make a table ──
function makeTable(headers, rows, colWidths) {
  const tableWidth = colWidths.reduce((a, b) => a + b, 0);
  const headerRow = new TableRow({
    tableHeader: true,
    children: headers.map((h, i) => new TableCell({
      borders,
      width: { size: colWidths[i], type: WidthType.DXA },
      shading: { fill: HEADER_BG, type: ShadingType.CLEAR },
      margins: cellMargins,
      verticalAlign: "center",
      children: [new Paragraph({
        spacing: { before: 40, after: 40 },
        children: [new TextRun({ text: h, bold: true, color: HEADER_TEXT, font: "Arial", size: 18 })]
      })]
    }))
  });
  const dataRows = rows.map((row, ri) => new TableRow({
    children: row.map((cell, ci) => new TableCell({
      borders,
      width: { size: colWidths[ci], type: WidthType.DXA },
      shading: { fill: ri % 2 === 0 ? ROW_EVEN : ROW_ODD, type: ShadingType.CLEAR },
      margins: cellMargins,
      children: [new Paragraph({
        spacing: { before: 30, after: 30 },
        alignment: typeof cell === "object" ? (cell.align || AlignmentType.LEFT) : AlignmentType.LEFT,
        children: [new TextRun({
          text: typeof cell === "object" ? cell.text : cell,
          bold: typeof cell === "object" ? (cell.bold || false) : false,
          font: "Arial",
          size: 18,
          color: typeof cell === "object" && cell.color ? cell.color : DARK_GRAY
        })]
      })]
    }))
  }));
  return new Table({
    width: { size: tableWidth, type: WidthType.DXA },
    columnWidths: colWidths,
    rows: [headerRow, ...dataRows]
  });
}

function h1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 360, after: 200 },
    children: [new TextRun({ text, bold: true, font: "Arial", size: 32, color: DARK_BLUE })]
  });
}

function h2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 280, after: 160 },
    children: [new TextRun({ text, bold: true, font: "Arial", size: 26, color: MEDIUM_BLUE })]
  });
}

function h3(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 200, after: 120 },
    children: [new TextRun({ text, bold: true, font: "Arial", size: 22, color: MEDIUM_BLUE })]
  });
}

function para(textOrRuns, opts = {}) {
  const children = typeof textOrRuns === "string"
    ? [new TextRun({ text: textOrRuns, font: "Arial", size: 20, color: DARK_GRAY })]
    : textOrRuns;
  return new Paragraph({
    spacing: { before: 80, after: 120, line: 300 },
    alignment: opts.align || AlignmentType.LEFT,
    ...opts,
    children
  });
}

function boldPara(textParts) {
  return new Paragraph({
    spacing: { before: 80, after: 120, line: 300 },
    children: textParts.map(p => new TextRun({
      text: p.text, bold: !!p.bold, font: "Arial", size: 20, color: p.color || DARK_GRAY
    }))
  });
}

function spacer(pts = 120) {
  return new Paragraph({ spacing: { before: pts, after: 0 }, children: [] });
}

function divider() {
  return new Paragraph({
    spacing: { before: 160, after: 160 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: MEDIUM_BLUE, space: 1 } },
    children: []
  });
}

// ── Build document ──
const doc = new Document({
  styles: {
    default: {
      document: { run: { font: "Arial", size: 20, color: DARK_GRAY } }
    },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 32, bold: true, font: "Arial", color: DARK_BLUE },
        paragraph: { spacing: { before: 360, after: 200 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 26, bold: true, font: "Arial", color: MEDIUM_BLUE },
        paragraph: { spacing: { before: 280, after: 160 }, outlineLevel: 1 } },
      { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 22, bold: true, font: "Arial", color: MEDIUM_BLUE },
        paragraph: { spacing: { before: 200, after: 120 }, outlineLevel: 2 } },
    ]
  },
  numbering: {
    config: [
      { reference: "bullets", levels: [
        { level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } },
        { level: 1, format: LevelFormat.BULLET, text: "◦", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 1440, hanging: 360 } } } }
      ]},
      { reference: "numbers", levels: [
        { level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }
      ]},
      { reference: "bullets2", levels: [
        { level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }
      ]},
      { reference: "bullets3", levels: [
        { level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }
      ]},
      { reference: "bullets4", levels: [
        { level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }
      ]},
      { reference: "nextSteps", levels: [
        { level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }
      ]},
    ]
  },
  sections: [
    // ═══════ TITLE PAGE ═══════
    {
      properties: {
        page: {
          size: { width: 12240, height: 15840 },
          margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
        }
      },
      children: [
        spacer(2400),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 200 },
          children: [new TextRun({ text: "ADVISOR360", font: "Arial", size: 28, color: MEDIUM_BLUE, bold: true, letterSpacing: 200 })]
        }),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 80 },
          border: { bottom: { style: BorderStyle.SINGLE, size: 8, color: MEDIUM_BLUE, space: 8 } },
          children: []
        }),
        spacer(200),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 120 },
          children: [new TextRun({ text: "Snowflake Data Warehouse", font: "Arial", size: 40, bold: true, color: DARK_BLUE })]
        }),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 200 },
          children: [new TextRun({ text: "Storage Utilization & Cost Optimization Report", font: "Arial", size: 36, color: DARK_BLUE })]
        }),
        spacer(400),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 60 },
          children: [new TextRun({ text: "Prepared by the Data Governance Team", font: "Arial", size: 22, color: MED_GRAY })]
        }),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 60 },
          children: [new TextRun({ text: "May 27, 2026", font: "Arial", size: 22, color: MED_GRAY })]
        }),
        spacer(200),
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { after: 60 },
          children: [new TextRun({ text: "Classification: Internal — Executive Summary", font: "Arial", size: 18, color: MED_GRAY, italics: true })]
        }),
      ]
    },
    // ═══════ MAIN CONTENT ═══════
    {
      properties: {
        page: {
          size: { width: 12240, height: 15840 },
          margin: { top: 1440, right: 1296, bottom: 1296, left: 1296 }
        }
      },
      headers: {
        default: new Header({
          children: [new Paragraph({
            alignment: AlignmentType.RIGHT,
            border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: MEDIUM_BLUE, space: 4 } },
            children: [new TextRun({ text: "Snowflake Storage Utilization Report  |  Advisor360  |  May 2026", font: "Arial", size: 16, color: MED_GRAY, italics: true })]
          })]
        })
      },
      footers: {
        default: new Footer({
          children: [new Paragraph({
            alignment: AlignmentType.CENTER,
            border: { top: { style: BorderStyle.SINGLE, size: 2, color: LIGHT_GRAY, space: 4 } },
            children: [
              new TextRun({ text: "Confidential  |  Page ", font: "Arial", size: 16, color: MED_GRAY }),
              new TextRun({ children: [PageNumber.CURRENT], font: "Arial", size: 16, color: MED_GRAY }),
            ]
          })]
        })
      },
      children: [
        // ── 1. Executive Summary ──
        h1("1. Executive Summary"),
        para("This report presents a comprehensive analysis of Advisor360’s Snowflake data warehouse storage utilization, conducted using the Euno metadata catalog. The findings reveal a significant opportunity to reduce annual storage costs by an estimated $90,000–$102,000 through the removal of unused data assets."),
        boldPara([
          { text: "Of the 84,985 business tables in Snowflake, only 6,902 (8.1%) have been queried in the past 60 days.", bold: false },
        ]),
        para("The key findings of this analysis are:"),
        new Paragraph({ numbering: { reference: "bullets", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "91.9% of tables ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "(78,083 of 84,985) have not been queried in the past 60 days.", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Approximately 80–83% of total storage expenditure ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "supports tables with zero query activity.", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "The largest contributors to storage waste are ", font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "legacy migration artifacts ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "(5,589 multitenant backup tables), developer test data, and duplicated datasets across non-production environments.", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets", level: 0 }, spacing: { before: 60, after: 120 }, children: [
          new TextRun({ text: "A phased cleanup initiative could recover an estimated ", font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "$70,000–$95,000 annually ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "with minimal operational risk.", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),

        divider(),

        // ── 2. Scope & Methodology ──
        h1("2. Scope & Methodology"),
        para("This analysis covers all Snowflake tables across the Advisor360 account (advisor360-azeast), excluding system metadata schemas (INFORMATION_SCHEMA, ACCOUNT_USAGE). A total of 84,985 business tables were evaluated."),
        para("Usage was assessed over a 60-day lookback window using Snowflake query history data surfaced through the Euno metadata catalog. Tables with zero read queries during this period are classified as “unused.” Storage costs are based on Euno’s projected monthly storage cost calculations, which reflect Snowflake’s standard on-demand pricing (~$23/TB/month)."),
        para("The analysis spans four environments: Development, QA, Staging, and Production."),

        divider(),

        // ── 3. Current State of Utilization ──
        h1("3. Current State of Utilization"),
        h2("3.1  Table Utilization Overview"),

        makeTable(
          ["Metric", "Count", "Percentage"],
          [
            ["Total business tables", { text: "84,985", align: AlignmentType.RIGHT }, { text: "100%", align: AlignmentType.RIGHT }],
            ["Actively queried (last 60 days)", { text: "6,902", align: AlignmentType.RIGHT }, { text: "8.1%", align: AlignmentType.RIGHT, bold: true, color: "27AE60" }],
            [{ text: "Not queried (last 60 days)", bold: true }, { text: "78,083", align: AlignmentType.RIGHT, bold: true, color: ACCENT_RED }, { text: "91.9%", align: AlignmentType.RIGHT, bold: true, color: ACCENT_RED }],
            ["Orphaned assets (no queries + no dependencies)", { text: "11,786", align: AlignmentType.RIGHT }, { text: "13.9%", align: AlignmentType.RIGHT }],
          ],
          [4800, 2400, 2448]
        ),

        para("More than nine out of ten tables in the Snowflake environment have not been accessed in the past two months. While some may serve archival or compliance purposes, the volume suggests substantial accumulation of legacy, test, and redundant data assets that warrant review."),

        h2("3.2  Storage Cost Distribution"),

        makeTable(
          ["Category", "Est. Monthly Cost", "Est. Annual Cost", "Share of Total"],
          [
            [{ text: "Unused table storage", bold: true }, { text: "$7,500–$8,500", align: AlignmentType.RIGHT, bold: true, color: ACCENT_RED }, { text: "$90,000–$102,000", align: AlignmentType.RIGHT, bold: true, color: ACCENT_RED }, { text: "~80–83%", align: AlignmentType.RIGHT, bold: true }],
            ["Active table storage", { text: "$1,500–$2,000", align: AlignmentType.RIGHT }, { text: "$18,000–$24,000", align: AlignmentType.RIGHT }, { text: "~17–20%", align: AlignmentType.RIGHT }],
            [{ text: "Total estimated storage", bold: true }, { text: "$9,000–$10,500", align: AlignmentType.RIGHT, bold: true }, { text: "$108,000–$126,000", align: AlignmentType.RIGHT, bold: true }, { text: "100%", align: AlignmentType.RIGHT }],
          ],
          [2800, 2200, 2200, 2448]
        ),

        boldPara([
          { text: "Approximately four out of every five dollars ", bold: true },
          { text: "spent on Snowflake storage supports data that no user or process has accessed in the past 60 days. This represents a material opportunity for cost recovery." },
        ]),

        h2("3.3  Unused Tables by Environment"),

        makeTable(
          ["Environment", "Unused Tables", "Share of Unused"],
          [
            [{ text: "Development", bold: true }, { text: "30,324", align: AlignmentType.RIGHT }, { text: "38.8%", align: AlignmentType.RIGHT }],
            ["Production", { text: "18,641", align: AlignmentType.RIGHT }, { text: "23.9%", align: AlignmentType.RIGHT }],
            ["QA", { text: "14,386", align: AlignmentType.RIGHT }, { text: "18.4%", align: AlignmentType.RIGHT }],
            ["Staging", { text: "13,785", align: AlignmentType.RIGHT }, { text: "17.7%", align: AlignmentType.RIGHT }],
          ],
          [3200, 3200, 3248]
        ),

        para("The Development environment is the largest contributor at nearly 39% of all unused tables, consistent with typical patterns where developer sandboxes accumulate data without cleanup procedures. The presence of over 18,600 unused tables in Production warrants closer examination, as these may include deprecated pipelines, legacy data loads, or post-migration remnants."),

        divider(),

        // ── 4. Root Cause Analysis ──
        h1("4. Root Cause Analysis"),
        h2("4.1  Legacy Migration Artifacts"),
        boldPara([
          { text: "The single largest category of storage waste consists of 5,589 tables ", bold: true },
          { text: "following the naming pattern *_OLD_MULTITENANT_BACKUP. These appear to be remnants of a prior multitenant architecture migration, present across all four environments. Individual tables consume up to 10 TB, costing over $200/month each. Their naming convention and complete absence of query activity indicate they no longer serve an operational purpose." },
        ]),

        h2("4.2  Developer and Test Data"),
        para("Multiple personal developer schemas (BKELLEY_*, TGREENAN_*, CDENTON_*, DBSCHAFFER_*) contain large-scale test and experimental tables replicating production datasets such as PositionValue and AccountValue. Across the warehouse, 7,781 unused tables contain keywords such as “test,” “backup,” “old,” “copy,” or “tmp” in their names—none of which have been accessed in over 60 days."),

        h2("4.3  Environment Duplication"),
        para("Large tables frequently appear with identical schemas and comparable row counts across Dev, QA, Staging, and Production. While some replication is necessary for testing, the degree of duplication—particularly for historical and archival tables—exceeds operational requirements and inflates storage costs across every environment."),

        divider(),

        // ── 5. Top Cost Drivers ──
        h1("5. Top Cost Drivers — Unused Tables"),

        makeTable(
          ["Rank", "Table Name", "Environment", "Schema", "Monthly Cost"],
          [
            [{ text: "1", align: AlignmentType.CENTER }, "POSITIONVALUE_OLD_MULTITENANT_BACKUP", "QA", "EDW_INTEGRATION", { text: "$216.79", align: AlignmentType.RIGHT, bold: true }],
            [{ text: "2", align: AlignmentType.CENTER }, "POSITIONVALUE_OLD_MULTITENANT_BACKUP", "Production", "EDW_INTEGRATION", { text: "$207.45", align: AlignmentType.RIGHT, bold: true }],
            [{ text: "3", align: AlignmentType.CENTER }, "POSITIONVALUE_OLD_MULTITENANT_BACKUP", "Development", "EDW_INTEGRATION", { text: "$181.81", align: AlignmentType.RIGHT, bold: true }],
            [{ text: "4", align: AlignmentType.CENTER }, "POSITIONVALUEOLD_OLD_MULTITENANT_BACKUP", "Development", "EDW_INTEGRATION", { text: "$174.23", align: AlignmentType.RIGHT }],
            [{ text: "5", align: AlignmentType.CENTER }, "POSITIONVALUE_COPY0810_OLD_MULTITENANT_BACKUP", "Development", "EDW_INTEGRATION", { text: "$156.21", align: AlignmentType.RIGHT }],
            [{ text: "6", align: AlignmentType.CENTER }, "POSITION_VALUE_20240531_2_OLD_MULTITENANT_BACKUP", "Development", "EDW_INTEGRATION", { text: "$153.34", align: AlignmentType.RIGHT }],
            [{ text: "7", align: AlignmentType.CENTER }, "POSITIONVALUE", "Governance DB", "EDW_TRANSFORMED", { text: "$118.07", align: AlignmentType.RIGHT }],
            [{ text: "8", align: AlignmentType.CENTER }, "POSITIONVALUE", "TG_TEST", "EDW_TRANSFORMED", { text: "$117.98", align: AlignmentType.RIGHT }],
            [{ text: "9", align: AlignmentType.CENTER }, "POSITIONVALUE", "QA", "EDW_INTEGRATION_CFN", { text: "$110.52", align: AlignmentType.RIGHT }],
            [{ text: "10", align: AlignmentType.CENTER }, "PositionValue", "Development", "EDW_INTEGRATION_CFN", { text: "$107.26", align: AlignmentType.RIGHT }],
          ],
          [600, 3700, 1500, 2048, 1800]
        ),

        boldPara([
          { text: "The ten most expensive unused tables alone account for approximately $1,544 per month ($18,500 annually). ", bold: true },
          { text: "Nine of the ten involve PositionValue-related data across environments and schemas, indicating a concentrated area of waste amenable to targeted cleanup." },
        ]),

        divider(),

        // ── 6. Recommended Actions ──
        h1("6. Recommended Actions"),

        h2("Phase 1 — Immediate (Weeks 1–2): Drop Legacy Migration Backups"),
        new Paragraph({ numbering: { reference: "bullets2", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Target: ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "5,589 tables matching the *_OLD_MULTITENANT_BACKUP naming pattern", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets2", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Risk: ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "Low — clearly labeled pre-migration backups with zero query activity", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets2", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Estimated annual savings: $40,000–$50,000", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets2", level: 0 }, spacing: { before: 60, after: 120 }, children: [
          new TextRun({ text: "Prerequisite: ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "Confirm with data engineering that the multitenant migration is fully complete", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),

        h2("Phase 2 — Quick Wins (Weeks 3–4): Clean Developer and Test Schemas"),
        new Paragraph({ numbering: { reference: "bullets3", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Target: ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "7,781 tables with test/backup/old/copy/tmp naming patterns, prioritizing the 404 tables with projected costs above $1/month", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets3", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Risk: ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "Low — personal schemas and explicitly named test tables are unlikely to support production", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets3", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Estimated annual savings: $15,000–$20,000 ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "(incremental)", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets3", level: 0 }, spacing: { before: 60, after: 120 }, children: [
          new TextRun({ text: "Action: ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "Notify schema owners, allow a two-week grace period, then archive and drop", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),

        h2("Phase 3 — Governance (Months 2–3): Address Orphaned Assets"),
        new Paragraph({ numbering: { reference: "bullets4", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Target: ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "11,786 tables flagged as orphaned (no queries in 60+ days, no downstream dependencies)", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets4", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Risk: ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "Moderate — requires validation for compliance, audit, or seasonal usage patterns", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets4", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Estimated annual savings: $15,000–$25,000 ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "(incremental)", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "bullets4", level: 0 }, spacing: { before: 60, after: 120 }, children: [
          new TextRun({ text: "Action: ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "Publish an orphaned asset list, engage business owners for attestation, implement a 90-day deprecation policy", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),

        h2("Phase 4 — Ongoing: Establish Data Lifecycle Policy"),
        para("To prevent reaccumulation and ensure sustained savings, we recommend establishing the following governance measures:"),
        new Paragraph({ numbering: { reference: "numbers", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Automated monitoring for tables with zero reads over a rolling 90-day window", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "numbers", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Mandatory owner assignment and retention policies for all new tables", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "numbers", level: 0 }, spacing: { before: 60, after: 60 }, children: [
          new TextRun({ text: "Quarterly storage reviews with environment-level budgets", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "numbers", level: 0 }, spacing: { before: 60, after: 120 }, children: [
          new TextRun({ text: "Storage quotas for developer schemas in non-production environments", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),

        divider(),

        // ── 7. Financial Summary ──
        h1("7. Financial Summary"),

        makeTable(
          ["Initiative", "Timeline", "Est. Annual Savings", "Risk"],
          [
            [{ text: "Phase 1: Migration backup cleanup", bold: true }, "Weeks 1–2", { text: "$40,000–$50,000", align: AlignmentType.RIGHT, bold: true }, { text: "Low", align: AlignmentType.CENTER, color: "27AE60" }],
            [{ text: "Phase 2: Developer/test cleanup", bold: true }, "Weeks 3–4", { text: "$15,000–$20,000", align: AlignmentType.RIGHT, bold: true }, { text: "Low", align: AlignmentType.CENTER, color: "27AE60" }],
            [{ text: "Phase 3: Orphaned asset retirement", bold: true }, "Months 2–3", { text: "$15,000–$25,000", align: AlignmentType.RIGHT, bold: true }, { text: "Moderate", align: AlignmentType.CENTER, color: "E67E22" }],
            [{ text: "Phase 4: Lifecycle policy", bold: true }, "Ongoing", { text: "Prevents recurrence", align: AlignmentType.RIGHT }, { text: "N/A", align: AlignmentType.CENTER, color: MED_GRAY }],
            [{ text: "TOTAL ESTIMATED SAVINGS", bold: true, color: DARK_BLUE }, "", { text: "$70,000–$95,000", align: AlignmentType.RIGHT, bold: true, color: DARK_BLUE }, ""],
          ],
          [3200, 1600, 2400, 2448]
        ),

        spacer(80),
        para("These estimates are based solely on storage cost recovery. Additional indirect savings may be realized through reduced data scanning costs during warehouse operations, faster metadata resolution, and simplified governance overhead. Phase 4, while not quantified above, is essential to prevent reaccumulation and ensure sustained value."),

        divider(),

        // ── 8. Next Steps ──
        h1("8. Next Steps"),
        new Paragraph({ numbering: { reference: "nextSteps", level: 0 }, spacing: { before: 80, after: 80 }, children: [
          new TextRun({ text: "Review and approve ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "the phased cleanup plan outlined in Section 6.", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "nextSteps", level: 0 }, spacing: { before: 80, after: 80 }, children: [
          new TextRun({ text: "Assign an owner ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "for each phase with clear timelines and accountability.", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "nextSteps", level: 0 }, spacing: { before: 80, after: 80 }, children: [
          new TextRun({ text: "Schedule a follow-up review ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "in 90 days to assess progress and measure realized savings.", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),
        new Paragraph({ numbering: { reference: "nextSteps", level: 0 }, spacing: { before: 80, after: 80 }, children: [
          new TextRun({ text: "Evaluate ", bold: true, font: "Arial", size: 20, color: DARK_GRAY }),
          new TextRun({ text: "whether a formal Data Lifecycle Management policy should be established as a standing governance practice.", font: "Arial", size: 20, color: DARK_GRAY }),
        ]}),

        divider(),

        // ── Appendix ──
        h1("Appendix: Data Sources & Definitions"),
        makeTable(
          ["Term", "Definition"],
          [
            [{ text: "Data Source", bold: true }, "Euno Metadata Catalog (Advisor360 account, account_admin persona)"],
            [{ text: "Usage Window", bold: true }, "60-day lookback from May 27, 2026"],
            [{ text: "Unused", bold: true }, "Zero read queries recorded in Snowflake query history over the 60-day window"],
            [{ text: "Orphaned Asset", bold: true }, "Unused (per above) AND no downstream lineage dependencies detected by Euno"],
            [{ text: "Storage Cost Basis", bold: true }, "Snowflake on-demand storage pricing (~$23/TB/month), reflected in Euno’s projected_storage_cost metric"],
            [{ text: "Tables Excluded", bold: true }, "INFORMATION_SCHEMA and ACCOUNT_USAGE system schemas"],
          ],
          [2400, 7248]
        ),
      ]
    }
  ]
});

// ── Write file ──
const OUTPUT = "C:\\Users\\mcohenyashar\\Documents\\Projects\\personalized_course_factory\\Snowflake_Storage_Utilization_Report.docx";
Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(OUTPUT, buffer);
  console.log("Report written to: " + OUTPUT);
}).catch(err => {
  console.error("Error:", err);
  process.exit(1);
});
