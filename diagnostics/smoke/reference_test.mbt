///|
test "tiny BF16 Llama completes the reference acceptance path" {
  let report = @smoke.run_reference_smoke()
  inspect(report.core_version(), content="0.1.0")
  assert_eq(report.operation_count(), 12)
  assert_eq(report.input_tokens(), 1)
  assert_eq(report.generated_tokens(), [0, 0, 0])
  inspect(
    report.summary(),
    content=(
      #|lunaflex 0.1.0 reference-smoke ok operations=12 input=1 generated=[0,0,0]
    ),
  )
}
