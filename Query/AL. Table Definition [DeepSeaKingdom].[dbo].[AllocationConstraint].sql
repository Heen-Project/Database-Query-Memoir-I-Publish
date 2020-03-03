USE [DeepSeaKingdom]
GO
CREATE TABLE [dbo].[OnsiteTestAllocationConstraint](
	[Id] [uniqueidentifier] PRIMARY KEY NOT NULL DEFAULT NEWSEQUENTIALID(), 
	[StartTerm] [varchar](4) NOT NULL,
	[Description] [nvarchar](MAX) NULL,
	[Day] [varchar](1) NULL,
	[DateStart] [date] NOT NULL,
	[DateEnd] [date] NOT NULL,
	[Shift] [varchar](1) NOT NULL,
	[Latitude] [varchar](25) NULL,
	[NumberOfLatitude] [int] NULL,
	[Location] [varchar](25) NULL,
	[House] [varchar](25) NULL,
	[LatitudeMasterId] [uniqueidentifier] NULL, 
	[Valid] [varchar](1) NOT NULL,
	[Note] [nvarchar](MAX) NULL,
	[InsertedDate] [datetime] NULL DEFAULT GETDATE(),
	[UpdatedDate] [datetime] NULL DEFAULT GETDATE()
)