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
        BlockingQueryText NVARCHAR(MAX)
    );

    -- Insert blocking session details into the temporary table
    INSERT INTO #BlockingDetails (SessionID, BlockingSessionID, WaitTimeSeconds, QueryText, BlockingQueryText)
    SELECT 
        r.session_id AS SessionID,
        r.blocking_session_id AS BlockingSessionID,
        r.wait_time / 1000 AS WaitTimeSeconds,
        t.text AS QueryText,
        bt.text AS BlockingQueryText
    FROM sys.dm_exec_requests r
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
    LEFT JOIN sys.dm_exec_requests br ON r.blocking_session_id = br.session_id
    OUTER APPLY sys.dm_exec_sql_text(br.sql_handle) bt
    WHERE r.wait_time > 30000 -- Filter for sessions blocked for more than 30 seconds
    ORDER BY r.wait_time;

    -- Return the blocking session details
    SELECT SessionID, BlockingSessionID, WaitTimeSeconds, QueryText, BlockingQueryText FROM #BlockingDetails;

    -- Clean up
    DROP TABLE #BlockingDetails;
END;