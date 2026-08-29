# LunaFlex

LunaFlex is the extracted, MoonBit-native transformer inference core from
LunaFlux. It keeps the deterministic model, tokenizer, scheduling, KV,
prefix-reuse, sampling, device, static-execution, and BF16 kernel foundations
without carrying serving adapters, deployment promotion, release evidence,
tensor parallelism, NCCL, FP8, or I8.

## Boundary

The first core owns:

- bounded tokenizer and model metadata admission;
- safetensors validation and dense Llama weight binding;
- immutable model, device, memory, and execution plans;
- continuous-batching scheduler state;
- generational paged-KV metadata and compressed prefix reuse;
- deterministic sampling;
- explicit CUDA resource ownership behind a private ABI;
- stateless BF16/reference execution contracts.

HTTP, OpenAI compatibility, process supervision, fleet integration, OCI,
release evidence, quantization, multi-GPU execution, and kernel qualification
campaigns belong in separate projects or optional packages.

## Provenance

The initial source was mechanically extracted from LunaFlux and retains its
Apache-2.0 license. Package imports were renamed from `vectie/lunaflux` to
`vectie/lunaflex`; optional feature edges were removed rather than reimplemented.
See [docs/PROVENANCE.md](docs/PROVENANCE.md) for the exact source revision and
compatibility decisions.

The package layout and dependency rules are documented in
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Validation

~~~sh
moon info
moon fmt
moon check --target native --deny-warn
moon test --target native --deny-warn
~~~
