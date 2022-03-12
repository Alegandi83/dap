--Uncomment the 4 lines below to create a stored procedure for data pipeline orchestration​
--CREATE PROC bulk_load_RoleNew
--AS
--BEGIN
COPY INTO dbo.RoleNew
(RoleID 1, Name 2, Email 3, Roles 4)
FROM 'https://dlscsag83datadev.dfs.core.windows.net/healthcare-info-protection/RoleNew'
WITH
(
	FILE_TYPE = 'CSV'
	,MAXERRORS = 0
	,FIELDTERMINATOR = ';'
	,FIRSTROW = 2
	,ERRORFILE = 'https://dlscsag83datadev.dfs.core.windows.net/healthcare-info-protection/'
)
--END
GO

SELECT TOP 100 * FROM dbo.RoleNew
GO