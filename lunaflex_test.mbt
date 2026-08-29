///|
test "core contract stays narrow" {
  inspect(@lunaflex.core_version(), content="0.1.0")
  assert_eq(@lunaflex.core_abi_version(), 1)
  debug_inspect(
    @lunaflex.core_capabilities(),
    content=(
      #|<ReadOnlyArray:
      #|  [
      #|    DenseBf16,
      #|    SingleCudaDevice,
      #|    ContinuousBatching,
      #|    PagedKvMetadata,
      #|    PrefixReuse,
      #|    AotExecution,
      #|  ]>
    ),
  )
  assert_true(
    @lunaflex.is_core_compatible(1, [
      DenseBf16,
      SingleCudaDevice,
      ContinuousBatching,
      PagedKvMetadata,
      PrefixReuse,
      AotExecution,
    ]),
  )
  assert_false(@lunaflex.is_core_compatible(2, [DenseBf16]))
}
