--Uncomment the 4 lines below to create a stored procedure for data pipeline orchestration​
--CREATE PROC bulk_load_PatientInformation
--AS
--BEGIN
COPY INTO dbo.PatientInformation
("Patient Name" 1, Gender 2, Phone 3, Email 4, "Medical Insurance Card" 5)
FROM 'https://dlscsag83datadev.dfs.core.windows.net/healthcare-info-protection/PatientInformation'
WITH
(
	FILE_TYPE = 'CSV'
	,MAXERRORS = 0
	,FIELDTERMINATOR = ';'
	,FIRSTROW = 2
	,ERRORFILE = 'https://dlscsag83datadev.dfs.core.windows.net/healthcare-info-protection/'
)
--END
GO

SELECT TOP 100 * FROM dbo.PatientInformation
GO