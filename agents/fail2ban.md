# Fail2ban Notes

## Validate filters with `fail2ban-regex`

Fail2ban detects and removes recognized timestamps before applying `failregex`. A filter that requires the access log's literal timestamp field can therefore look correct as a standalone regular expression while matching nothing in Fail2ban.

Always validate filters with the real `fail2ban-regex` command and representative positive and negative log lines. Anchor trusted fields such as `<HOST>`, the request, and the response status, but allow for the timestamp section to have been stripped before matching.
