-- USE master
CREATE LOGIN [BillingStaff] WITH PASSWORD = 'Sqluserpswag83'
CREATE LOGIN [ChiefOperatingManager] WITH PASSWORD = 'Sqluserpswag83'
CREATE LOGIN [CareManagerMiami] WITH PASSWORD = 'Sqluserpswag83'
CREATE LOGIN [CareManagerLosAngeles] WITH PASSWORD = 'Sqluserpswag83'
CREATE LOGIN [CareManager] WITH PASSWORD = 'Sqluserpswag83'
GO

-- USE syndpag83datadev
CREATE USER [BillingStaff] FOR LOGIN [BillingStaff] WITH DEFAULT_SCHEMA=[dbo];
CREATE USER [ChiefOperatingManager] FOR LOGIN [ChiefOperatingManager] WITH DEFAULT_SCHEMA=[dbo];
CREATE USER [CareManagerMiami] FOR LOGIN [CareManagerMiami] WITH DEFAULT_SCHEMA=[dbo];
CREATE USER [CareManagerLosAngeles] FOR LOGIN [CareManagerLosAngeles] WITH DEFAULT_SCHEMA=[dbo];   
CREATE USER [CareManager] FOR LOGIN [CareManager] WITH DEFAULT_SCHEMA=[dbo];
GO   



