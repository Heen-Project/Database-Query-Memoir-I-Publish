USE [DeepSeaKingdom]
GO
CREATE TABLE [dbo].[History_LAM_Brand_ACTV](
	[Id] [uniqueidentifier] PRIMARY KEY NOT NULL DEFAULT NEWSEQUENTIALID(),  
	[Term] [varchar](4) NOT NULL,
	[Brand_NBR] [numeric](5, 0) NOT NULL,
	[Orderline] [numeric](3, 0) NOT NULL,
	[TYPE] [varchar](10) NULL,
	[DESCR] [varchar](30) NULL,
	[DESCRSHORT] [varchar](10) NULL,
	[Content_ID] [varchar](6) NOT NULL,
	[SUBMIT_DT] [datetime] NULL,
	[APPROVE_DATE] [datetime] NULL,
	[POST_DT] [datetime] NULL,
	[ASCID] [varchar](11) NOT NULL,
	[Brand_OnsiteTest_TYPE] [varchar](4) NULL,
	[DESCRLONG_NOTES] [varchar](max) NULL,
	[InsertedDate] [datetime] NOT NULL DEFAULT GETDATE(),
	[TableDestination] [nvarchar](max) NOT NULL,
	[Note] [nvarchar](max) NULL,
	[U__SUBMIT_DT] [datetime] NULL,
	[U__APPROVE_DATE] [datetime] NULL,
	[U__POST_DT] [datetime] NULL,
	[U__ASCID] [varchar](11) NULL
)