# Malicious Containers Workshop

A hands-on workshop covering Kubernetes and container security — from offensive techniques to detection and response. Learn to build, deploy, and detect malicious containers in a safe lab environment.

## Repository Structure

- **`current/`** — The latest version of the workshop materials, labs, and infrastructure setup. Start here.
- **`archived/`** — Previous conference-specific versions (DEF CON 30, DEF CON 31, BSides Charleston, CactusCon, ISSA Triad). Preserved for reference.

## Getting Started

See [`current/README.md`](current/README.md) for an overview and [`current/lab-setup.md`](current/lab-setup.md) for environment setup instructions.

## Workshop Modules

1. **Docker Fundamentals** — Images, containers, layers, process hierarchy
2. **Exploring Containers** — Image history, reverse engineering, extracting artifacts
3. **Offensive Docker Techniques** — Data exfiltration, socket hijacking, privilege escalation
4. **Container IR** — Image forensics CTF, cleanup
5. **Kubernetes 101** — Architecture, components, networking
6. **Kubernetes Security** — RBAC abuse, privilege escalation, golden ticket attacks, evil pods
7. **Supply Chain Security** — Image signing (cosign/Sigstore), SBOMs (syft), vulnerability scanning (grype), provenance
8. **Modern Runtime Security** — Tracee, Falco, Tetragon — eBPF-based detection and comparison
9. **Cloud-Native Attacks** — IMDS exploitation, workload identity abuse, network policy bypass

## Presenters

### Instructor: David Mitchell
> [@digish0](https://twitter.com/digish0) | https://digital-shokunin.net

### Instructor: Adrian Wood
> [@whitehacksec](https://twitter.com/WHITEHACKSEC) | https://5stars217.github.io

## Our lockpick/hacker(space) group

[![FALE logo](https://github.com/lockfale/Malicious_Containers_Workshop/assets/913856/4a836cf4-cc97-49ec-a4c8-ed739c83820e)](https://github.com/lockFALE/)

## License

See [LICENSE](LICENSE).
