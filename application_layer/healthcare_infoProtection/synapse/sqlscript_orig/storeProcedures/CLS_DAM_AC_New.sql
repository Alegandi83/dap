SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CLS_DAM_AC_New] AS 
GRANT SELECT ON Campaign_Analytics([Region],[Country],[Campaign_Name],[Revenue_Target],[City],[State]) TO CareManagerMiami;
EXECUTE AS USER ='CareManagerMiami'
select [Region],[Country],[Campaign_Name],[Revenue_Target],[City],[State] from Campaign_Analytics
GO