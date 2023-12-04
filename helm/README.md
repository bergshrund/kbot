# Kbot helm chart

This chart requires the secret.token value to be set for proper functionality.

```
helm install kbot ./kbot-1.0.0.tgz --set secret.token=<api-token>
```

where **api-token** is a base64 encoded value of Telegram HTTP API access token obtained during the bot creation process.
