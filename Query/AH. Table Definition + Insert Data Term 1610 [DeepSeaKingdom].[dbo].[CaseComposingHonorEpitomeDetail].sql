USE [DeepSeaKingdom]
GO
/*CREATE TABLE [dbo].[CaseComposingHonorEpitomeDetail](
	Id uniqueidentifier PRIMARY KEY NOT NULL,  
	Term nvarchar(5) NULL,
	Personname nvarchar(25) NULL,
	WorkshopName nvarchar(50) NULL,
	ContentName nvarchar(255) NULL,
	LimitStatus nvarchar(25) NULL,
	Appendix nvarchar(25) NULL,
	CaseType nvarchar(50) NULL,
	Variation int NULL,
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
--DELETE FROM [dbo].[CaseComposingHonorEpitomeDetail] WHERE Term = @Term
;------------------------------
--INSERT INTO [dbo].[CaseComposingHonorEpitomeDetail]
SELECT NEWID(), @term, cmhrd.CaseComposer, @WorkshopName, cmhrd.ContentName, cmhrd.LimitStatus,'N', cmhrd.Type, cmhrd.Variation, NULL, @QuarterSessionId
FROM DeepSeaKingdom.WE.CaseComposingHonorEpitomeDetail cmhrd
;------------------------------
--INSERT INTO [DeepSeaKingdom].[dbo].[CaseComposingHonorEpitomeDetail] ([Id],[Term],[Personname],[WorkshopName],[ContentName],[LimitStatus],[Appendix],[CaseType],[Variation],[Note],[QuarterSessionId]) VALUES (NEWID(), @Term, 'SG15-1', @WorkshopName, 'COMP6140-Data Mining', NULL, 'Y', 'FinalTerm', '1', NULL, @QuarterSessionId), (NEWID(), @Term, 'DF11-2', @WorkshopName, 'COMP6119-Database Administration', NULL, 'Y', 'FinalTerm', '1', NULL, @QuarterSessionId)
