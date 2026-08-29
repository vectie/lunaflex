///|
test "core contract stays narrow" {
  inspect(@lunaflex.core_version(), content="0.1.0")
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
}
