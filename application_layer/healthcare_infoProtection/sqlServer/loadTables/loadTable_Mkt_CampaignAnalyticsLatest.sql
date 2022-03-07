USE hpi
GO

TRUNCATE TABLE hpi.[Mkt_CampaignAnalyticLatest]
GO

BULK INSERT hpi.[Mkt_CampaignAnalyticLatest]
FROM '/my_dap_data/Mkt_CampaignAnalyticLatest.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO