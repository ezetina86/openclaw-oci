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

## CI/CD Strategy
- **Pipeline:** Our primary infrastructure validation mechanism is defined in `.github/workflows/infra-ci.yml`.
- **Early Triggers:** To ensure early feedback, the pipeline triggers asynchronously on pushes to any feature branch (`feat/*`, `fix/*`, `chore/*`) as well as Pull Requests targeting `dev` or `main`.
- **Validation Checks:** Every CI run enforces formatting (`tofu fmt`), structural validity (`tofu validate`), mocked test assertions (`tofu test`), and comprehensive security scanning via Checkov.
- **Credential Safety:** Due to the use of `-backend=false` and `.tftest` mock providers, the CI pipeline simulates OCI environments safely without requiring live provider secrets on GitHub.
- **Pre-commit Workflow:** Local developers run lightweight `pre-commit` hooks (configured in `.pre-commit-config.yaml`) strictly for fast file formatting. Heavy validations are explicitly deferred to the automated CI pipeline to avoid local development blockers.

## Mandates and Rules
- NO EMOJIS: Do not use emojis in documentation, code comments, or terminal logs.
- Rootless: Always manage containers via systemd --user.
- Infrastructure: Use OpenTofu for all HCL configurations.
- Testing: All OpenTofu configuration additions must include a corresponding `.tftest.hcl` file testing structure via plan validations under `/infra/tests/`.
- Project Logo: If a new document is created in the future, the `logo.png` file must be added/included in it.
- NO AI MERGE: Antigravity is strictly UNAUTHORIZED to merge Pull Requests. All merges must be manually performed by the USER after review.
