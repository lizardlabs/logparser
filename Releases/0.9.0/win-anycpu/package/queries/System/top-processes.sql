-- title: Top processes snapshot
-- description: Rank local processes by working-set memory and sampled CPU usage.
-- category: System
-- command: ps
-- provider: Processes
-- source: *
-- table: process_snapshot
-- input-options: -CpuSampleMilliseconds:250 -MaximumRows:0 -IncludeDetails:ON -IgnoreInaccessible:ON
-- default-format: Terminal
-- default-destination: console
-- parameter: limit=25

SELECT ProcessId,
       ProcessName,
       round(CpuPercent, 2) AS CpuPercent,
       HUMANIZE_BYTES(WorkingSetBytes, '0.##') AS WorkingSet,
       HUMANIZE_BYTES(PrivateMemoryBytes, '0.##') AS PrivateMemory,
       ThreadCount,
       HandleCount,
       AccessStatus
FROM process_snapshot
ORDER BY WorkingSetBytes DESC, CpuPercent DESC
LIMIT CAST(coalesce(:limit, 25) AS INTEGER);
