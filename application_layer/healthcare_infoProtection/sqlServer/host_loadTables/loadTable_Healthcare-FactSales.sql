USE hpi
GO

TRUNCATE TABLE hpi.[Healthcare-FactSales]
GO

BULK INSERT hpi.[Healthcare-FactSales]
FROM 'c:/code/dap/application_layer/healthcare_infoProtection/data/Healthcare-FactSales.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO