USE [hpi]
GO

/****** Object:  Table [hpi].[RoleNew]    Script Date: 20/01/2022 21:45:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hpi].[RoleNew]') AND type in (N'U'))
DROP TABLE [hpi].[RoleNew]
GO

/****** Object:  Table [hpi].[RoleNew]    Script Date: 20/01/2022 21:45:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [hpi].[RoleNew](
	[RoleID] [nvarchar](4000) NULL,
	[Name] [nvarchar](4000) NULL,
	[Email] [nvarchar](4000) NULL,
	[Roles] [nvarchar](4000) NULL
) ON [PRIMARY]
GO

