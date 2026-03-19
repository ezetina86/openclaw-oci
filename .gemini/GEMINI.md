# OpenClaw Gemini Project Context

## Project Status
- Infrastructure: Provisioning (Region: us-chicago-1)
- Compute: Ampere ARM (Shape: VM.Standard.A1.Flex)
- OS: Ubuntu 22.04 LTS
- Ingress: Cloudflare Tunnel (Zero-Trust)
- Container Engine: Rootless Podman

## Git Strategy
- Main Branch (`main`): Protected, production-ready code only.
- Development Branch (`dev`): Primary integration branch. All active development merges here before Main.
- Feature Branches (`feat/*`, `fix/*`, `chore/*`): Used for all new changes.
- Commits: Follow Conventional Commits format (e.g., `feat:`, `fix:`, `docs:`, `chore:`).

## Mandates and Rules
- NO EMOJIS: Do not use emojis in documentation, code comments, or terminal logs.
- Rootless: Always manage containers via systemd --user.
- Infrastructure: Use OpenTofu for all HCL configurations.
- Testing: All OpenTofu configuration additions must include a corresponding `.tftest.hcl` file testing structure via plan validations under `/infra/tests/`.
