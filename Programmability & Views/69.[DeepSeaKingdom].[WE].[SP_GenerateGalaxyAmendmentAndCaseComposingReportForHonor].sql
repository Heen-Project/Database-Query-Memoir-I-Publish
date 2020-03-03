USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateGalaxyVentureAndCaseComposingReportForHonor] (
	@Term NVARCHAR(MAX) = N''
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX),@WorkshopId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
SELECT @WorkshopId = Workshops.WorkshopId FROM [LocalDB].Galaxy.dbo.Workshops WHERE Workshops.Name LIKE '%'+@WorkshopName+'%'
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
IF @WorkshopId IS NULL SET @WorkshopName = NULL
;----------------------------------------------------------------------
DECLARE @tcacmrId NVARCHAR(MAX), @tcacmrKey NVARCHAR(MAX), @Account NVARCHAR(MAX), @EmployeeNumber NVARCHAR(MAX), @Personname NVARCHAR(MAX), @Name NVARCHAR(MAX), @HonorVentureBeforeFines NVARCHAR(MAX), @FinesVenture NVARCHAR(MAX), @HonorVenture NVARCHAR(MAX), @HonorComposing NVARCHAR(MAX), @TotalHonor NVARCHAR(MAX), @Venture NVARCHAR(MAX), @CaseComposing NVARCHAR(MAX), @NonPaidVenture NVARCHAR(MAX), @LimitVenture NVARCHAR(MAX), @Responsibility NVARCHAR(MAX), @Venture NVARCHAR(MAX), @NonPaidResponsibility NVARCHAR(MAX), @NonPaidVenture NVARCHAR(MAX), @FinalTerm NVARCHAR(MAX), @AppendixResponsibility NVARCHAR(MAX), @AppendixFinalTerm NVARCHAR(MAX), @AppendixVenture NVARCHAR(MAX), @Note NVARCHAR(MAX)
;------------------------------
DECLARE @TemporaryVentureReportTable TABLE ([Account] NVARCHAR(MAX), [EmployeeNumber] NVARCHAR(MAX), [Personname] NVARCHAR(MAX), [Name] NVARCHAR(MAX), [HonorVentureBeforeFines] NVARCHAR(MAX), [FinesVenture] NVARCHAR(MAX), [HonorVenture] NVARCHAR(MAX), [HonorComposing] NVARCHAR(MAX), [TotalHonor] NVARCHAR(MAX), [Note] NVARCHAR(MAX), [ReportType] NVARCHAR(MAX), [ContentOutline] NVARCHAR(MAX), [BrandName] NVARCHAR(MAX), [Type] NVARCHAR(MAX), [TotalVenture] NVARCHAR(MAX), [Honor] NVARCHAR(MAX), [isAppendix] NVARCHAR(MAX))
DECLARE @TemporaryCaseComposingReportTable TABLE ([Account] NVARCHAR(MAX), [EmployeeNumber] NVARCHAR(MAX), [Personname] NVARCHAR(MAX), [Name] NVARCHAR(MAX), [HonorVentureBeforeFines] NVARCHAR(MAX), [FinesVenture] NVARCHAR(MAX), [HonorVenture] NVARCHAR(MAX), [HonorComposing] NVARCHAR(MAX), [TotalHonor] NVARCHAR(MAX), [Note] NVARCHAR(MAX), [ReportType] NVARCHAR(MAX), [Description] NVARCHAR(MAX), [Type] NVARCHAR(MAX), [Honor] NVARCHAR(MAX))
DECLARE @TemporaryTotalVentureAndCaseComposingTable TABLE ([Account] NVARCHAR(MAX), [EmployeeNumber] NVARCHAR(MAX), [Personname] NVARCHAR(MAX), [Name] NVARCHAR(MAX), [HonorVentureBeforeFines] NVARCHAR(MAX), [FinesVenture] NVARCHAR(MAX), [HonorVenture] NVARCHAR(MAX), [HonorComposing] NVARCHAR(MAX), [TotalHonor] NVARCHAR(MAX), [Note] NVARCHAR(MAX), [ReportType] NVARCHAR(MAX), [TotalVenture] NVARCHAR(MAX), [TotalCaseComposing] NVARCHAR(MAX), [LimitVenture] NVARCHAR(MAX), [LimitCaseComposing] NVARCHAR(MAX))
;------------------------------
DECLARE TotalVentureAndCaseComposingReport_Cursor CURSOR FOR
SELECT tcacmr.[Id], fo.[key], JSON_VALUE(fo.[value],'$.Account') AS Account, JSON_VALUE(fo.[value],'$.EmployeeNumber') AS EmployeeNumber, JSON_VALUE(fo.[value],'$.Personname') AS Personname, JSON_VALUE(fo.[value],'$.Name') AS Name, JSON_VALUE(fo.[value],'$.HonorVentureBeforeFines') AS HonorVentureBeforeFines, JSON_VALUE(fo.[value],'$.FinesVenture') AS FinesVenture, JSON_VALUE(fo.[value],'$.HonorVenture') AS HonorVenture, JSON_VALUE(fo.[value],'$.HonorComposing') AS HonorComposing, JSON_VALUE(fo.[value],'$.TotalHonor') AS TotalHonor, JSON_QUERY(fo.[value],'$.Venture') AS Venture, JSON_QUERY(fo.[value],'$.CaseComposing') AS CaseComposing, JSON_QUERY(fo.[value],'$.NonPaidVenture') AS NonPaidVenture, JSON_QUERY(fo.[value],'$.LimitVenture') AS LimitVenture, JSON_QUERY(fo.[value],'$.Responsibility') AS Responsibility, JSON_QUERY(fo.[value],'$.Venture') AS Venture, JSON_QUERY(fo.[value],'$.NonPaidResponsibility') AS NonPaidResponsibility, JSON_QUERY(fo.[value],'$.NonPaidVenture') AS NonPaidVenture, JSON_QUERY(fo.[value],'$.FinalTerm') AS FinalTerm, JSON_QUERY(fo.[value],'$.AppendixResponsibility') AS AppendixResponsibility, JSON_QUERY(fo.[value],'$.AppendixFinalTerm') AS AppendixFinalTerm, JSON_QUERY(fo.[value],'$.AppendixVenture') AS AppendixVenture, JSON_VALUE(fo.[value],'$.Note') AS Note
FROM [LocalDB].Items.dbo.[System.Collections.Generic.List`1_Galaxy.Model.TotalVentureAndCaseComposingReport_] tcacmr 
	CROSS APPLY OPENJSON (tcacmr.[FileObject]) AS fo
WHERE ISJSON(tcacmr.[FileObject])>0
	AND tcacmr.FileName LIKE @QuarterSessionId+'|'+@WorkshopId
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[System.Collections.Generic.List`1_Galaxy.Model.TotalVentureAndCaseComposingReport_] tcacmr2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].[Galaxy].[dbo].[DeletedItems] di WHERE di.[DataId] = tcacmr2.[Id]) AND tcacmr.[FileName] = tcacmr2.[FileName]  Batch BY tcacmr2.[FileName] HAVING MAX(tcacmr2.[SavedDate]) = tcacmr.[SavedDate]) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].[Galaxy].[dbo].[DeletedItems] di WHERE di.[DataId] = tcacmr.[Id]) 
;----------------------------------------------------------------------
OPEN TotalVentureAndCaseComposingReport_Cursor
;------------------------------
	FETCH NEXT FROM TotalVentureAndCaseComposingReport_Cursor INTO @tcacmrId, @tcacmrKey, @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Venture, @CaseComposing, @NonPaidVenture, @LimitVenture, @Responsibility, @Venture, @NonPaidResponsibility, @NonPaidVenture, @FinalTerm, @AppendixResponsibility, @AppendixFinalTerm, @AppendixVenture, @Note 
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		INSERT INTO @TemporaryVentureReportTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'Venture', as_tcacmr.[ContentOutline], as_tcacmr.[BrandName], as_tcacmr.[Type], as_tcacmr.[TotalVenture], as_tcacmr.[Honor], as_tcacmr.[isAppendix]
		FROM (SELECT DISTINCT * FROM OPENJSON(@Venture) WITH ([ContentOutline] NVARCHAR(MAX), [BrandName] NVARCHAR(MAX), [Type] NVARCHAR(MAX), [TotalVenture] NVARCHAR(MAX), [Honor] NVARCHAR(MAX), [isAppendix] NVARCHAR(MAX))) as_tcacmr
		;------------------------------
		INSERT INTO @TemporaryVentureReportTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'NonPaidVenture', as_tcacmr.[ContentOutline], as_tcacmr.[BrandName], as_tcacmr.[Type], as_tcacmr.[TotalVenture], as_tcacmr.[Honor], as_tcacmr.[isAppendix]
		FROM (SELECT DISTINCT * FROM OPENJSON(@NonPaidVenture) WITH ([ContentOutline] NVARCHAR(MAX), [BrandName] NVARCHAR(MAX), [Type] NVARCHAR(MAX), [TotalVenture] NVARCHAR(MAX), [Honor] NVARCHAR(MAX), [isAppendix] NVARCHAR(MAX))) as_tcacmr
		;------------------------------
		INSERT INTO @TemporaryVentureReportTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'LimitVenture', as_tcacmr.[ContentOutline], as_tcacmr.[BrandName], as_tcacmr.[Type], as_tcacmr.[TotalVenture], as_tcacmr.[Honor], as_tcacmr.[isAppendix]
		FROM (SELECT DISTINCT * FROM OPENJSON(@LimitVenture) WITH ([ContentOutline] NVARCHAR(MAX), [BrandName] NVARCHAR(MAX), [Type] NVARCHAR(MAX), [TotalVenture] NVARCHAR(MAX), [Honor] NVARCHAR(MAX), [isAppendix] NVARCHAR(MAX))) as_tcacmr
		;----------------------------------------------------------------------
		INSERT INTO @TemporaryCaseComposingReportTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'CaseComposing', as_tcacmr.[Description], as_tcacmr.[Type], as_tcacmr.[Honor]
		FROM (SELECT DISTINCT * FROM OPENJSON(@CaseComposing) WITH ([Description] NVARCHAR(MAX), [Type] NVARCHAR(MAX), [Honor] NVARCHAR(MAX))) as_tcacmr
		;----------------------------------------------------------------------
		INSERT INTO @TemporaryTotalVentureAndCaseComposingTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'Responsibility', as_tcacmr.[TotalVenture], as_tcacmr.[TotalCaseComposing], as_tcacmr.[LimitVenture], as_tcacmr.[LimitCaseComposing]
		FROM (SELECT DISTINCT * FROM OPENJSON(@Responsibility) WITH ([TotalVenture] NVARCHAR(MAX), [TotalCaseComposing] NVARCHAR(MAX), [LimitVenture] NVARCHAR(MAX), [LimitCaseComposing] NVARCHAR(MAX))) as_tcacmr
		;------------------------------
		INSERT INTO @TemporaryTotalVentureAndCaseComposingTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'Venture', as_tcacmr.[TotalVenture], as_tcacmr.[TotalCaseComposing], as_tcacmr.[LimitVenture], as_tcacmr.[LimitCaseComposing]
		FROM (SELECT DISTINCT * FROM OPENJSON(@Venture) WITH ([TotalVenture] NVARCHAR(MAX), [TotalCaseComposing] NVARCHAR(MAX), [LimitVenture] NVARCHAR(MAX), [LimitCaseComposing] NVARCHAR(MAX))) as_tcacmr
		;------------------------------
		INSERT INTO @TemporaryTotalVentureAndCaseComposingTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'FinalTerm', as_tcacmr.[TotalVenture], as_tcacmr.[TotalCaseComposing], as_tcacmr.[LimitVenture], as_tcacmr.[LimitCaseComposing]
		FROM (SELECT DISTINCT * FROM OPENJSON(@FinalTerm) WITH ([TotalVenture] NVARCHAR(MAX), [TotalCaseComposing] NVARCHAR(MAX), [LimitVenture] NVARCHAR(MAX), [LimitCaseComposing] NVARCHAR(MAX))) as_tcacmr
		;------------------------------
		INSERT INTO @TemporaryTotalVentureAndCaseComposingTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'NonPaidResponsibility', as_tcacmr.[TotalVenture], as_tcacmr.[TotalCaseComposing], as_tcacmr.[LimitVenture], as_tcacmr.[LimitCaseComposing]
		FROM (SELECT DISTINCT * FROM OPENJSON(@NonPaidResponsibility) WITH ([TotalVenture] NVARCHAR(MAX), [TotalCaseComposing] NVARCHAR(MAX), [LimitVenture] NVARCHAR(MAX), [LimitCaseComposing] NVARCHAR(MAX))) as_tcacmr
		;------------------------------
		INSERT INTO @TemporaryTotalVentureAndCaseComposingTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'NonPaidVenture', as_tcacmr.[TotalVenture], as_tcacmr.[TotalCaseComposing], as_tcacmr.[LimitVenture], as_tcacmr.[LimitCaseComposing]
		FROM (SELECT DISTINCT * FROM OPENJSON(@NonPaidVenture) WITH ([TotalVenture] NVARCHAR(MAX), [TotalCaseComposing] NVARCHAR(MAX), [LimitVenture] NVARCHAR(MAX), [LimitCaseComposing] NVARCHAR(MAX))) as_tcacmr
		;------------------------------
		INSERT INTO @TemporaryTotalVentureAndCaseComposingTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'AppendixResponsibility', as_tcacmr.[TotalVenture], as_tcacmr.[TotalCaseComposing], as_tcacmr.[LimitVenture], as_tcacmr.[LimitCaseComposing]
		FROM (SELECT DISTINCT * FROM OPENJSON(@AppendixResponsibility) WITH ([TotalVenture] NVARCHAR(MAX), [TotalCaseComposing] NVARCHAR(MAX), [LimitVenture] NVARCHAR(MAX), [LimitCaseComposing] NVARCHAR(MAX))) as_tcacmr
		;------------------------------
		INSERT INTO @TemporaryTotalVentureAndCaseComposingTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'AppendixFinalTerm', as_tcacmr.[TotalVenture], as_tcacmr.[TotalCaseComposing], as_tcacmr.[LimitVenture], as_tcacmr.[LimitCaseComposing]
		FROM (SELECT DISTINCT * FROM OPENJSON(@AppendixFinalTerm) WITH ([TotalVenture] NVARCHAR(MAX), [TotalCaseComposing] NVARCHAR(MAX), [LimitVenture] NVARCHAR(MAX), [LimitCaseComposing] NVARCHAR(MAX))) as_tcacmr
		;------------------------------
		INSERT INTO @TemporaryTotalVentureAndCaseComposingTable
		SELECT @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Note, 'AppendixVenture', as_tcacmr.[TotalVenture], as_tcacmr.[TotalCaseComposing], as_tcacmr.[LimitVenture], as_tcacmr.[LimitCaseComposing]
		FROM (SELECT DISTINCT * FROM OPENJSON(@AppendixVenture) WITH ([TotalVenture] NVARCHAR(MAX), [TotalCaseComposing] NVARCHAR(MAX), [LimitVenture] NVARCHAR(MAX), [LimitCaseComposing] NVARCHAR(MAX))) as_tcacmr
		--
	FETCH NEXT FROM TotalVentureAndCaseComposingReport_Cursor INTO @tcacmrId, @tcacmrKey, @Account, @EmployeeNumber, @Personname, @Name, @HonorVentureBeforeFines, @FinesVenture, @HonorVenture, @HonorComposing, @TotalHonor, @Venture, @CaseComposing, @NonPaidVenture, @LimitVenture, @Responsibility, @Venture, @NonPaidResponsibility, @NonPaidVenture, @FinalTerm, @AppendixResponsibility, @AppendixFinalTerm, @AppendixVenture, @Note
	END 
;------------------------------
CLOSE TotalVentureAndCaseComposingReport_Cursor
;----------------------------------------------------------------------
DEALLOCATE TotalVentureAndCaseComposingReport_Cursor
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.GalaxyVentureReportForHonor', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.GalaxyVentureReportForHonor;
IF OBJECT_ID('DeepSeaKingdom.WE.GalaxyCaseComposingReportForHonor', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.GalaxyCaseComposingReportForHonor;
IF OBJECT_ID('DeepSeaKingdom.WE.GalaxyTotalVentureAndCaseComposingReportForHonor', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.GalaxyTotalVentureAndCaseComposingReportForHonor;
;----------------------------------------------------------------------
SELECT DISTINCT [Term] = @Term, tcrt.[Account], tcrt.[EmployeeNumber], tcrt.[Personname], tcrt.[Name], tcrt.[HonorVentureBeforeFines], tcrt.[FinesVenture], tcrt.[HonorVenture], tcrt.[HonorComposing], tcrt.[TotalHonor], tcrt.[Note], tcrt.[ReportType], tcrt.[ContentOutline], tcrt.[BrandName], tcrt.[Type], tcrt.[TotalVenture], tcrt.[Honor], tcrt.[isAppendix]
INTO DeepSeaKingdom.WE.GalaxyVentureReportForHonor
FROM @TemporaryVentureReportTable tcrt
;------------------------------
SELECT DISTINCT [Term] = @Term, tcmrt.[Account], tcmrt.[EmployeeNumber], tcmrt.[Personname], tcmrt.[Name], tcmrt.[HonorVentureBeforeFines], tcmrt.[FinesVenture], tcmrt.[HonorVenture], tcmrt.[HonorComposing], tcmrt.[TotalHonor], tcmrt.[Note], tcmrt.[ReportType], tcmrt.[Description], tcmrt.[Type], tcmrt.[Honor]
INTO DeepSeaKingdom.WE.GalaxyCaseComposingReportForHonor
FROM @TemporaryCaseComposingReportTable tcmrt
;------------------------------
SELECT DISTINCT [Term] = @Term, ttcacmt.[Account], ttcacmt.[EmployeeNumber], ttcacmt.[Personname], ttcacmt.[Name], ttcacmt.[HonorVentureBeforeFines], ttcacmt.[FinesVenture], ttcacmt.[HonorVenture], ttcacmt.[HonorComposing], ttcacmt.[TotalHonor], ttcacmt.[Note], ttcacmt.[ReportType], ttcacmt.[TotalVenture], ttcacmt.[TotalCaseComposing], ttcacmt.[LimitVenture], ttcacmt.[LimitCaseComposing]
INTO DeepSeaKingdom.WE.GalaxyTotalVentureAndCaseComposingReportForHonor
FROM @TemporaryTotalVentureAndCaseComposingTable ttcacmt
;----------------------------------------------------------------------
END