# Adaptive Cards — Platform Notes

## Microsoft Teams

- **Supported schema version**: up to 1.5 (Bot Framework) / 1.6 (Teams AI Library / Copilot extensions)
- **Card delivery**: via Bot Framework `Activity.attachments` or `message extensions`
- **Recommended action type**: `Action.Execute` with Universal Action Model (UAM)
  - Enables server-side refresh without re-sending the card
  - Bot receives `Invoke` activity with `name: "adaptiveCard/action"` and `value.action`
  - Bot returns updated card in the Invoke response
- **`Action.Submit`** still works but does not support refresh; avoided in new Teams apps
- **Inputs**: Submitted as `activity.value.data` merged with `action.data`
- **Card width**: ~320 px mobile, ~640 px desktop — design for mobile first
- **Mentions**: Use `<at>alias</at>` in `TextBlock.text` with `msteams.entities` array in card root
- **Adaptive Card tabs**: version 1.4+ supported; `Action.Execute` required
- **Copilot extensions**: use version 1.6, `Action.Execute` only

### Teams Mention Example

```json
{
  "type": "TextBlock",
  "text": "Hi <at>Alice</at>, your task is due.",
  "wrap": true
},
"msteams": {
  "entities": [
    {
      "type": "mention",
      "text": "<at>Alice</at>",
      "mentioned": { "id": "alice@example.com", "name": "Alice" }
    }
  ]
}
```

---

## Outlook Actionable Messages

- **Supported schema version**: up to 1.4
- **Action type**: `Action.Execute` only (submit to a service endpoint)
- **Requires `originator`** property in the card `authentication` section (registered provider ID)
- Cards must be sent from a verified sender domain registered in the Actionable Email Developer Dashboard
- **Refresh** supported via `refresh.action` (`Action.Execute`)
- Cards are embedded in email HTML with `<script type="application/adaptivecard+json">`

---

## Power Automate / Power Apps

- **Supported schema version**: up to 1.3
- **Action type**: `Action.Submit`
- Used in Approval flows and "Post an Adaptive Card" Teams actions
- `Input.*` values surfaced as dynamic content in the flow

---

## Bot Framework Web Chat

- **Supported schema version**: up to 1.5
- **Action type**: `Action.Submit` (sends `activity` back to bot)
- Full JavaScript SDK available at [BotFramework-WebChat](https://github.com/microsoft/BotFramework-WebChat)

---

## Version Feature Quick Reference

| Feature | Min Version |
| ------- | ----------- |
| `selectAction` on containers | 1.1 |
| `Media` element | 1.1 |
| `ColumnSet` style/bleed | 1.2 |
| `RichTextBlock` | 1.2 |
| `ActionSet` inline | 1.2 |
| Input validation (`isRequired`, `errorMessage`, `label`) | 1.3 |
| Input `regex` | 1.3 |
| `Action.Execute` / UAM | 1.4 |
| Card `refresh` | 1.4 |
| Card `authentication` | 1.4 |
| `Table` element | 1.5 |
| `rtl` support | 1.5 |
| `TextBlock` `style: "heading"` | 1.5 |
| Action `tooltip`, `isEnabled`, `mode` | 1.5 |
| Compound Button, overflow menu | 1.6 |
