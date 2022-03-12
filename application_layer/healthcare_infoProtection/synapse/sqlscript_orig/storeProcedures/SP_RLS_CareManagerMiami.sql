SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_RLS_CareManagerMiami] AS
EXECUTE AS USER = 'CareManagerMiami' 
SELECT * FROM [HealthCare-FactSales];
revert;
GO