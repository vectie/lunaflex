# LunaFlex implementation guide

LunaFlex is the narrow MoonBit-native inference core extracted from LunaFlux.
Read `README.mbt.md`, `docs/ARCHITECTURE.md`, and `docs/PROVENANCE.md` before
changing package boundaries.

- Keep first-party planning and control paths in MoonBit with native targets.
- Do not add Python, PyTorch, TVM, HTTP, OCI, NCCL, or fleet dependencies.
- Keep CUDA and cuBLASLt behind private narrow native ABI packages.
- Require explicit deterministic release for GPU resources.
- Keep production kernels AOT and content-addressed; no request-path JIT.
- Keep scheduler code independent of HTTP, model families, and device backends.
- Keep model-specific branching in model plan builders and hardware-specific
  branching in device or kernel packages.
- Avoid steady-state heap allocation in token-step scheduling paths.

At a completed phase boundary run:

```sh
moon info
moon fmt
moon check --target native --deny-warn
moon test --target native --deny-warn
```
