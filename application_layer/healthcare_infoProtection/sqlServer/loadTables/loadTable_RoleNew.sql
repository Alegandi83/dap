USE hpi
GO

TRUNCATE TABLE hpi.RoleNew
GO

BULK INSERT hpi.RoleNew
FROM 'C:\code\dap\application_layer\healthcare_infoProtection\data\RoleNew.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO