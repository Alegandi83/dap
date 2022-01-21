USE hpi
GO

TRUNCATE TABLE hpi.Campaign_Analytics_New
GO

BULK INSERT hpi.Campaign_Analytics_New
FROM 'C:\code\modern-data-warehouse-dataops\e2e_samples\parking_sensors_synapse\application_layer\healthcare_infoProtection\data\Campaign_Analytics_New.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO