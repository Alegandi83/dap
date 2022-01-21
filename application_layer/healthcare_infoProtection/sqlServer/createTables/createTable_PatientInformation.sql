USE [hpi]
GO

/****** Object:  Table [hpi].[PatientInformation]    Script Date: 20/01/2022 21:41:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hpi].[PatientInformation]') AND type in (N'U'))
DROP TABLE [hpi].[PatientInformation]
GO

/****** Object:  Table [hpi].[PatientInformation]    Script Date: 20/01/2022 21:41:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [hpi].[PatientInformation](
	[Patient Name] [nvarchar](4000) NULL,
	[Gender] [nvarchar](4000) NULL,
	[Phone] [nvarchar](4000) NULL,
	[Email] [nvarchar](4000) NULL,
	[Medical Insurance Card] [nvarchar](19) NULL
) ON [PRIMARY]
GO