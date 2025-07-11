USE [DBA]
GO
/****** Object:  Table [dbo].[SqlServerVersions]    Script Date: 7/8/2025 3:43:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SqlServerVersions](
	[MajorVersionNumber] [tinyint] NOT NULL,
	[MinorVersionNumber] [smallint] NOT NULL,
	[Branch] [varchar](34) NOT NULL,
	[Url] [varchar](99) NOT NULL,
	[ReleaseDate] [date] NOT NULL,
	[MainstreamSupportEndDate] [date] NOT NULL,
	[ExtendedSupportEndDate] [date] NOT NULL,
	[MajorVersionName] [varchar](19) NOT NULL,
	[MinorVersionName] [varchar](67) NOT NULL,
 CONSTRAINT [PK_SqlServerVersions] PRIMARY KEY CLUSTERED 
(
	[MajorVersionNumber] ASC,
	[MinorVersionNumber] ASC,
	[ReleaseDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The major version number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MajorVersionNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The minor version number.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MinorVersionNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The update level of the build. CU indicates a cumulative update. SP indicates a service pack. RTM indicates Release To Manufacturer. GDR indicates a General Distribution Release. QFE indicates Quick Fix Engineering (aka hotfix).' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'Branch'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'A link to the KB article for a version.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'Url'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The date the version was publicly released.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'ReleaseDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The date main stream Microsoft support ends for the version.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MainstreamSupportEndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The date extended Microsoft support ends for the version.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'ExtendedSupportEndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The major version name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MajorVersionName'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'The minor version name.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions', @level2type=N'COLUMN',@level2name=N'MinorVersionName'
GO
EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'A reference for SQL Server major and minor versions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SqlServerVersions'
GO
