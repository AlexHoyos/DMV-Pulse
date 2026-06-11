CREATE PROCEDURE dmvpulse.usp_GetQueryExecutionPlan
    @PlanHandleStr NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF @PlanHandleStr IS NULL
    BEGIN
        SELECT CAST(NULL AS NVARCHAR(MAX)) AS QueryPlanXML, 'Plan handle is required.' AS ErrorMessage;
        RETURN;
    END;

    -- Clean the string and ensure it has 0x prefix
    SET @PlanHandleStr = LTRIM(RTRIM(@PlanHandleStr));
    IF @PlanHandleStr NOT LIKE '0x%'
    BEGIN
        SET @PlanHandleStr = '0x' + @PlanHandleStr;
    END;

    DECLARE @PlanHandle VARBINARY(64);
    BEGIN TRY
        SET @PlanHandle = CONVERT(VARBINARY(64), @PlanHandleStr, 1);
    END TRY
    BEGIN CATCH
        SELECT CAST(NULL AS NVARCHAR(MAX)) AS QueryPlanXML, 'Invalid hex plan handle format.' AS ErrorMessage;
        RETURN;
    END CATCH;

    -- Retrieve the XML query plan. Note: sys.dm_exec_query_plan returns query_plan which is XML.
    -- To ensure DAB can return it cleanly as a string, we cast it to NVARCHAR(MAX).
    SELECT 
        CAST(qp.query_plan AS NVARCHAR(MAX)) AS QueryPlanXML,
        CAST(NULL AS NVARCHAR(MAX)) AS ErrorMessage
    FROM sys.dm_exec_query_plan(@PlanHandle) qp;
END;
