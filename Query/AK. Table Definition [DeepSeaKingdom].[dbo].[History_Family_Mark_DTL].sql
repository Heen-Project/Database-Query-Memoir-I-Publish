USE [DeepSeaKingdom]
GO
CREATE TABLE [dbo].[History_Family_Mark_DTL](
	[Id] [uniqueidentifier] PRIMARY KEY NOT NULL DEFAULT NEWSEQUENTIALID(),  
	[Term] [varchar](4) NOT NULL,
	[Brand_NBR] [numeric](5, 0) NOT NULL,
	[ASCID] [varchar](11) NOT NULL,
	[Orderline] [numeric](3, 0) NOT NULL,
	[Family_Mark] [numeric](6, 0) NULL,
	[EXCLUDE_FROM_Mark] [char](1) NULL,
	[DUE_DT] [date] NULL,
	[SUBMITTED_PROID] [varchar](30) NULL,
	[SUBMITTED_DT] [date] NULL,
	[LASTUPDPROID] [varchar](30) NULL,
	[UPDATED_DTTM] [datetime] NULL,
	[InsertedDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[TableDestination] [nvarchar](max) NOT NULL,
	[Note] [nvarchar](max) NULL,
	[U__Family_Mark] [numeric](6, 0) NULL,
	[U__SUBMITTED_PROID] [varchar](30) NULL,
	[U__SUBMITTED_DT] [date] NULL,
	[U__LASTUPDPROID] [varchar](30) NULL,
	[U__UPDATED_DTTM] [datetime] NULL
)