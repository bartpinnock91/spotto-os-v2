# Product Management Workflow

This repo is the **thinking ground** for product management. Jira is the **source of truth** for active work.

## Products

| Product             | Folder                          | Jira Key | Description                               |
| ------------------- | ------------------------------- | -------- | ----------------------------------------- |
| Spotto              | `products/spotto/`              | SPOTTO   | B2C real estate platform (spotto.be)      |
| Vergelijkingspanden | `products/vergelijkingspanden/` | TRANSDATA | B2B comparable properties tool for agents |
| Markttendensen      | `products/markttendensen/`      | MT       | B2B market insights dashboard             |

## Workflow

```
DRAFT (here) → PUSH TO JIRA → JIRA (active) → DONE → ARCHIVE (here)
```

### 1. Drafting Stories

Create draft stories in `products/{product}/drafts/` using templates from `templates/`. Write all stories in dutch.

**Draft status lifecycle:**

- `Draft` - Work in progress, not ready
- `Ready for Jira` - Finalized, ready to push

### 2. Pushing to Jira

When a story is "Ready for Jira":

1. Use Jira MCP to create the ticket (use project key from table above)
2. Delete the draft file - Jira is now the single source of truth

**Available issue types:** Epic, New Feature, Improvement, Bug, Task (see `products/jira-workflow.md` for details)

### 3. Archiving Completed Stories

When stories are Done in Jira:

1. Pull the story with full metadata (comments, time spent, etc.)
2. Save to `products/{product}/archive/`
3. These become immutable records for analysis

## Folder Structure

Each product has:

- `context/` - Personas, competitors, feature overview
- `roadmap/` - High-level product roadmap
- `drafts/` - WIP stories (delete after pushing to Jira)
- `archive/` - Completed stories from Jira (immutable)

## Templates

- `templates/user-story.md` - Standard user story format
- `templates/epic.md` - Epic/initiative format

## Company Context

Shared context lives in `company/`:

- `vision.md` - Company vision & mission
- `strategy.md` - Strategic goals
- `glossary.md` - Shared terminology

## MCP Integrations

This repo uses MCP servers for direct integration:

| Server            | Purpose           | Usage                                              |
| ----------------- | ----------------- | -------------------------------------------------- |
| **Figma**         | Access designs    | Paste Figma frame links in conversations           |
| **Jira**          | Push/pull stories | Create tickets, query issues, archive done stories |
| **Confluence**    | Documentation     | Push summaries/reports to Confluence spaces         |
| **Google Analytics** | Access GA4 data   | Query analytics for Spotto products                |
| **MSSQL** (`mssql`) | Read-only SQL     | Query the Spotto platform DB (`dbo.Publications`, `Customers`, …) — see [docs/mcp-setup.md](docs/mcp-setup.md) |
| **MSSQL** (`mssql-comparison`) | Read-only SQL | Query the Vergelijkingspanden reference DB (`databricks` schema) for PR/data analyses — see [docs/mcp-setup.md](docs/mcp-setup.md) |

### Google Analytics

When querying GA4 data, always use the **Spotto - V2** property (ID: `491908260`).

Setup instructions: [docs/mcp-setup.md](docs/mcp-setup.md)

### Working with Designs

Each product has its own Figma file. When working on a product:

1. Share the relevant Figma link for the feature/screen
2. Claude can fetch design context directly via MCP
3. Include Figma links in draft stories for reference

## Guidelines

- **Never edit archived stories** - they are immutable records
- **Delete drafts after pushing** - Jira is the single source of truth, don't keep local copies
- **Context is valuable** - Keep product context up to date (tracking setup, personas, etc.)
- **Use templates** - Ensures consistency across stories
- **Include Figma links** - Reference designs in stories when relevant

### Single Source of Truth

- **Backlog order lives in Jira** - Never duplicate story lists or order in epic descriptions
- **Epics explain strategy, not order** - Describe the _why_ behind prioritization, not the sequence itself
- **Reference, don't repeat** - If you need to mention stories, link to them rather than listing them
