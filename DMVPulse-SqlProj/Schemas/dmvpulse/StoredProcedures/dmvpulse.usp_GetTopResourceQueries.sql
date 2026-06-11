CREATE PROCEDURE dmvpulse.usp_GetTopResourceQueries
    @Metric VARCHAR(10) = 'CPU',
    @TopCount INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    -- Ensure TopCount is positive and not excessively large
    SET @TopCount = COALESCE(@TopCount, 10);
    IF @TopCount <= 0 SET @TopCount = 10;
    IF @TopCount > 100 SET @TopCount = 100;

    SELECT TOP (@TopCount)
        CONVERT(VARCHAR(64), qs.plan_handle, 1) AS PlanHandle,
        CONVERT(VARCHAR(64), qs.query_hash, 1) AS QueryHash,
        qs.execution_count AS ExecutionCount,
        qs.total_worker_time / 1000.0 AS TotalCPUMs,
        (qs.total_worker_time / qs.execution_count) / 1000.0 AS AvgCPUMs,
        (qs.total_logical_reads + qs.total_logical_writes) AS TotalIO,
        ((qs.total_logical_reads + qs.total_logical_writes) / qs.execution_count) AS AvgIO,
        qs.total_elapsed_time / 1000.0 AS TotalDurationMs,
        (qs.total_elapsed_time / qs.execution_count) / 1000.0 AS AvgDurationMs,
        SUBSTRING(st.text, (qs.statement_start_offset/2)+1,   
            ((CASE qs.statement_end_offset   
                WHEN -1 THEN DATALENGTH(st.text)  
                ELSE qs.statement_end_offset   
            END - qs.statement_start_offset)/2) + 1) AS QueryText
    FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
    ORDER BY 
        CASE WHEN UPPER(@Metric) = 'CPU' THEN qs.total_worker_time END DESC,
        CASE WHEN UPPER(@Metric) = 'IO' THEN (qs.total_logical_reads + qs.total_logical_writes) END DESC,
        CASE WHEN UPPER(@Metric) = 'DURATION' THEN qs.total_elapsed_time END DESC,
        qs.total_worker_time DESC; -- default fallback
END;
