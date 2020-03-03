USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateFamilyMarkDetailGalaxy] (
	@Term NVARCHAR(MAX) = N''
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
IF OBJECT_ID('tempdb.dbo.#AssesmentIngredient', 'U') IS NOT NULL DROP TABLE #AssesmentIngredient;
IF OBJECT_ID('tempdb.dbo.#FamilyMark', 'U') IS NOT NULL DROP TABLE #FamilyMark;
IF OBJECT_ID('tempdb.dbo.##MarkDetail', 'U') IS NOT NULL DROP TABLE ##MarkDetail;
IF OBJECT_ID('tempdb.dbo.#MarkDetail', 'U') IS NOT NULL DROP TABLE #MarkDetail;
IF OBJECT_ID('tempdb.dbo.##FamilyMarkDetail', 'U') IS NOT NULL DROP TABLE ##FamilyMarkDetail;
IF OBJECT_ID('tempdb.dbo.#FamilyMarkDetail', 'U') IS NOT NULL DROP TABLE #FamilyMarkDetail;
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
;----------------------------------------------------------------------
SELECT * 
INTO #AssesmentIngredient 
FROM DeepSeaKingdom.WE.UDFTV_AssesmentIngredientVerticalDetail(@QuarterSessionId)
;------------------------------
SELECT * 
INTO #FamilyMark 
FROM DeepSeaKingdom.WE.V_FamilyMark ss WHERE ss.QuarterSessionId LIKE '%'+@QuarterSessionId+'%'
;----------------------------------------------------------------------
DECLARE @ColumnMark AS NVARCHAR(MAX), @ColumnStatus AS NVARCHAR(MAX),@SelectColumnMark AS NVARCHAR(MAX), @SelectColumnStatus AS NVARCHAR(MAX), @SelectColumnMarkShow AS NVARCHAR(MAX), @SelectColumnStatusShow AS NVARCHAR(MAX), @ColumnMarkUpdate AS NVARCHAR(MAX), @ColumnStatusUpdate AS NVARCHAR(MAX), @AlterColumn AS NVARCHAR(MAX), @ColumnMarkInsert AS NVARCHAR(MAX), @ColumnStatusInsert AS NVARCHAR(MAX)
;------------------------------
SELECT @ColumnMark = STUFF((SELECT DISTINCT ',[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+']' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH('')),1,1,'')
;------------------------------
SELECT @ColumnStatus = STUFF((SELECT DISTINCT ',[Status' + ec.Type+RIGHT('00'+ec.Number,2)+']' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH('')),1,1,'')
;------------------------------
SELECT @SelectColumnMark = (SELECT DISTINCT ',[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] = MAX([Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'])' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH(''))
;------------------------------
SELECT @SelectColumnStatus = (SELECT DISTINCT ',[Status' + ec.Type+RIGHT('00'+ec.Number,2)+'] = MAX([Status' + ec.Type+RIGHT('00'+ec.Number,2)+'])' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH(''))
;------------------------------
SELECT @SelectColumnMarkShow = (SELECT DISTINCT ',[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] = (CASE WHEN [Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NOT NULL THEN ''N/A'' ELSE NULL END)' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH(''))
;------------------------------
SELECT @SelectColumnStatusShow = (SELECT DISTINCT ',[Status' + ec.Type+RIGHT('00'+ec.Number,2)+']' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH(''))
;------------------------------
SELECT @ColumnMarkUpdate = STUFF((SELECT DISTINCT ',detail.[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] = (CASE WHEN detail.[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NOT NULL AND (Mark.[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NOT NULL OR Mark.[Status' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NOT NULL) THEN ISNULL(Mark.[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'],0) WHEN detail.[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NOT NULL AND (Mark.[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NULL AND Mark.[Status' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NULL) THEN ''N/A'' ELSE NULL END)' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH('')),1,1,'')
;------------------------------
SELECT @ColumnStatusUpdate = (SELECT DISTINCT ',detail.[Status' + ec.Type+RIGHT('00'+ec.Number,2)+'] = (CASE WHEN detail.[Status' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NOT NULL AND (Mark.[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NOT NULL OR Mark.[Status' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NOT NULL) THEN ISNULL(Mark.[Status' + ec.Type+RIGHT('00'+ec.Number,2)+'],'''') WHEN detail.[Status' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NOT NULL AND (Mark.[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NULL AND Mark.[Status' + ec.Type+RIGHT('00'+ec.Number,2)+'] IS NULL) THEN ''N/A''  ELSE NULL END)' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH(''))
;------------------------------
SELECT @AlterColumn = (SELECT DISTINCT 'ALTER TABLE #FamilyMarkDetail  ALTER COLUMN [Status' + ec.Type+RIGHT('00'+ec.Number,2)+'] NVARCHAR(MAX);' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH(''))
;----------------------------------------------------------------------
SELECT @ColumnMarkInsert = STUFF((SELECT DISTINCT ',[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] = (CASE WHEN ISNUMERIC([Mark' + ec.Type+RIGHT('00'+ec.Number,2)+']) = 1 THEN CONVERT(VARCHAR,CONVERT(INT,[Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'])) ELSE [Mark' + ec.Type+RIGHT('00'+ec.Number,2)+'] END)' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH('')),1,1,'')
;------------------------------
SELECT @ColumnStatusInsert = STUFF((SELECT DISTINCT ',[Status' + ec.Type+RIGHT('00'+ec.Number,2)+']' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH('')),1,1,'')
;------------------------------
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @Query NVARCHAR(MAX)
;------------------------------
SET @LinkedServer = N'[LocalDB]'
;------------------------------
SET @OpenQuery = N'SELECT DISTINCT [WorkshopName] = lab.Name 
		,[ContentOutline] = co.Name
		,[TopicName] = Topics.Name
		,[AssociateCode] = ct.AssociateCode
		,[AssociateName] = ct.AssociateName
		,[MemberNumber] = bFamilyXXX.Number
		,[MemberName] = bFamilyXXX.Name
		,[BrandName] = RTRIM(LEFT(ct.BrandName, 5))
		,[MemberId] = bFamilyXXX.MemberId
		,[QuarterSessionId] = ct.QuarterSessionId
		,[ContentOutlineId] = Topics.ContentOutlineId
	FROM Galaxy.dbo.BrandBusinesss ct 
		JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
			AND ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
			AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
		JOIN Galaxy.dbo.BrandBusinessFamilys cts ON cts.BrandBusinessId = ct.BrandBusinessId
			AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedBrandBusinessFamilys dcts WHERE dcts.BrandBusinessFamilyId = cts.BrandBusinessFamilyId AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = dcts.DeletedBrandBusinessFamilyId))
		JOIN Galaxy.dbo.Workshops lab ON lab.WorkshopId = Topics.WorkshopId
		JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
		JOIN Galaxy.dbo.Members bFamilyXXX ON bFamilyXXX.MemberId = cts.MemberId'
;------------------------------
SET @Query = N'SELECT DISTINCT [House] = es.House
	,[WorkshopName] = mess.WorkshopName 
	,[ContentOutline] = mess.ContentOutline
	,[TopicName] = mess.TopicName
	,[AssociateCode] = mess.AssociateCode
	,[AssociateName] = mess.AssociateName
	,[MemberNumber] = mess.MemberNumber
	,[MemberName] = mess.MemberName
	,[BrandName] = mess.BrandName
	'+@SelectColumnMarkShow+@SelectColumnStatusShow+'
	,[MemberId] = mess.MemberId
	,[QuarterSessionId] = mess.QuarterSessionId
	,[ContentOutlineId] = mess.ContentOutlineId
INTO ##FamilyMarkDetail
FROM OPENQUERY('+@LinkedServer+','''+replace(@OpenQuery,'''','''''')+''') mess
	JOIN (
		SELECT pvt2.QuarterSessionId, pvt2.ContentOutlineId'+@SelectColumnMark+@SelectColumnStatus+'
FROM (
	SELECT DISTINCT ec.QuarterSessionId, ec.ContentOutlineId, ec.DetailPercentage, [Status] = '''', [PivotMark] = ''Mark''+ec.Type+RIGHT(''00''+ec.DetailNumber,2), [PivotStatus] = ''Status''+ec.Type+RIGHT(''00''+ec.DetailNumber,2)
	FROM #AssesmentIngredient ec
	) AS SourceTable 
		PIVOT (MAX(SourceTable.DetailPercentage) FOR [PivotMark] IN ('+@ColumnMark+')) AS pvt1 
		PIVOT (MAX(pvt1.Status) FOR [PivotStatus] IN ('+@ColumnStatus+')) AS pvt2
Batch BY pvt2.QuarterSessionId, pvt2.ContentOutlineId
	) ec ON ec.ContentOutlineId = mess.ContentOutlineId
		AND ec.QuarterSessionId = mess.QuarterSessionId
	LEFT JOIN DeepSeaKingdom.dbo.EnrollmentStatus es ON es.[Family ID] = mess.MemberNumber
		AND RTRIM(es.Topic)+RIGHT(''0000''+CAST(LTRIM(es.[Catalog Number]) AS VARCHAR),4) = LEFT(mess.TopicName, CHARINDEX(''-'',mess.TopicName)-1)
		AND es.[Brand Section] = mess.BrandName
		AND es.[Academic Career] = ''RS1''
		AND es.Term = (SELECT DISTINCT QuarterSessions.Period FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessionId LIKE ''%'+@QuarterSessionId+'%'')'
;------------------------------
EXECUTE (@Query)
;------------------------------
SELECT * INTO #FamilyMarkDetail FROM ##FamilyMarkDetail
;------------------------------
DROP TABLE ##FamilyMarkDetail
--EXEC sp_serveroption 'ATLANTIS', 'data access', 'true'
--EXEC sp_helpserver
;----------------------------------------------------------------------
SET @Query = 'SELECT DISTINCT pvt2.BrandBusinessId, pvt2.MemberId, pvt2.QuarterSessionId, pvt2.ContentOutlineId, pvt2.BrandName'+@SelectColumnMark+@SelectColumnStatus+'
INTO ##MarkDetail
FROM (
	SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, [Mark] = ISNULL(ss.Mark,0), ss.Status, [PivotMark] = ''Mark''+ss.Type+RIGHT(''00''+ss.Number,2), [PivotStatus] = ''Status''+ss.Type+RIGHT(''00''+ss.Number,2)
	FROM #FamilyMark ss
	) AS SourceTable 
		PIVOT (MAX(SourceTable.Mark) FOR [PivotMark] IN ('+@ColumnMark+')) AS pvt1 
		PIVOT (MAX(pvt1.Status) FOR [PivotStatus] IN ('+@ColumnStatus+')) AS pvt2
Batch BY pvt2.BrandBusinessId, pvt2.MemberId, pvt2.QuarterSessionId, pvt2.ContentOutlineId, pvt2.BrandName'
;------------------------------
EXECUTE(@Query)
;------------------------------
SELECT * INTO #MarkDetail FROM ##MarkDetail
;------------------------------
DROP TABLE ##MarkDetail
;----------------------------------------------------------------------
SET @Query = 'SELECT DISTINCT pvt2.BrandBusinessId, pvt2.MemberId, pvt2.QuarterSessionId, pvt2.ContentOutlineId, pvt2.BrandName'+@SelectColumnMark+@SelectColumnStatus+'
INTO ##MarkDetail
FROM (
	SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, [Mark] = ISNULL(ss.Mark,0), ss.Status, [PivotMark] = ''Mark''+ss.Type+RIGHT(''00''+ss.Number,2), [PivotStatus] = ''Status''+ss.Type+RIGHT(''00''+ss.Number,2)
	FROM #FamilyMark ss
	) AS SourceTable 
		PIVOT (MAX(SourceTable.Mark) FOR [PivotMark] IN ('+@ColumnMark+')) AS pvt1 
		PIVOT (MAX(pvt1.Status) FOR [PivotStatus] IN ('+@ColumnStatus+')) AS pvt2
Batch BY pvt2.BrandBusinessId, pvt2.MemberId, pvt2.QuarterSessionId, pvt2.ContentOutlineId, pvt2.BrandName'
;------------------------------
EXECUTE(@Query)
;----------------------------------------------------------------------
EXECUTE(@AlterColumn)
;------------------------------
SET @Query = 'UPDATE detail
SET '+@ColumnMarkUpdate+@ColumnStatusUpdate+'
FROM #FamilyMarkDetail detail
	JOIN #MarkDetail Mark ON detail.MemberId = Mark.MemberId
		AND detail.QuarterSessionId = Mark.QuarterSessionId
		AND detail.ContentOutlineId = Mark.ContentOutlineId
		AND detail.BrandName = Mark.BrandName'
;------------------------------
EXECUTE(@Query)
;----------------------------------------------------------------------
/*SELECT * INTO #FamilyMarkDetail FROM ##FamilyMarkDetail
;------------------------------
DROP TABLE ##FamilyMarkDetail
;----------------------------------------------------------------------
DROP TABLE DeepSeaKingdom.WE.FamilyMarkDetail
;------------------------------
SELECT * INTO DeepSeaKingdom.WE.FamilyMarkDetail FROM #FamilyMarkDetail
;----------------------------------------------------------------------*/
	IF OBJECT_ID('DeepSeaKingdom.WE.FamilyMarkDetail', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.FamilyMarkDetail
	;------------------------------
	SET @Query = 'SELECT DISTINCT  [Term] = '''+@Term+''', [QuarterSessionId] = '''+@QuarterSessionId+''', [House], [WorkshopName], [ContentOutline], [TopicName], [AssociateCode], [AssociateName], [MemberNumber], [MemberName], [BrandName],'+@ColumnMarkInsert+','+@ColumnStatusInsert+'
		INTO DeepSeaKingdom.WE.FamilyMarkDetail 
		FROM #FamilyMarkDetail'
	;------------------------------
	EXECUTE(@Query)	
;----------------------------------------------------------------------
END