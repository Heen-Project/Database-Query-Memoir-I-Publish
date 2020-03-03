USE [DeepSeaKingdom]
GO
/*CREATE TABLE [dbo].[HonorEpitomeSummary](
	Id uniqueidentifier PRIMARY KEY NOT NULL,  
	Term nvarchar(5) NULL,
	Personname nvarchar(25) NULL,
	WorkshopName nvarchar(50) NULL,
	HonorType nvarchar(50) NULL,
	TotalPaid nvarchar(25) NULL,
	ResponsibilityReguler nvarchar(10) NULL,
	FinalTermReguler nvarchar(10) NULL,
	MidTermReguler nvarchar(10) NULL,
	VentureReguler nvarchar(10) NULL,
	ResponsibilityAppendix nvarchar(10) NULL,
	FinalTermAppendix nvarchar(10) NULL,
	MidTermAppendix nvarchar(10) NULL,
	VentureAppendix nvarchar(10) NULL,
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
--DELETE FROM [dbo].[HonorEpitomeSummary] WHERE Term = @Term
;------------------------------
--INSERT INTO [dbo].[HonorEpitomeSummary]
SELECT NEWID(), @term, chrs.Corrector, @WorkshopName, 'Venture', chrs.Totalpaid, chrs.Responsibility, chrs.FinalTerm, NULL, chrs.Venture, chrs.[Responsibility Appendix], chrs.[FinalTerm Appendix], NULL, chrs.[Venture Appendix], NULL, @QuarterSessionId
FROM DeepSeaKingdom.WE.VentureHonorEpitomeSummary chrs
UNION
SELECT NEWID(), @term, cmhrs.CaseComposer, @WorkshopName, 'CaseCompose', cmhrs.Total, cmhrs.Responsibility, cmhrs.FinalTerm, NULL, cmhrs.Venture, 0, 0, NULL, 0, NULL, @QuarterSessionId
FROM DeepSeaKingdom.WE.CaseComposingHonorEpitomeSummary cmhrs

--INSERT INTO [dbo].[HonorEpitomeSummary] ([Id],[Term],[Personname],[WorkshopName],[HonorType],[TotalPaid],[ResponsibilityReguler],[FinalTermReguler],[MidTermReguler],[VentureReguler],[ResponsibilityAppendix],[FinalTermAppendix],[MidTermAppendix],[VentureAppendix],[Note],[QuarterSessionId]) VALUES (NEWID(), @term, 'SG15-1', @WorkshopName, 'CaseCompose', 0, 0, 0, NULL, 0, 0, 1, NULL, 0, NULL, @QuarterSessionId), (NEWID(), @term, 'DF11-2', @WorkshopName, 'CaseCompose', 0, 0, 0, NULL, 0, 0, 1, NULL, 0, NULL, @QuarterSessionId)

--UPDATE [dbo].[HonorEpitomeSummary] SET [TotalPaid] = IIF(CEILING (ISNULL(CONVERT(FLOAT,[ResponsibilityReguler]),0) + ISNULL(CONVERT(FLOAT,[FinalTermReguler]),0) + ISNULL(CONVERT(FLOAT,[MidTermReguler]),0) + ISNULL(CONVERT(FLOAT,[VentureReguler]),0) + ISNULL(CONVERT(FLOAT,[ResponsibilityAppendix]),0) + ISNULL(CONVERT(FLOAT,[FinalTermAppendix]),0) + ISNULL(CONVERT(FLOAT,[MidTermAppendix]),0) + ISNULL(CONVERT(FLOAT,[VentureAppendix]),0))<0,0,CEILING (ISNULL(CONVERT(FLOAT,[ResponsibilityReguler]),0) + ISNULL(CONVERT(FLOAT,[FinalTermReguler]),0) + ISNULL(CONVERT(FLOAT,[MidTermReguler]),0) + ISNULL(CONVERT(FLOAT,[VentureReguler]),0) + ISNULL(CONVERT(FLOAT,[ResponsibilityAppendix]),0) + ISNULL(CONVERT(FLOAT,[FinalTermAppendix]),0) + ISNULL(CONVERT(FLOAT,[MidTermAppendix]),0) + ISNULL(CONVERT(FLOAT,[VentureAppendix]),0)))