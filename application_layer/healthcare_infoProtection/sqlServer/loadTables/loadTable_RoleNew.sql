USE hpi
GO

TRUNCATE TABLE hpi.RoleNew
GO

BULK INSERT hpi.RoleNew
FROM 'C:\code\modern-data-warehouse-dataops\e2e_samples\parking_sensors_synapse\application_layer\healthcare_infoProtection\data\RoleNew.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO