USE hpi
GO

INSERT INTO [hpi].[ControlTableForTemplate]
SELECT		ROW_NUMBER() OVER(order by name) as PartitionID,
			SCHEMA_NAME(schema_id) as SourceTableSchema,
			name as SourceTableName,
			'select * from ' + SCHEMA_NAME(schema_id) + '.' + name AS FilterQuery
FROM		sys.tables
GO