--Uncomment the 4 lines below to create a stored procedure for data pipeline orchestration​
--CREATE PROC bulk_load_HospitalEmpPIIData
--AS
--BEGIN
COPY INTO dbo.HospitalEmpPIIData
(Id 1, EmpName 2, Address 3, City 4, County 5, State 6, Phone 7, Email 8, Designation 9, SSN 10, SSN_encrypted 11)
FROM 'https://dlscsag83datadev.dfs.core.windows.net/healthcare-info-protection/HostpitalEmpPIIData'
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

SELECT TOP 100 * FROM dbo.HospitalEmpPIIData
GO