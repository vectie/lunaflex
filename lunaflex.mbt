///|
/// The deliberately narrow capability envelope of the LunaFlex core.
pub(all) enum CoreCapability {
  DenseBf16
  SingleCudaDevice
  ContinuousBatching
  PagedKvMetadata
  PrefixReuse
  AotExecution
} derive(Debug, Eq)

///|
/// Stable semantic version of the extracted core contract.
pub fn core_version() -> String {
  "0.1.0"
}

///|
/// Capabilities intentionally retained in the first extracted core.
pub fn core_capabilities() -> ReadOnlyArray[CoreCapability] {
  ReadOnlyArray::from_array([
    DenseBf16,
    SingleCudaDevice,
    ContinuousBatching,
    PagedKvMetadata,
    PrefixReuse,
    AotExecution,
  ])
}
