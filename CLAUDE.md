# Product Management Workflow

This repo is the **thinking ground** for product management. Jira is the **source of truth** for active work.

## Products

| Product | Folder | Description |
|---------|--------|-------------|
| Spotto | `products/spotto/` | B2C real estate platform (spotto.be) |
| Vergelijkingspanden | `products/vergelijkingspanden/` | B2B comparable properties tool for agents |
| Markttendensen | `products/markttendensen/` | B2B market insights dashboard |

## Workflow

```
DRAFT (here) → PUSH TO JIRA → JIRA (active) → DONE → ARCHIVE (here)
```

### 1. Drafting Stories

Create draft stories in `products/{product}/drafts/` using templates from `templates/`.

**Draft status lifecycle:**
- `Draft` - Work in progress, not ready
- `Ready for Jira` - Finalized, ready to push

### 2. Pushing to Jira

When a story is "Ready for Jira":
1. Use Jira MCP to create the ticket
2. Add the Jira ticket ID to the draft
3. Move or delete the draft (Jira is now source of truth)

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

| Server | Purpose | Usage |
|--------|---------|-------|
| **Figma** | Access designs | Paste Figma frame links in conversations |
| **Jira** | Push/pull stories | Create tickets, query issues, archive done stories |

Setup instructions: [docs/mcp-setup.md](docs/mcp-setup.md)

### Working with Designs

Each product has its own Figma file. When working on a product:
1. Share the relevant Figma link for the feature/screen
2. Claude can fetch design context directly via MCP
3. Include Figma links in draft stories for reference

## Guidelines

- **Never edit archived stories** - they are immutable records
- **Drafts are disposable** - Jira becomes the source once pushed
- **Context is valuable** - Keep product context up to date
- **Use templates** - Ensures consistency across stories
- **Include Figma links** - Reference designs in stories when relevant
