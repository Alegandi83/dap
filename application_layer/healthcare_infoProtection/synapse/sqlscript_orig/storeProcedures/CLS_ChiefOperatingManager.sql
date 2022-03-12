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