SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_RLS_CareManagerLosAngeles] AS
EXECUTE AS USER = 'CareManagerLosAngeles'; 
SELECT * FROM [HealthCare-FactSales];
revert;
GO