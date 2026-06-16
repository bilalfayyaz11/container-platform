# Container Security Manifest

This manifest documents the security controls applied to the hardened Python container runtime and the threat each control reduces.

| Control | Implementation | Threat Mitigated |
|---|---|---|
| non-root execution | Dockerfile uses USER 10001:10001 | Reduces impact if the application process is compromised because it does not run as UID 0. |
| read-only filesystem | Container runs with --read-only | Prevents attackers from modifying application files, binaries, or system paths inside the container. |
| tmpfs scratch space | Container runs with --tmpfs /tmp:rw,noexec,nosuid,size=32m | Provides a controlled writable location without allowing persistent filesystem modification. |
| capabilities dropped | Container runs with --cap-drop ALL | Removes Linux privileges that could otherwise allow dangerous kernel-level actions. |
| AppArmor enforcement | Container runs with --security-opt apparmor=docker-hardened-python | Restricts sensitive file and kernel interface access using mandatory access control. |
| no privilege escalation | Container runs with --security-opt no-new-privileges:true | Blocks the process from gaining extra privileges through setuid or similar mechanisms. |
| content trust workflow | Local registry workflow and DCT validation script document image integrity controls | Demonstrates image provenance validation requirements and prevents blind trust in unsigned image tags. |
| resource limits | Container runs with --memory 256m and --cpus 0.5 | Limits denial-of-service impact from memory exhaustion or CPU abuse. |
| automatic restart | Container runs with --restart unless-stopped | Improves service resilience if the container process crashes. |
| local registry boundary | Image is pushed to localhost:5000 instead of an external registry | Avoids accidental publication of internal runtime images. |
