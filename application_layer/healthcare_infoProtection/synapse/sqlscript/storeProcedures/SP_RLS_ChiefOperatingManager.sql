SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [hpi].[SP_RLS_ChiefOperatingManager] AS

EXECUTE AS USER = 'ChiefOperatingManager';  

SELECT      * 
FROM        hpi.[HealthCare-FactSales];

revert;
GO