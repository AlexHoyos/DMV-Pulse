CREATE PROCEDURE dmvpulse.usp_GetMissingIndexes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 20
        migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS EstimatedImprovement,
        mid.statement AS TableName,
        'CREATE INDEX [IX_' + OBJECT_NAME(mid.object_id, mid.database_id) + '_' + CAST(mid.index_handle AS VARCHAR(10)) + ']' +
        ' ON ' + mid.statement + ' (' + ISNULL(mid.equality_columns, '') + 
        CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END + 
        ISNULL(mid.inequality_columns, '') + ')' +
        ISNULL(' INCLUDE (' + mid.included_columns + ')', '') AS CreateIndexStatement,
        mid.equality_columns AS EqualityColumns,
        mid.inequality_columns AS InequalityColumns,
        mid.included_columns AS IncludedColumns,
        migs.user_seeks AS UserSeeks,
        migs.user_scans AS UserScans,
        migs.avg_user_impact AS AvgUserImpact
    FROM sys.dm_db_missing_index_groups mig
    INNER JOIN sys.dm_db_missing_index_group_stats migs 
        ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details mid 
        ON mig.index_handle = mid.index_handle
    ORDER BY EstimatedImprovement DESC;
END;
