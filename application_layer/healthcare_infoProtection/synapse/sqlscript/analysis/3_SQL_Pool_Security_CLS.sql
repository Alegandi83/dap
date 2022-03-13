/*  Column-level security feature in Azure Synapse simplifies the design and coding of security in application. 
    It ensures column level security by restricting column access to protect sensitive data. */

--Step 1: Let us see how this feature in Azure Synapse works. Before that let us have a look at the Mkt_CampaignAnalyticLatest table. 
SELECT      TOP 100 * 
FROM        hpi.Mkt_CampaignAnalyticLatest

/*  Consider a scenario where there are two users. 
    A ChiefOperatingManager, who is an authorized  personnel with access to all the information in the database 
    and a CareManager, to whom only required information should be presented.*/

-- Step:2 We look for the names “ChiefOperatingManager” and “CareManagerMiami” present in the Datawarehouse. 
SELECT      Name as [User] 
FROM        sys.sysusers 
WHERE       name IN (N'ChiefOperatingManager',N'CareManagerMiami')

-- Step:3 Now let us enforcing column level security for the CareManagerMiami. 
/*  Let us see how.
    The Mkt_CampaignAnalyticLatest table in the warehouse has information like Region, Country,Campaign_Name, Revenue_Target , and Revenue.
    Of all the information, Revenue generated from every Mkt_CampaignAnalyticLatest is a classified one and should be hidden from CareManagerMiami.
    To conceal this information, we execute the following query: */

GRANT SELECT ON hpi.Mkt_CampaignAnalyticLatest ([Region],[Country],[Campaign_Name],[Revenue_Target]) TO CareManagerMiami;
-- This provides CareManagerMiami access to all the columns of the Mkt_CampaignAnalyticLatest table but Revenue.
-- Step:4 Then, to check if the security has been enforced, we execute the following query with current User As 'CareManagerMiami'
EXECUTE AS USER ='CareManagerMiami'
SELECT      * 
FROM        hpi.Mkt_CampaignAnalyticLatest
---
EXECUTE AS USER ='CareManagerMiami'
SELECT      [Region],
            [Country],
            [Campaign_Name],
            [Revenue_Target] 
FROM        hpi.Mkt_CampaignAnalyticLatest

/*  And look at that, when the user logged in as CareManagerMiami tries to view all the columns from the Mkt_CampaignAnalyticLatest table, 
    he is prompted with a ‘permission denied error’ on Revenue column.*/

-- Step:5 Whereas, the ChiefOperatingManager of the company should be authorized with all the information present in the warehouse.To do so, we execute the following query.
Revert;
GRANT SELECT ON hpi.Mkt_CampaignAnalyticLatest TO ChiefOperatingManager;  --Full access to all columns.

-- Step:6 Let us check if our ChiefOperatingManager user can see all the information that is present. Assign Current User As 'ChiefOperatingManager' and the execute the query
EXECUTE AS USER ='ChiefOperatingManager'
SELECT      *
FROM        hpi.Mkt_CampaignAnalyticLatest

-------------------------------------------------------------
Revert;