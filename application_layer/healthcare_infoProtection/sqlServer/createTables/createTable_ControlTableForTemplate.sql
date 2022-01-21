USE [hpi]
GO

/****** Object:  Table [hpi].[ControlTableForTemplate]    Script Date: 21/01/2022 00:38:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ControlTableForTemplate]') AND type in (N'U'))
DROP TABLE [hpi].[ControlTableForTemplate]
GO

/****** Object:  Table [hpi].[ControlTableForTemplate]    Script Date: 21/01/2022 00:38:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [hpi].[ControlTableForTemplate](
	[PartitionID] [int] NULL,
	[SourceTableSchema] [varchar](255) NULL,
	[SourceTableName] [varchar](255) NULL,
	[FilterQuery] [varchar](255) NULL
) ON [PRIMARY]
GO


