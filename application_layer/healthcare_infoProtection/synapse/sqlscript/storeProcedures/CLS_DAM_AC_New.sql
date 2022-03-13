SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [hpi].[CLS_DAM_AC_New] AS 

GRANT SELECT ON hpi.Campaign_Analytics([Region],[Country],[Campaign_Name],[Revenue_Target],[City],[State]) TO CareManagerMiami;
EXECUTE AS USER ='CareManagerMiami'

SELECT      [Region],
            [Country],
            [Campaign_Name],
            [Revenue_Target],
            [City],
            [State] 
FROM        hpi.Campaign_Analytics
GO