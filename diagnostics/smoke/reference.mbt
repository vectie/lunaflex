///|
/// Result of executing the deterministic tiny-Llama acceptance path.
pub struct ReferenceSmokeReport {
  core_version : String
  operation_count : Int32
  input_tokens : Int32
  generated_tokens : ReadOnlyArray[Int32]
} derive(Debug, Eq)

///|
pub fn ReferenceSmokeReport::core_version(
  self : ReferenceSmokeReport,
) -> String {
  self.core_version
}

///|
pub fn ReferenceSmokeReport::operation_count(
  self : ReferenceSmokeReport,
) -> Int32 {
  self.operation_count
}

///|
pub fn ReferenceSmokeReport::input_tokens(self : ReferenceSmokeReport) -> Int32 {
  self.input_tokens
}

///|
pub fn ReferenceSmokeReport::generated_tokens(
  self : ReferenceSmokeReport,
) -> ReadOnlyArray[Int32] {
  self.generated_tokens
}

///|
pub fn ReferenceSmokeReport::summary(self : ReferenceSmokeReport) -> String {
  "lunaflex \{self.core_version} reference-smoke ok operations=\{self.operation_count} input=\{self.input_tokens} generated=[\{self.generated_tokens[0]},\{self.generated_tokens[1]},\{self.generated_tokens[2]}]"
}

///|
pub(all) suberror ReferenceSmokeError {
  UnexpectedOperationCount(expected~ : Int32, actual~ : Int32)
  UnexpectedSelection(expected~ : Int32, actual~ : Int32)
  UnexpectedGeneratedCount(expected~ : Int32, actual~ : Int32)
  UnexpectedGeneratedToken(
    position~ : Int32,
    expected~ : Int32,
    actual~ : Int32
  )
} derive(Debug, Eq)

///|
fn tiny_model() -> @spec.LlamaModelMetadata raise {
  let model_spec = @spec.LlamaModelSpec::new(
    vocabulary_size=3,
    hidden_size=2,
    intermediate_size=2,
    layer_count=1,
    attention_head_count=1,
    kv_head_count=1,
    context_length=4,
    rope_theta=10000.0,
    rms_norm_epsilon=0.000001,
    weight_dtype=BFloat16,
    kv_dtype=BFloat16,
  )
  let content = @spec.ContentDigest::from_sha256(
    "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
  )
  @spec.LlamaModelMetadata::from_verified_content(model_spec, content)
}

///|
fn append_bfloat16(output : Array[Byte], values : ArrayView[Float]) -> Unit {
  for value in values {
    let bits = value.reinterpret_as_uint()
    output.push((bits >> 16).to_byte())
    output.push((bits >> 24).to_byte())
  }
}

///|
fn append_tensor(
  entries : Array[@safetensors.RawTensorMetadata],
  payload : Array[Byte],
  name : String,
  shape : ArrayView[Int64],
  values : ArrayView[Float],
) -> Unit {
  let start = payload.length().to_int64()
  append_bfloat16(payload, values)
  entries.push(
    @safetensors.RawTensorMetadata::new(
      name~,
      dtype="BF16",
      shape~,
      data_start=start,
      data_end=payload.length().to_int64(),
    ),
  )
}

