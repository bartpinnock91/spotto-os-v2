# MCP Server Setup

This repo uses two MCP servers for product management workflow:

| Server | Purpose |
|--------|---------|
| **Figma** | Access design files directly from Figma links |
| **Jira** | Push stories to Jira, pull completed stories |

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

## Security Notes

- Never commit `.env` to git (it's in `.gitignore`)
- API tokens have the same permissions as your account
- Rotate tokens periodically
