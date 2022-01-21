USE hpi
GO

TRUNCATE TABLE hpi.HospitalEmpPIIData
GO

BULK INSERT hpi.HospitalEmpPIIData
FROM 'C:\code\modern-data-warehouse-dataops\e2e_samples\parking_sensors_synapse\application_layer\healthcare_infoProtection\data\HospitalEmpPIIData.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO