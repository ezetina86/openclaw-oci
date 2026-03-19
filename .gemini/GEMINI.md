# OpenClaw Gemini Project Context

## Project Status
- Infrastructure: Provisioning (Region: us-chicago-1)
- Compute: Ampere ARM (Shape: VM.Standard.A1.Flex)
- OS: Ubuntu 22.04 LTS
- Ingress: Cloudflare Tunnel (Zero-Trust)
- Container Engine: Rootless Podman

## Mandates and Rules
- NO EMOJIS: Do not use emojis in documentation, code comments, or terminal logs.
- Rootless: Always manage containers via systemd --user.
- Infrastructure: Use OpenTofu for all HCL configurations.
