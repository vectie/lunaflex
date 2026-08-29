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
/// Compile-time integration ABI for consumers such as LunaFlux.
pub fn core_abi_version() -> Int {
  1
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

///|
/// Tests whether this build satisfies a consumer's narrow core contract.
pub fn is_core_compatible(
  required_abi : Int,
  required_capabilities : ArrayView[CoreCapability],
) -> Bool {
  if required_abi != core_abi_version() {
    return false
  }
  let available = core_capabilities()
  for required in required_capabilities {
    if !available.contains(required) {
      return false
    }
  }
  true
}
