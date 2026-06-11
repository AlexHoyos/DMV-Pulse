CREATE PROCEDURE dmvpulse.usp_GetPlansForQuery
    @QueryHashStr VARCHAR(64) = NULL,
    @SearchText NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @QueryHash BINARY(8);
    IF @QueryHashStr IS NOT NULL
    BEGIN
        -- Clean the string and ensure it has 0x prefix
        SET @QueryHashStr = LTRIM(RTRIM(@QueryHashStr));
        IF @QueryHashStr NOT LIKE '0x%'
        BEGIN
            SET @QueryHashStr = '0x' + @QueryHashStr;
        END;
        BEGIN TRY
            SET @QueryHash = CONVERT(BINARY(8), @QueryHashStr, 1);
        END TRY
        BEGIN CATCH
            -- Invalid format, will fall back or return empty
            SET @QueryHash = NULL;
        END CATCH;
    END;

    -- If no query hash is provided but search text is, find the query hash of the top matching query
    IF @QueryHash IS NULL AND @SearchText IS NOT NULL
    BEGIN
        SELECT TOP 1 @QueryHash = qs.query_hash
        FROM sys.dm_exec_query_stats qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
        WHERE st.text LIKE '%' + @SearchText + '%'
        ORDER BY qs.total_elapsed_time DESC;
    END;

    IF @QueryHash IS NULL
    BEGIN
        -- Return empty result if no query hash found
        SELECT 
            CAST(NULL AS VARCHAR(64)) AS PlanHandle,
            CAST(NULL AS VARCHAR(64)) AS QueryPlanHash,
            CAST(NULL AS VARCHAR(64)) AS QueryHash,
            0 AS ExecutionCount,
            0.0 AS AvgElapsedTimeMs,
            0.0 AS MinElapsedTimeMs,
            0.0 AS MaxElapsedTimeMs,
            0.0 AS ElapsedTimeDiffMs,
            0.0 AS AvgCPUMs,
            0.0 AS AvgLogicalReads,
            CAST(NULL AS NVARCHAR(MAX)) AS QueryText
        WHERE 1 = 0;
        RETURN;
    END;

    -- Return stats for all plans associated with this query hash
    SELECT 
        CONVERT(VARCHAR(64), qs.plan_handle, 1) AS PlanHandle,
        CONVERT(VARCHAR(64), qs.query_plan_hash, 1) AS QueryPlanHash,
        CONVERT(VARCHAR(64), qs.query_hash, 1) AS QueryHash,
        qs.execution_count AS ExecutionCount,
        (qs.total_elapsed_time / qs.execution_count) / 1000.0 AS AvgElapsedTimeMs,
        qs.min_elapsed_time / 1000.0 AS MinElapsedTimeMs,
        qs.max_elapsed_time / 1000.0 AS MaxElapsedTimeMs,
        (qs.max_elapsed_time - qs.min_elapsed_time) / 1000.0 AS ElapsedTimeDiffMs,
        (qs.total_worker_time / qs.execution_count) / 1000.0 AS AvgCPUMs,
        (qs.total_logical_reads / qs.execution_count) AS AvgLogicalReads,
        SUBSTRING(st.text, (qs.statement_start_offset/2)+1,   
            ((CASE qs.statement_end_offset   
                WHEN -1 THEN DATALENGTH(st.text)  
                ELSE qs.statement_end_offset   
            END - qs.statement_start_offset)/2) + 1) AS QueryText
    FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
    WHERE qs.query_hash = @QueryHash
    ORDER BY AvgElapsedTimeMs DESC;
END;
