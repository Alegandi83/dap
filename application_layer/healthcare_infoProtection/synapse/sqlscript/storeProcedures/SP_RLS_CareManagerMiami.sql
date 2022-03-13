SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [hpi].[SP_RLS_CareManagerMiami] AS

EXECUTE AS USER = 'CareManagerMiami' 

SELECT      * 
FROM        hpi.[HealthCare-FactSales];

revert;
GO