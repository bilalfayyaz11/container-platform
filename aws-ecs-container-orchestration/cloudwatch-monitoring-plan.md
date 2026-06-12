# ECS CloudWatch Monitoring Plan

## Metrics

- CPUUtilization
- MemoryUtilization
- RunningTaskCount
- PendingTaskCount
- Service desired count
- Load balancer target health
- HTTP 5xx count
- Target response time

## Alarms

- ECS service CPU utilization greater than 80 percent for 10 minutes
- Running task count below 2
- Load balancer unhealthy host count greater than 0
- HTTP 5xx errors above baseline

## Dashboard Widgets

- ECS CPU utilization
- ECS memory utilization
- Running task count
- ALB request count
- ALB target response time
- ALB unhealthy targets
