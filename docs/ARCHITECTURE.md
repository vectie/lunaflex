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
