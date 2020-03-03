USE [DeepSeaKingdom]
GO
/*CREATE TABLE [dbo].[VentureHonorEpitomeDetail](
	Id uniqueidentifier PRIMARY KEY NOT NULL,  
	Term nvarchar(5) NULL,
	Personname nvarchar(25) NULL,
	WorkshopName nvarchar(50) NULL,
	ContentName nvarchar(255) NULL,
	BrandName nvarchar(25) NULL,
	LimitStatus nvarchar(25) NULL,
	PaidStatus nvarchar(25) NULL,
	Appendix nvarchar(25) NULL,
	GalaxyIngredient nvarchar(50) NULL,
	GalaxyNumber int NULL,
	HonorWeight nvarchar(5) NULL,
	FileProcessed nvarchar(25) NULL,
	Note nvarchar(max),
	QuarterSessionId uniqueidentifier NULL,
)*/
;----------------------------------------------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1610'
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------
SELECT @WorkshopId = Workshops.WorkshopId FROM [LocalDB].Galaxy.dbo.Workshops WHERE Workshops.Name LIKE '%'+@WorkshopName+'%'
;------------------------------
--DELETE FROM [dbo].[VentureHonorEpitomeDetail] WHERE Term = @Term
;------------------------------
--INSERT INTO [dbo].[VentureHonorEpitomeDetail]
SELECT NEWID(), @term, chrd.Corrector, @WorkshopName, chrd.ContentName, chrd.BrandName, chrd.LimitStatus, chrd.PaidStatus, 'N', chrd.Type, chrd.Number, chrd.Weight, chrd.HasFileProcessed, NULL, @QuarterSessionId
FROM DeepSeaKingdom.WE.VentureHonorEpitomeDetail chrd
UNION
SELECT NEWID(), @term, chard.Corrector, @WorkshopName, chard.ContentName, chard.BrandName, NULL, 'Paid', 'Y', chard.Type, chard.Number, chard.Weight, chard.HasFileProcessed, NULL, @QuarterSessionId
FROM DeepSeaKingdom.WE.VentureHonorAppendixEpitomeDetail chard