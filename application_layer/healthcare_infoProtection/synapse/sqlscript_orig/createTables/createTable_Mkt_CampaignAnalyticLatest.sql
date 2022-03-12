SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Mkt_CampaignAnalyticLatest]
(
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
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO