USE hpi
GO

TRUNCATE TABLE hpi.HospitalEmpPIIData
GO

BULK INSERT hpi.HospitalEmpPIIData
FROM 'C:\code\dap\application_layer\healthcare_infoProtection\data\HospitalEmpPIIData.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO