USE hpi
GO

TRUNCATE TABLE hpi.PatientInformation
GO

BULK INSERT hpi.PatientInformation
FROM '/my_dap_data/PatientInformation.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\r\n'   --Use to shift the control to next row
)
GO