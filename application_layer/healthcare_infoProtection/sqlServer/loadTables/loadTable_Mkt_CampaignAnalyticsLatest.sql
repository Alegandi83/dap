USE hpi
GO

TRUNCATE TABLE hpi.[Mkt_CampaignAnalyticLatest]
GO

BULK INSERT hpi.[Mkt_CampaignAnalyticLatest]
FROM 'C:\code\modern-data-warehouse-dataops\e2e_samples\parking_sensors_synapse\application_layer\healthcare_infoProtection\data\Mkt_CampaignAnalyticLatest.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO