CREATE PROCEDURE dmvpulse.usp_GetSessionResourceUsage
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.session_id AS SessionID,
        s.login_name AS LoginName,
        s.host_name AS HostName,
        s.program_name AS ProgramName,
        s.status AS Status,
        COALESCE(r.cpu_time, s.cpu_time) AS CpuTimeMs,
        COALESCE(r.logical_reads, s.logical_reads) AS LogicalReads,
        COALESCE(r.reads, s.reads) AS PhysicalReads,
        COALESCE(r.writes, s.writes) AS Writes,
        COALESCE(r.total_elapsed_time, DATEDIFF(ms, s.last_request_start_time, GETDATE())) AS ElapsedTimeMs,
        (s.memory_usage * 8) AS MemoryKB, -- memory_usage is in 8 KB pages
        s.open_transaction_count AS OpenTransactionCount,
        COALESCE(st.text, cst.text) AS QueryText
    FROM sys.dm_exec_sessions s
    LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
    LEFT JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
    OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
    OUTER APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) cst
    WHERE s.session_id != @@SPID 
      AND s.is_user_process = 1
    ORDER BY CpuTimeMs DESC;
END;
