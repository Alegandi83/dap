SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HealthCare-FactSales]
(
	[CareManager] [nvarchar](4000) NULL,
	[PayerName] [nvarchar](4000) NULL,
	[CampaignName] [nvarchar](4000) NULL,
	[Region] [nvarchar](4000) NULL,
	[State] [nvarchar](4000) NULL,
	[City] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[RevenueTarget] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO