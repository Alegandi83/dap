USE [hpi]
GO

/****** Object:  Table [hpi].[Campaign_Analytics]    Script Date: 20/01/2022 21:42:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hpi].[Campaign_Analytics]') AND type in (N'U'))
DROP TABLE [hpi].[Campaign_Analytics]
GO

/****** Object:  Table [hpi].[Campaign_Analytics]    Script Date: 20/01/2022 21:42:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [hpi].[Campaign_Analytics](
	[Region] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Campaign_Name] [varchar](50) NULL,
	[Revenue] [varchar](50) NULL,
	[Revenue_Target] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL
) ON [PRIMARY]
GO


