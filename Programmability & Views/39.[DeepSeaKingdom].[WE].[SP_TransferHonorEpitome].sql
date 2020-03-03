USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_TransferHonorEpitome](
	@Term NVARCHAR(MAX) = N''
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
SELECT @WorkshopId = Workshops.WorkshopId FROM [LocalDB].Galaxy.dbo.Workshops WHERE Workshops.Name LIKE '%'+@WorkshopName+'%'
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
IF @WorkshopId IS NULL SET @WorkshopName = NULL
;----------------------------------------------------------------------
DELETE FROM [dbo].[VentureHonorEpitomeDetail] WHERE Term = @Term
;------------------------------
INSERT INTO [dbo].[VentureHonorEpitomeDetail]
SELECT NEWID(), @term, chrd.Corrector, @WorkshopName, chrd.ContentName, chrd.BrandName, chrd.LimitStatus, chrd.PaidStatus, 'N', chrd.Type, chrd.Number, chrd.Weight, chrd.HasFileProcessed, NULL, @QuarterSessionId
FROM DeepSeaKingdom.WE.VentureHonorEpitomeDetail chrd
UNION
SELECT NEWID(), @term, chard.Corrector, @WorkshopName, chard.ContentName, chard.BrandName, NULL, 'Paid', 'Y', chard.Type, chard.Number, chard.Weight, chard.HasFileProcessed, NULL, @QuarterSessionId
FROM DeepSeaKingdom.WE.VentureHonorAppendixEpitomeDetail chard
;------------------------------
DELETE FROM [dbo].[CaseComposingHonorEpitomeDetail] WHERE Term = @Term
;------------------------------
INSERT INTO [dbo].[CaseComposingHonorEpitomeDetail]
SELECT NEWID(), @term, cmhrd.CaseComposer, @WorkshopName, cmhrd.ContentName, cmhrd.LimitStatus,'N', cmhrd.Type, cmhrd.Variation, NULL, @QuarterSessionId
FROM DeepSeaKingdom.WE.CaseComposingHonorEpitomeDetail cmhrd
;------------------------------
DELETE FROM [dbo].[HonorEpitomeSummary] WHERE Term = @Term
;------------------------------
INSERT INTO [dbo].[HonorEpitomeSummary]
SELECT NEWID(), @term, chrs.Corrector, @WorkshopName, 'Venture', chrs.Totalpaid, chrs.Responsibility, chrs.FinalTerm, NULL, chrs.Venture, chrs.[Responsibility Appendix], chrs.[FinalTerm Appendix], NULL, chrs.[Venture Appendix], NULL, @QuarterSessionId
FROM DeepSeaKingdom.WE.VentureHonorEpitomeSummary chrs
UNION
SELECT NEWID(), @term, cmhrs.CaseComposer, @WorkshopName, 'CaseCompose', cmhrs.Total, cmhrs.Responsibility, cmhrs.FinalTerm, NULL, cmhrs.Venture, 0, 0, NULL, 0, NULL, @QuarterSessionId
FROM DeepSeaKingdom.WE.CaseComposingHonorEpitomeSummary cmhrs
;------------------------------
--UPDATE [dbo].[HonorEpitomeSummary] SET [TotalPaid] = IIF(CEILING (ISNULL(CONVERT(FLOAT,[ResponsibilityReguler]),0) + ISNULL(CONVERT(FLOAT,[FinalTermReguler]),0) + ISNULL(CONVERT(FLOAT,[MidTermReguler]),0) + ISNULL(CONVERT(FLOAT,[VentureReguler]),0) + ISNULL(CONVERT(FLOAT,[ResponsibilityAppendix]),0) + ISNULL(CONVERT(FLOAT,[FinalTermAppendix]),0) + ISNULL(CONVERT(FLOAT,[MidTermAppendix]),0) + ISNULL(CONVERT(FLOAT,[VentureAppendix]),0))<0,0,CEILING (ISNULL(CONVERT(FLOAT,[ResponsibilityReguler]),0) + ISNULL(CONVERT(FLOAT,[FinalTermReguler]),0) + ISNULL(CONVERT(FLOAT,[MidTermReguler]),0) + ISNULL(CONVERT(FLOAT,[VentureReguler]),0) + ISNULL(CONVERT(FLOAT,[ResponsibilityAppendix]),0) + ISNULL(CONVERT(FLOAT,[FinalTermAppendix]),0) + ISNULL(CONVERT(FLOAT,[MidTermAppendix]),0) + ISNULL(CONVERT(FLOAT,[VentureAppendix]),0)))
;----------------------------------------------------------------------
END