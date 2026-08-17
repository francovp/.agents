# Adaptive Cards — Common Patterns

Full ready-to-use card templates.

---

## Notification Card

```json
{
  "$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.2",
  "body": [
    {
      "type": "ColumnSet",
      "columns": [
        {
          "type": "Column", "width": "auto",
          "items": [{ "type": "Image", "url": "https://example.com/icon.png", "size": "small", "altText": "App icon" }]
        },
        {
          "type": "Column", "width": "stretch",
          "items": [
            { "type": "TextBlock", "text": "Deployment Complete", "weight": "bolder", "wrap": true },
            { "type": "TextBlock", "text": "Production · 2 min ago", "isSubtle": true, "size": "small", "wrap": true }
          ]
        }
      ]
    },
    {
      "type": "TextBlock",
      "text": "Version **2.4.1** was deployed successfully to production. All health checks passed.",
      "wrap": true
    },
    {
      "type": "FactSet",
      "facts": [
        { "title": "Environment", "value": "Production" },
        { "title": "Build",       "value": "#1042" },
        { "title": "Duration",    "value": "3m 12s" }
      ]
    }
  ],
  "actions": [
    { "type": "Action.OpenUrl", "title": "View Logs", "url": "https://example.com/logs" },
    { "type": "Action.OpenUrl", "title": "Release Notes", "url": "https://example.com/releases" }
  ]
}
```

---

## Approval Workflow Card (Universal Action Model)

```json
{
  "$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.4",
  "refresh": {
    "action": {
      "type": "Action.Execute",
      "verb": "getApprovalStatus",
      "data": { "requestId": "REQ-001" }
    },
    "userIds": ["alice@example.com", "bob@example.com"]
  },
  "body": [
    { "type": "TextBlock", "text": "Approval Request", "weight": "bolder", "size": "medium", "wrap": true },
    {
      "type": "FactSet",
      "facts": [
        { "title": "Requested by", "value": "Carol" },
        { "title": "Date",         "value": "2025-07-29" },
        { "title": "Amount",       "value": "$4,500" },
        { "title": "Status",       "value": "Pending" }
      ]
    },
    { "type": "TextBlock", "text": "Office equipment purchase for Q3 project setup.", "wrap": true, "isSubtle": true }
  ],
  "actions": [
    { "type": "Action.Execute", "title": "Approve", "verb": "approve", "style": "positive", "data": { "requestId": "REQ-001" } },
    { "type": "Action.Execute", "title": "Reject",  "verb": "reject",  "style": "destructive", "data": { "requestId": "REQ-001" } },
    { "type": "Action.ShowCard", "title": "Comment", "card": {
        "type": "AdaptiveCard",
        "body": [{ "type": "Input.Text", "id": "comment", "placeholder": "Add a comment…", "isMultiline": true, "label": "Comment" }],
        "actions": [{ "type": "Action.Execute", "title": "Submit Comment", "verb": "comment", "data": { "requestId": "REQ-001" } }]
      }
    }
  ]
}
```

---

## Form Card

```json
{
  "$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.3",
  "body": [
    { "type": "TextBlock", "text": "Create New Ticket", "weight": "bolder", "size": "medium", "wrap": true },
    {
      "type": "Container",
      "style": "emphasis",
      "items": [
        { "type": "Input.Text",   "id": "title",    "label": "Title",       "placeholder": "Brief description", "isRequired": true, "errorMessage": "Title is required" },
        { "type": "Input.Text",   "id": "describe", "label": "Description", "isMultiline": true, "placeholder": "Steps to reproduce…" },
        { "type": "Input.ChoiceSet", "id": "priority", "label": "Priority", "style": "compact", "value": "medium",
          "choices": [
            { "title": "Critical", "value": "critical" },
            { "title": "High",     "value": "high" },
            { "title": "Medium",   "value": "medium" },
            { "title": "Low",      "value": "low" }
          ]
        },
        { "type": "Input.Date", "id": "dueDate", "label": "Due Date" }
      ]
    }
  ],
  "actions": [
    { "type": "Action.Submit", "title": "Create Ticket", "style": "positive", "data": { "action": "createTicket" } }
  ]
}
```

---

## Collapsible Section Card

```json
{
  "$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.2",
  "body": [
    { "type": "TextBlock", "text": "Summary Report", "weight": "bolder", "size": "medium", "wrap": true },
    { "type": "TextBlock", "text": "Click below to see detailed metrics.", "wrap": true },
    {
      "type": "ActionSet",
      "actions": [
        {
          "type": "Action.ToggleVisibility",
          "title": "Show Details",
          "targetElements": ["detailsSection"]
        }
      ]
    },
    {
      "type": "Container",
      "id": "detailsSection",
      "isVisible": false,
      "style": "emphasis",
      "items": [
        { "type": "TextBlock", "text": "Detailed Metrics", "weight": "bolder", "wrap": true },
        {
          "type": "FactSet",
          "facts": [
            { "title": "Total Requests", "value": "12,400" },
            { "title": "Errors",         "value": "3 (0.02%)" },
            { "title": "P99 Latency",    "value": "240ms" }
          ]
        }
      ]
    }
  ]
}
```

---

## Person / Profile Card

```json
{
  "$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.1",
  "body": [
    {
      "type": "ColumnSet",
      "columns": [
        {
          "type": "Column", "width": "auto",
          "items": [{ "type": "Image", "url": "https://example.com/avatar.png", "size": "medium", "style": "person", "altText": "Alice" }]
        },
        {
          "type": "Column", "width": "stretch",
          "verticalContentAlignment": "center",
          "items": [
            { "type": "TextBlock", "text": "Alice Johnson", "weight": "bolder", "wrap": true },
            { "type": "TextBlock", "text": "Senior Engineer · Platform Team", "isSubtle": true, "size": "small", "wrap": true }
          ]
        }
      ]
    },
    { "type": "TextBlock", "text": "alice.johnson@example.com", "wrap": true }
  ],
  "actions": [
    { "type": "Action.OpenUrl", "title": "Send Email", "url": "mailto:alice.johnson@example.com" },
    { "type": "Action.OpenUrl", "title": "View Profile", "url": "https://example.com/profile/alice" }
  ]
}
```
