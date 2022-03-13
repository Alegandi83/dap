SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hpi].[Campaign_Analytics_New]
(
	[Region] [nvarchar](4000) NULL,
	[Country] [nvarchar](4000) NULL,
	[Campaign_Name] [nvarchar](4000) NULL,
	[Revenue] [nvarchar](4000) NULL,
	[Revenue_Target] [nvarchar](4000) NULL,
	[City] [nvarchar](4000) NULL,
	[State] [nvarchar](4000) NULL,
	[RoleID] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO