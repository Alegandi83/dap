--Uncomment the 4 lines below to create a stored procedure for data pipeline orchestration​
--CREATE PROC bulk_load_Campaign_Analytics
--AS
--BEGIN
COPY INTO hpi.Campaign_Analytics
(Region 1, Country 2, Campaign_Name 3, Revenue 4, Revenue_Target 5, City 6, State 7)
FROM 'https://dlscsag83datadev.dfs.core.windows.net/healthcare-info-protection/Campaign_Analytics'
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

SELECT TOP 100 * FROM hpi.Campaign_Analytics
GO