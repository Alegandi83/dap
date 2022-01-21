USE [hpi]
GO

/****** Object:  Table [hpi].[HospitalEmpPIIData]    Script Date: 20/01/2022 21:45:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hpi].[HospitalEmpPIIData]') AND type in (N'U'))
DROP TABLE [hpi].[HospitalEmpPIIData]
GO

/****** Object:  Table [hpi].[HospitalEmpPIIData]    Script Date: 20/01/2022 21:45:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [hpi].[HospitalEmpPIIData](
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
) ON [PRIMARY]
GO

