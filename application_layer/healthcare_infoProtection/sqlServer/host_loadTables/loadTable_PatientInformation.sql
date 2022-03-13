USE hpi
GO

TRUNCATE TABLE hpi.PatientInformation
GO

BULK INSERT hpi.PatientInformation
FROM 'c:/code/dap/application_layer/healthcare_infoProtection/data/PatientInformation.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO