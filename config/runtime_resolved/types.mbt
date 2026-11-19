///|
/// Cross-component startup relations checked by runtime capacity resolution.
pub(all) enum RuntimeCapacityRule {
  EmergencyReserveWithinPhysicalPages
  ContextFitsBlockTable
  TotalRequestSlots
  WorkerTokenBudget
  WorkerPlanRows
  WorkerPrefillRows
  WorkerDecodeRows
  WorkerCompletionSlots
  WorkerSequenceTokens
  WorkerPlanPages
  RecomputeHistoryCapacity
  WorkerTokenIdRange
  OutputEventCapacity
  ModelBatchRows
  PageAllocatorLimits
  BlockTableLimits
  PrefixIndexLimits
} derive(Debug, Eq)

///|
/// Payload-safe startup failure. The rule names only bounded configuration
/// categories; it contains no model path, request data, or device details.
pub(all) suberror RuntimeCapacityError {
  Invalid(RuntimeCapacityRule)
} derive(Debug, Eq)

///|
/// Stable subjects for derived startup-capacity explanations.
pub(all) enum RuntimeCapacitySubject {
  ContextPagesPerRequest
  TotalRequestSlots
  MaxRowsPerStep
  WorkerPageTableCells
  RecomputeHistoryCells
  PlanBufferCount
  PageGenerationLimit
  BlockTableGenerationLimit
} derive(Debug, Eq)

///|
/// Stable reasons for deterministic startup-capacity decisions.
pub(all) enum RuntimeCapacityReason {
  CeilingDivision
  CombinedConfiguredCapacity
  MinimumOfActiveAndTokenBudget
  RowsTimesContextPages
  RequestSlotsTimesMaximumGeneratedTokens
  FixedDoubleBuffer
  OwnerMaximumGenerationDefault
} derive(Debug, Eq)

///|
/// One bounded explanation for a derived startup capacity.
pub struct RuntimeCapacityDecision {
  subject : RuntimeCapacitySubject
  reason : RuntimeCapacityReason
} derive(Debug, Eq)

///|
/// Immutable startup-only materialization of scheduler, cache, model-shape,
/// worker-protocol, and host KV metadata capacity relations.
///
/// It deliberately contains no device KV byte count, kernel support claim, or
/// live mutable runtime state.
pub struct ResolvedRuntimeCapacity {
  priv tokens_per_page : Int32
  priv total_page_count : Int32
  priv context_pages_per_request : Int32
  priv block_table_pages_per_request : Int32
  priv max_active_requests : Int32
  priv max_waiting_requests : Int32
  priv total_request_slots : Int32
  priv step_token_budget : Int32
  priv prefill_chunk_tokens : Int32
  priv emergency_decode_page_reserve : Int32
  priv waiting_age_threshold_steps : Int32
  priv output_event_capacity : Int32
  priv max_rows_per_step : Int32
  priv required_worker_page_table_cells : Int32
  priv maximum_generated_tokens_per_request : Int32
  priv required_recompute_history_cells : Int32
  priv model_max_batch_rows : Int32
  priv model_max_sequence_tokens : Int32
  priv worker_max_prefill_rows : Int32
  priv worker_max_decode_rows : Int32
  priv worker_max_plan_rows : Int32
  priv worker_max_plan_tokens : Int32
  priv worker_max_plan_pages : Int32
  priv worker_max_capabilities : Int32
  priv worker_max_completion_slots : Int32
  priv worker_max_sequence_tokens : Int32
  priv worker_max_token_id : Int32
  priv page_allocator_limits : @page_allocator.PageAllocatorLimits
  priv block_table_limits : @block_table.BlockTableLimits
  priv prefix_index_limits : @radix.PrefixIndexLimits?
  priv prefix_layout : @radix.PrefixLayout
  priv decisions : ReadOnlyArray[RuntimeCapacityDecision]
} derive(Debug, Eq)
