/*	Row level Security (RLS) in Azure Synapse enables us to use group membership to control access to rows in a table.
	Azure Synapse applies the access restriction every time the data access is attempted from any user. 
	Let see how we can implement row level security in Azure Synapse.*/

----------------------------------Row-Level Security (RLS), 1: Filter predicates------------------------------------------------------------------
-- Step:1 The [HealthCare-FactSales] table has two Analyst values i.e. CareManagerMiami and CareManagerLosAngeles
SELECT      top 100 * 
FROM        hpi.[HealthCare-FactSales] 
ORDER BY    City ;

/* Moving ahead, we Create a new schema, and an inline table-valued function. 
The function returns 1 when a row in the Analyst column is the same as the user executing the query (@Analyst = USER_NAME())
 or if the user executing the query is the ChiefOperatingManager user (USER_NAME() = 'ChiefOperatingManager').
*/

--Step:2 To set up RLS, the following query creates three login users :  ChiefOperatingManager, CareManagerMiami, CareManagerLosAngeles
Exec hpi.Sp_HealthCareRLS
GO
CREATE SCHEMA Security
GO
CREATE FUNCTION Security.fn_securitypredicate(@Analyst AS sysname)  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN  SELECT      1 AS fn_securitypredicate_result
            WHERE       @Analyst = USER_NAME() 
                OR      USER_NAME() = 'ChiefOperatingManager'
GO
-- Now we define security policy that allows users to filter rows based on thier login name.
CREATE SECURITY POLICY SalesFilter  
ADD FILTER PREDICATE Security.fn_securitypredicate(CareManager)
ON hpi.[HealthCare-FactSales]
WITH (STATE = ON);
------ Allow SELECT permissions to the fn_securitypredicate function.------
GRANT SELECT ON security.fn_securitypredicate TO ChiefOperatingManager, CareManagerMiami, CareManagerLosAngeles;


-- Step:3 Let us now test the filtering predicate, by selecting data from the [HealthCare-FactSales] table as 'CareManagerMiami' user.
EXECUTE AS USER = 'CareManagerMiami'; 
SELECT      * 
FROM        hpi.[HealthCare-FactSales];
revert;
-- As we can see, the query has returned rows here Login name is CareManagerMiami

-- Step:4 Let us test the same for  'CareManagerLosAngeles' user.
EXECUTE AS USER = 'CareManagerLosAngeles'; 
SELECT      * 
FROM        hpi.[HealthCare-FactSales];
revert;
-- RLS is working indeed.

-- Step:5 The ChiefOperatingManager should be able to see all rows in the table.
EXECUTE AS USER = 'ChiefOperatingManager';  
SELECT      * 
FROM        hpi.[HealthCare-FactSales];
revert;
-- And he can.

--Step:6 To disable the security policy we just created above, we execute the following.
ALTER SECURITY POLICY SalesFilter  
WITH (STATE = OFF);

DROP SECURITY POLICY SalesFilter;
DROP FUNCTION Security.fn_securitypredicate;
DROP SCHEMA Security;