# Architecture

LunaFlex is a native inference library, not a serving product. Its dependency
direction is intentionally one-way:

1. `internal/*` owns narrow native and validation primitives.
2. `model/*`, `tokenizer/*`, `kernels/*`, and `device` admit immutable startup
   data and execution contracts.
3. `kv/*`, `prefix/radix`, `sampling`, and `scheduler/core` own token-step
   state transitions.
4. `engine/*` combines admitted plans with device resources and reference or
   static execution.

The hot path must not perform filesystem access, cryptography, artifact
admission, model-family discovery, or unbounded allocation. GPU resources are
linear owners with explicit close or abort operations.

## Supported envelope

The first release targets one CUDA device, dense BF16 Llama-family models,
continuous batching, paged-KV metadata, prefix reuse, deterministic sampling,
and content-addressed AOT kernels. Reference execution remains available for
deterministic correctness tests.

Multi-GPU collectives, quantized execution, serving protocols, deployment, and
fleet policy remain outside this repository.

## Consumer integration

LunaFlex is consumed as a normal MoonBit module and linked into its host. The
root package exposes a small ABI/capability contract so a host can fail its
build or startup acceptance checks when the required core envelope changes.
This is compile-time composition, not runtime dynamic-library loading.

Concrete model, scheduler, and device types remain owned by their focused
LunaFlex packages. Consumers should migrate whole owning-package boundaries;
they must not translate between duplicate LunaFlux and LunaFlex nominal types
inside the token-step path.
