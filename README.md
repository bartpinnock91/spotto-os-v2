# Spotto OS - Product Management

Product management repository for Spotto's real estate products.

## Products

| Product | Type | Description |
|---------|------|-------------|
| [Spotto](products/spotto/) | B2C | Real estate platform for property search |
| [Vergelijkingspanden](products/vergelijkingspanden/) | B2B | Comparable properties tool for pricing |
| [Markttendensen](products/markttendensen/) | B2B | Market insights dashboard |

## Structure

```
├── company/          # Shared company context
├── products/         # Per-product folders
│   ├── {product}/
│   │   ├── context/  # Personas, competitors
│   │   ├── roadmap/  # Product roadmap
│   │   ├── drafts/   # WIP stories
│   │   └── archive/  # Completed stories
└── templates/        # Story templates
```

## Workflow

This repo is the **drafting ground**. Jira is the **source of truth**.

1. Draft stories here
2. Push finalized stories to Jira
3. Archive completed stories back here (with metadata)

See [CLAUDE.md](CLAUDE.md) for detailed workflow instructions.
