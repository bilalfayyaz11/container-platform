fields @timestamp, @message
| filter @message like /containerized Lambda runtime/
| sort @timestamp desc
| limit 20
