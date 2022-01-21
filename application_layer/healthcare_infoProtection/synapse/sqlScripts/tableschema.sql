---------------------------------------------------------------------
-- Tables
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleNew]
(
	[RoleID] [nvarchar](4000) NULL,
	[Name] [nvarchar](4000) NULL,
	[Email] [nvarchar](4000) NULL,
	[Roles] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PatientInformation]
(
	[Patient Name] [nvarchar](4000) NULL,
	[Gender] [nvarchar](4000) NULL,
	[Phone] [nvarchar](4000) NULL,
	[Email] [nvarchar](4000) NULL,
	[Medical Insurance Card] [nvarchar](19) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Campaign_Analytics]
(
	[Region] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Campaign_Name] [varchar](50) NULL,
	[Revenue] [varchar](50) NULL,
	[Revenue_Target] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Campaign_Analytics_New]
(
	[Region] [nvarchar](4000) NULL,
	[Country] [nvarchar](4000) NULL,
	[Campaign_Name] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[Revenue_Target] [nvarchar](4000) NULL,
	[City] [nvarchar](4000) NULL,
	[State] [nvarchar](4000) NULL,
	[RoleID] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HealthCare-FactSales]
(
	[CareManager] [nvarchar](4000) NULL,
	[PayerName] [nvarchar](4000) NULL,
	[CampaignName] [nvarchar](4000) NULL,
	[Region] [nvarchar](4000) NULL,
	[State] [nvarchar](4000) NULL,
	[City] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[RevenueTarget] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Mkt_CampaignAnalyticLatest]
(
	[Region] [nvarchar](4000) NULL,
	[Country] [nvarchar](4000) NULL,
	[ProductCategory] [nvarchar](4000) NULL,
	[Campaign_ID] [nvarchar](4000) NULL,
	[Campaign_Name] [nvarchar](4000) NULL,
	[Qualification] [nvarchar](4000) NULL,
	[Qualification_Number] [nvarchar](4000) NULL,
	[Response_Status] [nvarchar](4000) NULL,
	[Responses] [nvarchar](4000) NULL,
	[Cost] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[ROI] [nvarchar](4000) NULL,
	[Lead_Generation] [nvarchar](4000) NULL,
	[Revenue_Target] [nvarchar](4000) NULL,
	[Campaign_Tactic] [nvarchar](4000) NULL,
	[Customer_Segment] [nvarchar](4000) NULL,
	[Status] [nvarchar](4000) NULL,
	[Profit] [nvarchar](4000) NULL,
	[Marketing_Cost] [nvarchar](4000) NULL,
	[CampaignID] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO
---------------------------------------------------------------------
-- Store Procedures
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CLS_DAM_AC_New] AS 
GRANT SELECT ON Campaign_Analytics([Region],[Country],[Campaign_Name],[Revenue_Target],[City],[State]) TO CareManagerMiami;
EXECUTE AS USER ='CareManagerMiami'
select [Region],[Country],[Campaign_Name],[Revenue_Target],[City],[State] from Campaign_Analytics
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CLS_DAM_F_New] AS 
BEGIN TRY
-- Generate a divide-by-zero error  
	
		GRANT SELECT ON Campaign_Analytics([Region],[Country],[Campaign_Name],[Revenue_Target],[CITY],[State]) TO CareManagerMiami;
		EXECUTE AS USER ='CareManagerMiami'
		select * from Campaign_Analytics
END TRY
BEGIN CATCH
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_STATE() AS ErrorState,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_PROCEDURE() AS ErrorProcedure,
		
		ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CLS_ChiefOperatingManager] AS 
Revert;
GRANT SELECT ON Campaign_Analytics TO ChiefOperatingManager;  --Full access to all columns.
-- Step:6 Let us check if our ChiefOperatingManager user can see all the information that is present. Assign Current User As 'CEO' and the execute the query
EXECUTE AS USER ='ChiefOperatingManager'
select * from Campaign_Analytics
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_RLS_CareManagerLosAngeles] AS
EXECUTE AS USER = 'CareManagerLosAngeles'; 
SELECT * FROM [HealthCare-FactSales];
revert;
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_RLS_CareManagerMiami] AS
EXECUTE AS USER = 'CareManagerMiami' 
SELECT * FROM [HealthCare-FactSales];
revert;
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_RLS_ChiefOperatingManager] AS
EXECUTE AS USER = 'ChiefOperatingManager';  
SELECT * FROM [HealthCare-FactSales];
revert;
GO
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Confirm DDM] AS 
SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function  
FROM sys.masked_columns AS c  
JOIN sys.tables AS tbl   ON c.[object_id] = tbl.[object_id]  WHERE is_masked = 1;
---------------------------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Sp_HealthCareRLS] AS 
Begin	
	-- After creating the users, read access is provided to all three users on FactSales table
	GRANT SELECT ON [HealthCare-FactSales] TO ChiefOperatingManager, CareManagerMiami, CareManagerLosAngeles;  

	IF EXISts (SELECT 1 FROM sys.security_predicates sp where sp.predicate_definition='([Security].[fn_securitypredicate]([SalesRep]))')
	BEGIN
		DROP SECURITY POLICY SalesFilter;
		DROP FUNCTION Security.fn_securitypredicate;
	END
	
	IF  EXISTS (SELECT * FROM sys.schemas where name='Security')
	BEGIN	
	DROP SCHEMA Security;
	End
	
	/* Moving ahead, we Create a new schema, and an inline table-valued function. 
	The function returns 1 when a row in the SalesRep column is the same as the user executing the query (@SalesRep = USER_NAME())
	or if the user executing the query is the Manager user (USER_NAME() = 'ChiefOperatingManager').
	*/
end
GO