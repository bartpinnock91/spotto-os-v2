# MCP Server Setup

This repo uses several MCP servers for product management workflow:

| Server | Purpose |
|--------|---------|
| **Figma** | Access design files directly from Figma links |
| **Jira/Confluence** | Push stories to Jira, pull completed stories, access Confluence |
| **Google Analytics** | Query GA4 data for Spotto products |

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

## Security Notes

- Never commit `.env` to git (it's in `.gitignore`)
- API tokens have the same permissions as your account
- Rotate tokens periodically
