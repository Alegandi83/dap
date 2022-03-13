SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [hpi].[SP_RLS_CareManagerLosAngeles] AS

EXECUTE AS USER = 'CareManagerLosAngeles'; 

SELECT      * 
FROM        hpi.[HealthCare-FactSales];

revert;
GO