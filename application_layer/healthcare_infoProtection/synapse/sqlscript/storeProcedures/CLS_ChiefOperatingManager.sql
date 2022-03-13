SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [hpi].[CLS_ChiefOperatingManager] AS 
Revert;
--Full access to all columns.
GRANT SELECT ON hpi.Campaign_Analytics TO ChiefOperatingManager;  
-- Step:6 Let us check if our ChiefOperatingManager user can see all the information.
-- Assign Current User As 'CEO' and the execute the query
EXECUTE AS USER ='ChiefOperatingManager'
SELECT      * 
FROM        hpi.Campaign_Analytics
GO