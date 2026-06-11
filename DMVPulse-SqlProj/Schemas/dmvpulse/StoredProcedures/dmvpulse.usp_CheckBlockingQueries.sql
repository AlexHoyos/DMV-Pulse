CREATE PROCEDURE dmvpulse.usp_CheckBlockingQueries
AS
BEGIN
    SET NOCOUNT ON;

    -- Temporary table to store blocking session details
    CREATE TABLE #BlockingDetails (
        SessionID INT,
        BlockingSessionID INT,
        WaitTimeSeconds INT,
        QueryText NVARCHAR(MAX),
        BlockingQueryText NVARCHAR(MAX),
        BlockingCause NVARCHAR(50)
    );

    -- Insert blocking session details into the temporary table
    INSERT INTO #BlockingDetails (SessionID, BlockingSessionID, WaitTimeSeconds, QueryText, BlockingQueryText, BlockingCause)
    SELECT 
        r.session_id AS SessionID,
        r.blocking_session_id AS BlockingSessionID,
        r.wait_time / 1000 AS WaitTimeSeconds,
        t.text AS QueryText,
        COALESCE(bt.text, btc.text) AS BlockingQueryText,
        CASE 
            WHEN br.session_id IS NOT NULL THEN 'Script'
            WHEN bs.open_transaction_count > 0 THEN 'Transaction'
            ELSE 'Idle Session'
        END AS BlockingCause
    FROM sys.dm_exec_requests r
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
    LEFT JOIN sys.dm_exec_requests br ON r.blocking_session_id = br.session_id
    LEFT JOIN sys.dm_exec_connections bc ON r.blocking_session_id = bc.session_id
    LEFT JOIN sys.dm_exec_sessions bs ON r.blocking_session_id = bs.session_id
    OUTER APPLY sys.dm_exec_sql_text(br.sql_handle) bt
    OUTER APPLY sys.dm_exec_sql_text(bc.most_recent_sql_handle) btc
    WHERE r.wait_time > 30000 -- Filter for sessions blocked for more than 30 seconds
    ORDER BY r.wait_time;

    -- Return the blocking session details
    SELECT SessionID, BlockingSessionID, WaitTimeSeconds, QueryText, BlockingQueryText, BlockingCause FROM #BlockingDetails;

    -- Clean up
    DROP TABLE #BlockingDetails;
END;