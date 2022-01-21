USE hpi
GO

TRUNCATE TABLE hpi.PatientInformation
GO

BULK INSERT hpi.PatientInformation
FROM 'C:\code\modern-data-warehouse-dataops\e2e_samples\parking_sensors_synapse\application_layer\healthcare_infoProtection\data\PatientInformation.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO