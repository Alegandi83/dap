SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_RLS_ChiefOperatingManager] AS
EXECUTE AS USER = 'ChiefOperatingManager';  
SELECT * FROM [HealthCare-FactSales];
revert;
GO