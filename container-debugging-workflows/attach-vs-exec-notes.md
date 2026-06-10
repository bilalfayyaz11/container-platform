# Docker Attach vs Exec Notes

docker attach connects your terminal directly to the main process of a running container.
If Ctrl+C is sent while attached, it can stop the container because the signal reaches PID 1.

docker exec starts a new process inside the running container.
It is safer for troubleshooting because exiting the exec shell does not stop the main container process.

Recommended production troubleshooting approach:
- Use docker logs for output inspection.
- Use docker exec for shell access and diagnostics.
- Avoid docker attach unless you intentionally need to interact with the main process.
