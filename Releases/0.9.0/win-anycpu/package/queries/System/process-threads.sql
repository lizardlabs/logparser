-- title: Process thread snapshot
-- description: Inspect thread state, wait reason, priority, and sampled CPU for selected processes.
-- category: System
-- command: threads
-- provider: Threads
-- source: ulp
-- table: thread_snapshot
-- input-options: -CpuSampleMilliseconds:250 -MaximumRows:5000 -IncludeDetails:ON -IgnoreInaccessible:ON
-- default-format: Terminal
-- default-destination: console
-- parameter: state=

SELECT ProcessId,
       ProcessName,
       ThreadId,
       ThreadState,
       WaitReason,
       round(CpuPercent, 2) AS CpuPercent,
       CurrentPriority,
       PriorityLevel,
       AccessStatus
FROM thread_snapshot
WHERE coalesce(:state, '') = '' OR ThreadState = :state COLLATE NOCASE
ORDER BY CpuPercent DESC, ProcessId, ThreadId
LIMIT 500;
