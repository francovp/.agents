---
name: adaptive-cards
description: >
  Design and generate Adaptive Cards JSON using the official schema. Use when the user asks to
  create, build, author, design, or generate an Adaptive Card, a Teams card, a bot card, an
  Outlook Actionable Message, a Copilot card, or any JSON card payload for Microsoft platforms.
  Trigger on: 'adaptive card', 'AdaptiveCard', 'Teams card', 'bot message card', 'Outlook card',
  'actionable message', 'card JSON', 'TextBlock', 'ColumnSet', 'Action.Submit', 'Action.Execute',
  'card schema', 'card designer', 'notification card', 'approval card', 'form card',
  'adaptive-card.json', 'hero card', 'thumbnail card Teams'.
argument-hint: 'Describe the card (purpose, layout, inputs needed, target platform)'
---

# Adaptive Cards

Generate valid, well-structured Adaptive Card JSON for Microsoft Teams, Copilot, Outlook, and Bot Framework.

**Schema**: `https://adaptivecards.io/schemas/adaptive-card.json`  
**Docs**: https://adaptivecards.microsoft.com/  
**Designer**: https://adaptivecards.io/designer/  
**Explorer**: https://adaptivecards.io/explorer/

---

## Card Skeleton

Always start with this root structure:

```json
{
  "$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.5",
  "body": [],
  "actions": []
}
```

**Version guidance** — use the minimum version required:

| Version | Key additions |
|---------|---------------|
| 1.0 | TextBlock, Image, basic actions |
| 1.1 | Media, selectAction on containers |
| 1.2 | ColumnSet style/bleed, RichTextBlock, ActionSet inline |
| 1.3 | Input validation (`isRequired`, `errorMessage`, `label`) |
| 1.4 | `Action.Execute` (Universal Action Model), Refresh, Authentication |
| 1.5 | Table, `rtl`, `TextBlockStyle: "heading"`, action `tooltip`/`isEnabled`/`mode` |
| 1.6 | Compound Button, overflow menu (Fluent-only hosts) |

Teams supports up to **1.5** (Bot Framework) and **1.6** (Copilot/Teams AI Library).  
Outlook Actionable Messages support up to **1.4**.

---

## Elements

### TextBlock
```json
{
  "type": "TextBlock",
  "text": "Hello **World**",
  "size": "large",       // default|small|medium|large|extraLarge
  "weight": "bolder",    // default|lighter|bolder
  "color": "accent",     // default|dark|light|accent|good|warning|attention
  "wrap": true,          // always set true unless single-line is intentional
  "isSubtle": false,
  "maxLines": 3,
  "horizontalAlignment": "left",  // left|center|right
  "style": "heading"    // default|heading (v1.5+)
}
```

### Image
```json
{
  "type": "Image",
  "url": "https://example.com/image.png",
  "altText": "Description for accessibility",
  "size": "medium",      // auto|stretch|small|medium|large
  "style": "person",     // default|person (circular crop)
  "horizontalAlignment": "center"
}
```

### Container
Groups elements. Supports `style`, `bleed`, `selectAction`, `backgroundImage`, `minHeight`.
```json
{
  "type": "Container",
  "style": "emphasis",   // default|emphasis|good|attention|warning|accent
  "bleed": true,         // extend to parent edge, ignoring padding
  "items": []
}
```

### ColumnSet / Column
Side-by-side layout. Each `Column` is a container with a `width`.
```json
{
  "type": "ColumnSet",
  "columns": [
    {
      "type": "Column",
      "width": "auto",     // auto|stretch|"<N>px"|relative number
      "items": []
    },
    {
      "type": "Column",
      "width": "stretch",
      "items": []
    }
  ]
}
```

### FactSet
Name/value pair table.
```json
{
  "type": "FactSet",
  "facts": [
    { "title": "Status", "value": "Active" },
    { "title": "Owner",  "value": "Alice" }
  ]
}
```

### ActionSet
Renders actions inline inside the body (not the bottom action bar).
```json
{ "type": "ActionSet", "actions": [] }
```

### Table (v1.5+)
```json
{
  "type": "Table",
  "firstRowAsHeader": true,
  "showGridLines": true,
  "columns": [
    { "type": "TableColumnDefinition", "width": 1 },
    { "type": "TableColumnDefinition", "width": 2 }
  ],
  "rows": [
    {
      "type": "TableRow",
      "cells": [
        { "type": "TableCell", "items": [{ "type": "TextBlock", "text": "Name", "wrap": true }] },
        { "type": "TableCell", "items": [{ "type": "TextBlock", "text": "Value", "wrap": true }] }
      ]
    }
  ]
}
```

### RichTextBlock (v1.2+)
Inline formatting with mixed styles.
```json
{
  "type": "RichTextBlock",
  "inlines": [
    { "type": "TextRun", "text": "Bold ", "weight": "bolder" },
    { "type": "TextRun", "text": "and italic", "italic": true }
  ]
}
```

---

## Actions

### Action.OpenUrl
```json
{ "type": "Action.OpenUrl", "title": "Learn More", "url": "https://example.com" }
```

### Action.Submit
Collects all inputs and sends to the host. For Bot Framework / Teams bots.
```json
{
  "type": "Action.Submit",
  "title": "Submit",
  "data": { "action": "submitForm", "customField": "value" }
}
```