///|
fn tiny_weights() -> @materialize.HostMaterialization raise {
  let entries : Array[@safetensors.RawTensorMetadata] = []
  let payload : Array[Byte] = []
  append_tensor(entries, payload, "model.embed_tokens.weight", [3L, 2L], [
    1.0F,
    0.0F,
    0.0F,
    1.0F,
    -1.0F,
    -1.0F,
  ])
  append_tensor(
    entries,
    payload,
    "model.layers.0.input_layernorm.weight",
    [2L],
    [1.0F, 1.0F],
  )
  for
    name in [
      "model.layers.0.self_attn.q_proj.weight", "model.layers.0.self_attn.k_proj.weight",
      "model.layers.0.self_attn.v_proj.weight", "model.layers.0.self_attn.o_proj.weight",
    ] {
    append_tensor(entries, payload, name, [2L, 2L], [0.0F, 0.0F, 0.0F, 0.0F])
  }
  append_tensor(
    entries,
    payload,
    "model.layers.0.post_attention_layernorm.weight",
    [2L],
    [1.0F, 1.0F],
  )
  for
    name in [
      "model.layers.0.mlp.gate_proj.weight", "model.layers.0.mlp.up_proj.weight",
      "model.layers.0.mlp.down_proj.weight",
    ] {
    append_tensor(entries, payload, name, [2L, 2L], [0.0F, 0.0F, 0.0F, 0.0F])
  }
  append_tensor(entries, payload, "model.norm.weight", [2L], [1.0F, 1.0F])
  append_tensor(entries, payload, "lm_head.weight", [3L, 2L], [
    1.0F,
    0.0F,
    0.0F,
    1.0F,
    -1.0F,
    -1.0F,
  ])
  let header_bytes = 16
  let header_limits = @safetensors.HeaderLimits::new(
    max_header_bytes=128,
    max_tensor_count=16,
    max_rank=2,
    max_name_length=128,
    max_payload_bytes=1024L,
    max_materialized_tensor_bytes=1024L,
  )
  let metadata = @safetensors.validate_metadata(
    entries,
    encoded_header_bytes=header_bytes,
    payload_bytes=payload.length().to_int64(),
    limits=header_limits,
  )
  let model = tiny_model()
  let plan = @llama.build(model)
  let bindings = @llama_weights.bind(model, plan, metadata)
  let file : Array[Byte] = [header_bytes.to_byte(), 0, 0, 0, 0, 0, 0, 0]
  file.push(b'{')
  file.push(b'}')
  for _ in 2..<header_bytes {
    file.push(b' ')
  }
  for byte in payload {
    file.push(byte)
  }
  let limits = @materialize.MaterializationLimits::new(
    max_header_bytes=128,
    max_tensor_count=16,
    max_payload_bytes=1024L,
    max_host_bytes=1024L,
  )
  @materialize.copy_to_host(bindings, Bytes::from_array(file), limits~)
}

///|
fn execution_limits() -> @reference.ExecutionLimits raise {
  @reference.ExecutionLimits::new(
    kernels=@refkernels.ReferenceLimits::new(
      max_rows=4,
      max_columns=8,
      max_elements=32,
    ),
    sampling=@sampling.SamplingLimits::new(1, 3),
    max_operations=16,
    max_tensors=12,
    max_input_tokens=4,
  )
}

///|
/// Builds, materializes, executes, samples, and generates with a tiny BF16
/// Llama graph. This is a CPU reference-path acceptance check, not a benchmark.
pub fn run_reference_smoke() -> ReferenceSmokeReport raise {
  let plan = @llama.build(tiny_model())
  let limits = execution_limits()
  let prepared = @reference.prepare(plan, tiny_weights(), limits~)
  let executed = @reference.execute(plan, prepared, [0], limits~)
  if executed.operation_count() != 12 {
    raise ReferenceSmokeError::UnexpectedOperationCount(
      expected=12,
      actual=executed.operation_count(),
    )
  }
  if executed.selection().token_id() != 0 {
    raise ReferenceSmokeError::UnexpectedSelection(
      expected=0,
      actual=executed.selection().token_id(),
    )
  }
  let generated = @reference.generate(
    plan,
    prepared,
    [0],
    max_new_tokens=3,
    limits~,
  )
  let tokens = generated.generated_tokens()
  if tokens.length() != 3 {
    raise ReferenceSmokeError::UnexpectedGeneratedCount(
      expected=3,
      actual=tokens.length(),
    )
  }
  for position, token in tokens {
    if token != 0 {
      raise ReferenceSmokeError::UnexpectedGeneratedToken(
        position~,
        expected=0,
        actual=token,
      )
    }
  }
  {
    core_version: @lunaflex.core_version(),
    operation_count: executed.operation_count(),
    input_tokens: generated.input_tokens(),
    generated_tokens: tokens,
  }
}
