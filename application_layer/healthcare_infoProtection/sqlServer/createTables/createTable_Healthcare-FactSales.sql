USE [hpi]
GO

/****** Object:  Table [hpi].[HealthCare-FactSales]    Script Date: 20/01/2022 21:42:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hpi].[HealthCare-FactSales]') AND type in (N'U'))
DROP TABLE [hpi].[HealthCare-FactSales]
GO

/****** Object:  Table [hpi].[HealthCare-FactSales]    Script Date: 20/01/2022 21:42:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [hpi].[HealthCare-FactSales](
	[CareManager] [nvarchar](4000) NULL,
	[PayerName] [nvarchar](4000) NULL,
	[CampaignName] [nvarchar](4000) NULL,
	[Region] [nvarchar](4000) NULL,
	[State] [nvarchar](4000) NULL,
	[City] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[RevenueTarget] [nvarchar](4000) NULL
) ON [PRIMARY]
GO

