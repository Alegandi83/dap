USE hpi
GO

TRUNCATE TABLE hpi.Campaign_Analytics_New
GO

BULK INSERT hpi.Campaign_Analytics_New
FROM '/my_dap_data/Campaign_Analytics_New.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',  --CSV field delimiter
    ROWTERMINATOR = '\r\n'   --Use to shift the control to next row
)
GO