--Uncomment the 4 lines below to create a stored procedure for data pipeline orchestration​
--CREATE PROC bulk_load_Mkt_CampaignAnalyticLatest
--AS
--BEGIN
COPY INTO dbo.Mkt_CampaignAnalyticLatest
(Region 1, Country 2, ProductCategory 3, Campaign_ID 4, Campaign_Name 5, Qualification 6, Qualification_Number 7, Response_Status 8, Responses 9, Cost 10, Revenue 11, ROI 12, Lead_Generation 13, Revenue_Target 14, Campaign_Tactic 15, Customer_Segment 16, Status 17, Profit 18, Marketing_Cost 19, CampaignID 20)
FROM 'https://dlscsag83datadev.dfs.core.windows.net/healthcare-info-protection/Mkt_CampaignAnalyticLatest'
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

SELECT TOP 100 * FROM dbo.Mkt_CampaignAnalyticLatest
GO