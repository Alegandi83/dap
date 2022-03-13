USE hpi
GO

TRUNCATE TABLE hpi.Campaign_Analytics
GO

BULK INSERT hpi.Campaign_Analytics
FROM '/my_dap_data/Campaign_Analytics.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',  --CSV field delimiter
    ROWTERMINATOR = '\n'   --Use to shift the control to next row
)
GO