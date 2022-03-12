CREATE USER [<purview_name>] FROM EXTERNAL PROVIDER
GO

EXEC sp_addrolemember 'db_datareader', [<purview_name>]
GO