USE [DeepSeaKingdom]
GO
CREATE TABLE [dbo].[OnsiteTestLatitudeFirmware](
	[Id] [uniqueidentifier] PRIMARY KEY NOT NULL DEFAULT NEWSEQUENTIALID(), 
	[StartTerm] [varchar](4) NOT NULL,
	[ContentCode] [varchar](25) NULL,
	[ContentID] [varchar](25) NULL,
	[ContentName] [nvarchar](MAX) NULL,
	[Firmware] [nvarchar](MAX) NULL,
	[Latitude] [varchar](25) NULL,
	[House] [varchar](25) NULL,
	[FirmwareCount] int NULL,
	[Managed] [varchar](1) NOT NULL,
	[Valid] [varchar](1) NOT NULL,
	[Note] [nvarchar](MAX) NULL,
	[InsertedDate] [datetime] NULL DEFAULT GETDATE(),
	[UpdateDate] [datetime] NULL DEFAULT GETDATE()
)