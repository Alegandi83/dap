SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HospitalEmpPIIData]
(
	[Id] [int] NULL,
	[EmpName] [nvarchar](61) NULL,
	[Address] [nvarchar](30) NULL,
	[City] [nvarchar](30) NULL,
	[County] [nvarchar](30) NULL,
	[State] [nvarchar](10) NULL,
	[Phone] [varchar](100) NULL,
	[Email] [varchar](100) NULL,
	[Designation] [varchar](20) NULL,
	[SSN] [varchar](100) NULL,
	[SSN_encrypted] [nvarchar](100) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO