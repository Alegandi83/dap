SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hpi].[Campaign_Analytics]
(
	[Region] [varchar](50) NULL,
	[Country] [varchar](50) NULL,
	[Campaign_Name] [varchar](50) NULL,
	[Revenue] [varchar](50) NULL,
	[Revenue_Target] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO