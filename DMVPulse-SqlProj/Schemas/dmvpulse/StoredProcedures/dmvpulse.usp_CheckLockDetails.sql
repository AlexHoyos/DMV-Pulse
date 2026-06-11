CREATE PROCEDURE dmvpulse.usp_CheckLockDetails
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        tl.request_session_id AS SessionID,
        COALESCE(DB_NAME(tl.resource_database_id), 'Unknown') AS DatabaseName,
        tl.resource_type AS ResourceType,
        tl.request_mode AS RequestMode,
        tl.request_status AS RequestStatus,
        CASE 
            WHEN tl.resource_associated_entity_id IS NOT NULL 
                 AND tl.resource_type IN ('OBJECT') 
            THEN OBJECT_NAME(tl.resource_associated_entity_id, tl.resource_database_id)
            WHEN tl.resource_associated_entity_id IS NOT NULL 
                 AND tl.resource_type IN ('KEY', 'PAGE', 'RID') 
            THEN (
                SELECT TOP 1 OBJECT_NAME(p.object_id, tl.resource_database_id)
                FROM sys.partitions p
                WHERE p.hobt_id = tl.resource_associated_entity_id
            )
            ELSE NULL
        END AS LockedObjectName,
        tl.resource_description AS ResourceDescription
    FROM sys.dm_tran_locks tl
    WHERE tl.request_session_id != @@SPID
    ORDER BY tl.request_session_id;
END;
