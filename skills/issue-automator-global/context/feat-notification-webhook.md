## Summary

Add notification webhook integration to the issue-automator skill, enabling alerts to Telegram (and WhatsApp) for global deadlock events and PR-in-review transitions.

## Key Changes

### :bell: Notification Webhook System

- Added a new `Notification Webhook` section documenting environment variables: `NOTIFY_WEBHOOK_URL`, `NOTIFY_API_KEY`, `NOTIFY_CHANNELS`, `NOTIFY_TELEGRAM_CHAT_ID`, `NOTIFY_WHATSAPP_CHAT_ID`
- Provided a reusable `curl` template for sending notifications
- Defined two notification triggers: global deadlock and PR in review

### :arrows_counterclockwise: Updated Step 7 (PR in Review)

- After moving a PR to `In review`, the workflow now sends a notification with the PR URL and issue number

### :warning: Updated Error Handling

- When both CLI and MCP auth fail, the skill now sends a `GLOBAL_BLOCKED` notification before halting

## Configuration Updates

### Environment Variables

```bash
NOTIFY_WEBHOOK_URL=https://cabros-crypto-bot-telegram.onrender.com/api/webhook/message
NOTIFY_API_KEY=<required>
NOTIFY_CHANNELS=telegram,whatsapp
NOTIFY_TELEGRAM_CHAT_ID=-1001234567890
NOTIFY_WHATSAPP_CHAT_ID=120363422033474991@g.us
```

## Documentation Updates

- **Notification Webhook** Documented webhook configuration, curl helper, and event triggers in SKILL.md
- **Error Handling** Extended the CLI/MCP authentication failure section with notification instructions

---

**Review Checklist:**
- [ ] Code quality meets project standards
- [ ] Documentation is complete and accurate
- [ ] All env vars have sensible defaults where possible
