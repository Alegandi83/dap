--Uncomment the 4 lines below to create a stored procedure for data pipeline orchestration​
--CREATE PROC bulk_load_HealthCare-FactSales
--AS
--BEGIN
COPY INTO [dbo].[HealthCare-FactSales]
(CareManager 1, PayerName 2, CampaignName 3, Region 4, State 5, City 6, Revenue 7, RevenueTarget 8)
FROM 'https://dlscsag83datadev.dfs.core.windows.net/healthcare-info-protection/HealthCare-FactSales'
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

SELECT TOP 100 * FROM [dbo].[HealthCare-FactSales]
GO