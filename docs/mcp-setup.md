# MCP Server Setup

This repo uses several MCP servers for product management workflow:

| Server | Purpose |
|--------|---------|
| **Figma** | Access design files directly from Figma links |
| **Jira/Confluence** | Push stories to Jira, pull completed stories, access Confluence |
| **Google Analytics** | Query GA4 data for Spotto products |
| **MSSQL** (`mssql`) | Read-only SQL access to the Spotto **platform** DB (`dbo.Publications`, `Customers`, …) |
| **MSSQL** (`mssql-comparison`) | Read-only SQL access to the Vergelijkingspanden **reference/comparison** DB (`databricks` schema) for PR/data analyses |

## 1. Figma MCP Setup

Figma uses OAuth authentication (browser-based).

### Steps:
1. Open Claude Code in this repo
2. The Figma MCP server will prompt you to authenticate via browser
3. Log in with your Figma account
4. Done - you can now use Figma links in conversations

### Usage:
Just paste a Figma frame link and ask Claude to analyze the design.

## 2. Jira MCP Setup

Jira requires an API token.

### Generate API Token:
1. Go to [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click "Create API token"
3. Give it a label (e.g., "Claude Code")
4. Copy the token

### Configure Environment:
1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your credentials:
   ```
   JIRA_URL=https://your-company.atlassian.net
   JIRA_USERNAME=your.email@company.com
   JIRA_API_TOKEN=your_token_here
   ```

3. Restart Claude Code to pick up the new config

### Usage:
Ask Claude to create issues, search for tickets, or pull completed stories.

## Troubleshooting

### Figma not connecting
- Make sure you're logged into Figma in your browser
- Try re-authenticating by restarting Claude Code

### Jira not connecting
- Verify your API token is valid
- Check that JIRA_URL doesn't have a trailing slash
- Ensure your Atlassian account has access to the projects

## 3. Google Analytics MCP Setup (Windows)

Google Analytics uses Application Default Credentials (ADC). On Windows, there's a workaround required.

### Prerequisites:
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed
- Access to the `spotto-production` GCP project
- `analytics-mcp` installed: `pip install analytics-mcp`

### Setup Steps:

1. **Authenticate with the correct scopes:**
   ```powershell
   gcloud auth application-default login --scopes="https://www.googleapis.com/auth/analytics.readonly,https://www.googleapis.com/auth/cloud-platform"
   ```
   This opens a browser - log in with your Google account that has GA access.

2. **Set the quota project:**
   ```powershell
   gcloud auth application-default set-quota-project spotto-production
   ```

3. **Copy credentials to the expected location (Windows workaround):**
   ```powershell
   copy "$env:APPDATA\gcloud\application_default_credentials.json" "$env:USERPROFILE\application_default_credentials.json"
   ```

4. **Restart Claude Code** to reload the MCP server.

### Usage:
Ask Claude to query Google Analytics data. Always use the **Spotto - V2** property (ID: `491908260`).

### Troubleshooting

**`invalid_grant: Bad Request`**
- Credentials have expired. Re-run steps 1-3 above.

**`ACCESS_TOKEN_SCOPE_INSUFFICIENT`**
- You authenticated without the Analytics scope. Re-run step 1 with the `--scopes` flag.

**`SERVICE_DISABLED` / quota project error**
- Run step 2 to set the quota project.

## 4. MSSQL (SQL Server) MCP Setup

This is the SQL MCP used for the data-driven PR analyses (see `products/spotto/drafts/PR/`). It gives Claude **read-only** SQL access to the Vergelijkingspanden reference database (referred to in the PR notes as the `mssql-comparison` / "comparison" DB, `databricks` schema).

> **Which DB?** This is the comparison/reference database (`realestatecomparison-api-production-db` on server `xqrzu6hyjd.database.windows.net`), whose `databricks` schema federates into the Databricks workspace `adb-697404674670473`. It is **not** the Spotto platform DB (`oris-prod-immox-sql` / `oris-prod-immox-properties`) — that one holds `dbo.Publications`, `Customers`, etc. and has no `ReferenceProperties*` tables. The `ReferencePropertiesPublications` / `ReferenceProperties` / `…PublicationPrices` tables the PR queries use live only here.

### What it is

The **Node MSSQL MCP server** from Microsoft's [Azure-Samples/SQL-AI-samples](https://github.com/Azure-Samples/SQL-AI-samples) (`MssqlMcp/Node`). The **same built binary** is registered **twice** with Claude — once per database — using different env vars:

| Server name | Database | Tool prefix | Use for |
| ----------- | -------- | ----------- | ------- |
| `mssql` | Spotto **platform** DB — `oris-prod-immox-sql.database.windows.net` / `oris-prod-immox-properties` | `mcp__mssql__…` | Platform data: `dbo.Publications`, `Customers`, `RealtorProfiles`, … |
| `mssql-comparison` | Vergelijkingspanden **reference/comparison** DB — `xqrzu6hyjd.database.windows.net` / `realestatecomparison-api-production-db` | `mcp__mssql-comparison__…` | PR/data analyses: `databricks.ReferencePropertiesPublications`, `ReferenceProperties`, `…PublicationPrices`, … |

> **Which one?** The `databricks`-schema `ReferenceProperties*` tables the PR queries use (`products/spotto/drafts/PR/`) live **only in `mssql-comparison`** (its `databricks` schema federates into the Databricks workspace `adb-697404674670473`). The platform DB on `mssql` has **no** `ReferenceProperties*` tables. The PR notes cite the source as MCP `mssql-comparison` for exactly this reason.

> **Note:** Microsoft removed this Node sample from the `SQL-AI-samples` repo on 2026-06-03 (commit `0ea8cf9`, "Removed problematic MCP sample") and now points to the Data API Builder-based SQL MCP Server instead. We therefore pin to the **last good commit `f7233135`** (2025-10-14). The local copy under `~/mcp-servers/mssql-mcp` is that snapshot, shared by both server registrations.

In **read-only mode** (`READONLY=true`) each server exposes three tools: `list_table`, `read_data`, `describe_table`. With `READONLY=false` it would also expose `insert_data`, `update_data`, `create_table`, `create_index`, `drop_table` — **do not enable this** against the production DBs.

### Prerequisites

- Node.js (built/tested on Node 24) and npm
- Azure AD (Entra ID) account with read access to both `oris-prod-immox-sql.database.windows.net` and `xqrzu6hyjd.database.windows.net`
- A browser on the machine (auth is interactive — see below)

### Install / build

```bash
# 1. Get the last good source (folder was removed from the repo's main branch)
REF=f72331350b3d2e41f91a67d31aa7838837c3d196
B=https://raw.githubusercontent.com/Azure-Samples/SQL-AI-samples/$REF/MssqlMcp/Node
DEST=~/mcp-servers/mssql-mcp
mkdir -p "$DEST/src/tools"
for f in package.json package-lock.json tsconfig.json README.md LICENSE src/index.ts \
  src/tools/CreateIndexTool.ts src/tools/CreateTableTool.ts src/tools/DescribeTableTool.ts \
  src/tools/DropTableTool.ts src/tools/InsertDataTool.ts src/tools/ListTableTool.ts \
  src/tools/ReadDataTool.ts src/tools/UpdateDataTool.ts; do
  curl -sfL "$B/$f" -o "$DEST/$f"
done

# 2. Install deps + build (npm's `prepare` script runs `tsc` → produces dist/index.js)
cd "$DEST" && npm install
```

### Register with Claude Code

Both are registered at **user scope** (available in every project; the absolute path is machine-specific so it stays out of git):

```bash
# 1) Spotto platform DB
claude mcp add mssql -s user \
  --env SERVER_NAME=oris-prod-immox-sql.database.windows.net \
  --env DATABASE_NAME=oris-prod-immox-properties \
  --env READONLY=true \
  -- node C:/Users/bartp/mcp-servers/mssql-mcp/dist/index.js

# 2) Vergelijkingspanden reference/comparison DB
claude mcp add mssql-comparison -s user \
  --env SERVER_NAME=xqrzu6hyjd.database.windows.net \
  --env DATABASE_NAME=realestatecomparison-api-production-db \
  --env READONLY=true \
  -- node C:/Users/bartp/mcp-servers/mssql-mcp/dist/index.js
```

Env vars (per server):

| Env var | `mssql` | `mssql-comparison` | Purpose |
| ------- | ------- | ------------------ | ------- |
| `SERVER_NAME` | `oris-prod-immox-sql.database.windows.net` | `xqrzu6hyjd.database.windows.net` | Azure SQL server |
| `DATABASE_NAME` | `oris-prod-immox-properties` | `realestatecomparison-api-production-db` | Database |
| `READONLY` | `true` | `true` | Restrict to `list_table` / `read_data` / `describe_table` |
| `TRUST_SERVER_CERTIFICATE` | *(optional)* `true`/`false` | *(optional)* | TLS cert trust |
| `CONNECTION_TIMEOUT` | *(optional)* seconds | *(optional)* | Connection timeout (default 30) |

### Authentication

Auth uses Azure AD via `InteractiveBrowserCredential` (scope `https://database.windows.net/.default`). **No `az` CLI or stored secret is needed** — there is no password in the config. The DB connection is made **lazily on the first tool call**: the first time Claude runs a `read_data`/`describe_table` query, a browser window opens to log you into Azure AD. The access token is then cached and refreshed automatically for the session.

### Verify

```bash
# Protocol check (does NOT touch the DB): both should report ✓ Connected
claude mcp list        # → mssql: ... ✓ Connected  /  mssql-comparison: ... ✓ Connected
```

To verify actual DB connectivity, ask Claude to run a small query and complete the browser login when it pops up — e.g. `mssql-comparison` → `describe_table` on `databricks.ReferencePropertiesPublications`, or `mssql` → `read_data` `SELECT TOP 1 * FROM dbo.Publications`.

> **After re-registering, reload MCP in the running session** (Claude Code `/mcp` → reconnect, or restart) — live MCP processes keep their original env until reloaded, so config changes won't take effect mid-session.

### Troubleshooting

- **No browser appears / login loop** — the credential redirects to `http://localhost`; make sure no other process holds that port and that a default browser is set.
- **`Login failed` / access denied** — your Azure AD account needs read rights on the database; confirm with `sqlcmd -S <server> -d <database> -G`.
- **`✓ Connected` but queries fail** — "Connected" only means the stdio process started; DB errors surface on the first query. Check you're using the right server (`databricks.*` tables exist only on `mssql-comparison`; `dbo.*` platform tables only on `mssql`).
- **Rebuild after a Node/dep change** — `cd ~/mcp-servers/mssql-mcp && npm run build` (rebuilds the shared binary used by both servers).

## Security Notes

- Never commit `.env` to git (it's in `.gitignore`)
- API tokens have the same permissions as your account
- Rotate tokens periodically
