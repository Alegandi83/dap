USE hpi
GO

TRUNCATE TABLE hpi.HospitalEmpPIIData
GO

BULK INSERT hpi.HospitalEmpPIIData
FROM '/my_dap_data/HospitalEmpPIIData.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO