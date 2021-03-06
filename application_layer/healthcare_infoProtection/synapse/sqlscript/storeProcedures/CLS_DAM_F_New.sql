SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [hpi].[CLS_DAM_F_New] AS 
BEGIN TRY
-- Generate a divide-by-zero error  
	
		GRANT SELECT ON hpi.Campaign_Analytics([Region],[Country],[Campaign_Name],[Revenue_Target],[CITY],[State]) TO CareManagerMiami;
		EXECUTE AS USER ='CareManagerMiami'
		
		SELECT		* 
		FROM 		hpi.Campaign_Analytics

END TRY
BEGIN CATCH

	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_STATE() AS ErrorState,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_PROCEDURE() AS ErrorProcedure,		
		ERROR_MESSAGE() AS ErrorMessage;

END CATCH;
GO