### Action.Execute (v1.4+ — Universal Action Model, preferred for Teams)
```json
{
  "type": "Action.Execute",
  "title": "Approve",
  "verb": "approveRequest",
  "data": { "requestId": "123" },
  "style": "positive"    // default|positive|destructive
}
```

### Action.ShowCard
Expands an inline sub-card on click. Good for progressive disclosure.
```json
{
  "type": "Action.ShowCard",
  "title": "Show Details",
  "card": {
    "type": "AdaptiveCard",
    "body": [{ "type": "TextBlock", "text": "Extra info", "wrap": true }]
  }
}
```

### Action.ToggleVisibility (v1.2+)
Show/hide elements by ID.
```json
{
  "type": "Action.ToggleVisibility",
  "title": "Toggle",
  "targetElements": ["elementId1", { "elementId": "elementId2", "isVisible": false }]
}
```

**Action common properties**: `title`, `iconUrl`, `style` (default|positive|destructive), `tooltip` (v1.5), `isEnabled` (v1.5), `mode` (primary|secondary, v1.5), `fallback`.

---

## Inputs

All inputs require `id`. Use `label`, `isRequired`, `errorMessage` (v1.3+) for forms.

### Input.Text
```json
{
  "type": "Input.Text",
  "id": "email",
  "label": "Email address",
  "placeholder": "user@example.com",
  "style": "email",       // text|tel|url|email|password
  "isRequired": true,
  "errorMessage": "Please enter a valid email",
  "regex": "^[^@]+@[^@]+$",
  "isMultiline": false,
  "maxLength": 100
}
```

### Input.Number
```json
{ "type": "Input.Number", "id": "qty", "label": "Quantity", "min": 1, "max": 99, "value": 1 }
```

### Input.Date / Input.Time
```json
{ "type": "Input.Date", "id": "dueDate", "label": "Due date", "min": "2024-01-01" }
{ "type": "Input.Time", "id": "meetingTime", "label": "Time", "min": "09:00", "max": "17:00" }
```

### Input.Toggle
```json
{
  "type": "Input.Toggle",
  "id": "agree",
  "title": "I agree to the terms",
  "value": "false",
  "valueOn": "true",
  "valueOff": "false"
}
```

### Input.ChoiceSet
```json
{
  "type": "Input.ChoiceSet",
  "id": "priority",
  "label": "Priority",
  "style": "compact",     // compact|expanded
  "isMultiSelect": false,
  "value": "medium",
  "choices": [
    { "title": "High",   "value": "high" },
    { "title": "Medium", "value": "medium" },
    { "title": "Low",    "value": "low" }
  ]
}
```

---

## Common Card Patterns

See [common-patterns.md](./references/common-patterns.md) for full examples.

### Notification / Alert
- Header with icon + title in `ColumnSet`
- `TextBlock` body with `wrap: true`
- One or two `Action.OpenUrl` buttons

### Approval Workflow
- `FactSet` with request details
- Two actions: `Action.Execute` with `style: "positive"` (Approve) and `style: "destructive"` (Reject)
- Use `Action.Execute` + Universal Action Model for refreshable state

### Form / Data Collection
- `Input.*` elements with `label`, `isRequired`, `errorMessage`
- `Action.Submit` or `Action.Execute` to collect
- Group related inputs in `Container` with `style: "emphasis"`

### Collapsible Section
- `Action.ToggleVisibility` button + a `Container` with matching `id` and `isVisible: false`

---

## Platform Notes

| Platform | Max version | Action type | Notes |
|----------|-------------|-------------|-------|
| Teams Bot | 1.5 | `Action.Submit` or `Action.Execute` | UAM preferred for refreshable cards |
| Teams Copilot/AI Library | 1.6 | `Action.Execute` | Use UAM; avoid `Action.Submit` |
| Outlook Actionable Messages | 1.4 | `Action.Execute` | Requires `originator` in `authentication` section |
| Bot Framework Web Chat | 1.5 | `Action.Submit` | |
| Power Automate / Approvals | 1.3 | `Action.Submit` | |

Full platform support matrix: https://adaptivecards.microsoft.com/

---

## Design Best Practices

1. **Always set `wrap: true`** on `TextBlock` — clipped text is a common bug.
2. **Use `ColumnSet` sparingly** on mobile; prefer vertical stacking when in doubt.
3. **`style: "emphasis"`** on Container provides visual grouping without borders.
4. **Keep cards narrow-friendly** — Teams renders cards at ~320–400 px on mobile.
5. **Use `size: "small"` text** for metadata; `size: "large"` only for headlines.
6. **Don't rely on `backgroundImage`** — some hosts don't render it.
7. **Validate with the Designer** at https://adaptivecards.io/designer/ before shipping.
8. **Use `fallbackText`** on the root card for hosts that can't render it.
9. **Avoid deeply nested containers** — max 3 levels deep.
10. **Use `isSubtle: true`** for secondary information to reduce visual noise.

---

## Validation Checklist

- [ ] `$schema` and `type: "AdaptiveCard"` present on root
- [ ] `version` is the minimum needed (not always `"1.0"`)
- [ ] Every `Input.*` has a unique `id`
- [ ] All `TextBlock` elements have `wrap: true` (unless intentionally single-line)
- [ ] All `Image` elements have `altText`
- [ ] Card renders correctly in https://adaptivecards.io/designer/
- [ ] `Action.Execute` used instead of `Action.Submit` for Teams UAM scenarios
- [ ] No `Action.ShowCard` inside another `ShowCard` (not supported)
