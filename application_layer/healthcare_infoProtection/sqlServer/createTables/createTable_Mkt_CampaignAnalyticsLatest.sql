USE [hpi]
GO

/****** Object:  Table [hpi].[Mkt_CampaignAnalyticLatest]    Script Date: 20/01/2022 21:45:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hpi].[Mkt_CampaignAnalyticLatest]') AND type in (N'U'))
DROP TABLE [hpi].[Mkt_CampaignAnalyticLatest]
GO

/****** Object:  Table [hpi].[Mkt_CampaignAnalyticLatest]    Script Date: 20/01/2022 21:45:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [hpi].[Mkt_CampaignAnalyticLatest](
	[Region] [nvarchar](4000) NULL,
	[Country] [nvarchar](4000) NULL,
	[ProductCategory] [nvarchar](4000) NULL,
	[Campaign_ID] [nvarchar](4000) NULL,
	[Campaign_Name] [nvarchar](4000) NULL,
	[Qualification] [nvarchar](4000) NULL,
	[Qualification_Number] [nvarchar](4000) NULL,
	[Response_Status] [nvarchar](4000) NULL,
	[Responses] [nvarchar](4000) NULL,
	[Cost] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[ROI] [nvarchar](4000) NULL,
	[Lead_Generation] [nvarchar](4000) NULL,
	[Revenue_Target] [nvarchar](4000) NULL,
	[Campaign_Tactic] [nvarchar](4000) NULL,
	[Customer_Segment] [nvarchar](4000) NULL,
	[Status] [nvarchar](4000) NULL,
	[Profit] [nvarchar](4000) NULL,
	[Marketing_Cost] [nvarchar](4000) NULL,
	[CampaignID] [nvarchar](4000) NULL
) ON [PRIMARY]
GO

