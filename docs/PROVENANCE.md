# Extraction provenance

LunaFlex 0.1.0 was extracted from LunaFlux commit
`adbd19e1104c3348923f426f7830e31b6c7f6a8a`.

The extraction copied the narrow model, tokenizer, scheduler, KV, prefix,
sampling, device, AOT-kernel, and reference-execution package closure. MoonBit
imports moved from `vectie/lunaflux` to `vectie/lunaflex`, and private native
symbols moved from the `lunaflux_` prefix to `lunaflex_` so the two libraries
cannot collide in one process.

Canonical byte-domain strings intentionally retain their existing `lunaflux.`
prefix. Those strings are protocol identifiers, not package names; changing
them would silently invalidate plan, numeric-contract, and artifact digests.

The extraction deliberately removed:

- HTTP and OpenAI-compatible serving adapters;
- process supervision and worker lifecycle orchestration;
- OCI, release, qualification, and evidence pipelines;
- NCCL and tensor-parallel execution;
- Mistral-specific configuration support;
- FP8 and I8 execution paths.

This is a source extraction, not a rewrite. New work should preserve the narrow
boundary instead of copying higher product layers back from LunaFlux.
