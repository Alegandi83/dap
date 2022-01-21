USE [hpi]
GO

/****** Object:  Table [hpi].[Campaign_Analytics_New]    Script Date: 20/01/2022 21:42:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hpi].[Campaign_Analytics_New]') AND type in (N'U'))
DROP TABLE [hpi].[Campaign_Analytics_New]
GO

/****** Object:  Table [hpi].[Campaign_Analytics_New]    Script Date: 20/01/2022 21:42:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [hpi].[Campaign_Analytics_New](
	[Region] [nvarchar](4000) NULL,
	[Country] [nvarchar](4000) NULL,
	[Campaign_Name] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[Revenue_Target] [nvarchar](4000) NULL,
	[City] [nvarchar](4000) NULL,
	[State] [nvarchar](4000) NULL,
	[RoleID] [nvarchar](4000) NULL
) ON [PRIMARY]
GO

