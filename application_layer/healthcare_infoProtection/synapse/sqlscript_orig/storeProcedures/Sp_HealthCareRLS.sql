SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Sp_HealthCareRLS] AS 
Begin	
	-- After creating the users, read access is provided to all three users on FactSales table
	GRANT SELECT ON [HealthCare-FactSales] TO ChiefOperatingManager, CareManagerMiami, CareManagerLosAngeles;  

	IF EXISts (SELECT 1 FROM sys.security_predicates sp where sp.predicate_definition='([Security].[fn_securitypredicate]([SalesRep]))')
	BEGIN
		DROP SECURITY POLICY SalesFilter;
		DROP FUNCTION Security.fn_securitypredicate;
	END
	
	IF  EXISTS (SELECT * FROM sys.schemas where name='Security')
	BEGIN	
	DROP SCHEMA Security;
	End
	
	/* Moving ahead, we Create a new schema, and an inline table-valued function. 
	The function returns 1 when a row in the SalesRep column is the same as the user executing the query (@SalesRep = USER_NAME())
	or if the user executing the query is the Manager user (USER_NAME() = 'ChiefOperatingManager').
	*/
end
GO