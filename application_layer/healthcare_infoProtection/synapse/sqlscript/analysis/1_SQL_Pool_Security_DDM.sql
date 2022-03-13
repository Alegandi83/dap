-- Step:1(View the existing table 'PatientInformation' Data) 
select      top 100 * 
from        hpi.PatientInformation

-- Step:2 Let's confirm that there are no Dynamic Data Masking (DDM) applied on columns
Exec hpi.[Confirm_DDM]
-- No results returned verify that no data masking has been done yet.

-- Step:3 Now lets mask 'Medical Insurance Card' and 'Email' Column of 'PatientInformation' table.
ALTER TABLE hpi.PatientInformation  
ALTER COLUMN [Medical Insurance Card] ADD MASKED WITH (FUNCTION = 'partial(0,"XXX-XXX-XXXX-",4)')
GO
ALTER TABLE hpi.PatientInformation 
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()')
GO
-- The columns are sucessfully masked.

-- Step:4 Let's see Dynamic Data Masking (DDM) applied on the two columns.
Exec hpi.[Confirm_DDM]

-- Step:5 Now, let us grant SELECT permission to 'CareManager'sysusers on the 'PatientInformation' table.
SELECT      Name as [User] 
FROM        sys.sysusers 
WHERE       name = N'CareManager'

GRANT SELECT ON hpi.PatientInformation TO CareManager;  

-- Step:6 Logged in as  'CareManager' let us execute the select query and view the result.
EXECUTE AS USER =N'CareManager';  
SELECT      * 
FROM        hpi.PatientInformation; 

-- Step:7 Let us Remove the data masking using UNMASK permission
GRANT UNMASK TO CareManager
EXECUTE AS USER = 'CareManager';  
SELECT      top 10 * 
FROM        hpi.PatientInformation; 
revert; 
REVOKE UNMASK TO CareManager;  

----step:8 Reverting all the changes back to as it was.
ALTER TABLE hpi.PatientInformation
ALTER COLUMN [Medical Insurance Card] DROP MASKED;
GO
ALTER TABLE hpi.PatientInformation
ALTER COLUMN Email DROP MASKED;
GO