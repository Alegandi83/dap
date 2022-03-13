SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [hpi].[PatientInformation]
(
	[Patient Name] [nvarchar](4000) NULL,
	[Gender] [nvarchar](4000) NULL,
	[Phone] [nvarchar](4000) NULL,
	[Email] [nvarchar](4000) NULL,
	[Medical Insurance Card] [nvarchar](19) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO