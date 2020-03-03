USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateFamilyMarkSummary] (
	@Term NVARCHAR(MAX) = N''
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
IF OBJECT_ID('tempdb.dbo.#AssesmentIngredient', 'U') IS NOT NULL DROP TABLE #AssesmentIngredient;
IF OBJECT_ID('tempdb.dbo.#FamilyMark', 'U') IS NOT NULL DROP TABLE #FamilyMark;
IF OBJECT_ID('tempdb.dbo.#MarkSummary', 'U') IS NOT NULL DROP TABLE #MarkSummary;
IF OBJECT_ID('tempdb.dbo.##FamilyMarkSummary', 'U') IS NOT NULL DROP TABLE ##FamilyMarkSummary;
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
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @Query NVARCHAR(MAX)
;----------------------------------------------------------------------
;WITH FamilyMark_CTE AS (
	SELECT DISTINCT pvt_FamilyMark.BrandBusinessId, pvt_FamilyMark.MemberId, pvt_FamilyMark.QuarterSessionId, pvt_FamilyMark.ContentOutlineId, pvt_FamilyMark.BrandName, [Responsibility] = MAX(pvt_FamilyMark.Responsibility), [Venture] = MAX(pvt_FamilyMark.Venture), [MidTerm] = MAX(pvt_FamilyMark.MidTerm), [FinalTerm] = MAX(pvt_FamilyMark.FinalTerm), [OldResponsibility] = MAX(pvt_FamilyMark.OldResponsibility), [OldVenture] = MAX(pvt_FamilyMark.OldVenture), [OldMidTerm] = MAX(pvt_FamilyMark.OldMidTerm), [OldFinalTerm] = MAX(pvt_FamilyMark.OldFinalTerm)
	FROM (
	SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, ss.Type, [Summary] = CONVERT(NUMERIC(10,2),CEILING(SUM((CONVERT(NUMERIC(10,2),ISNULL(ss.Mark,0.00)) * CONVERT(NUMERIC(10,2), ec.DetailPercentage))/100.00) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type))),[OldSummary] = CONVERT(NUMERIC(10,2),SUM((CONVERT(NUMERIC(10,2),ISNULL(ss.Mark,0.00)) * CONVERT(NUMERIC(10,2), ec.DetailPercentage))/100.00) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type)), [OldType] = 'Old'+ss.Type
		FROM #AssesmentIngredient ec
			JOIN #FamilyMark ss ON ec.ContentOutlineId = ss.ContentOutlineId
				AND ec.Type = ss.Type
				AND ec.DetailNumber = ss.Number
				AND ec.QuarterSessionId = ss.QuarterSessionId
		) AS SourceTable PIVOT (MAX(SourceTable.[Summary]) FOR [Type] IN ([Responsibility],[Venture],[MidTerm],[FinalTerm])) AS pvt PIVOT (MAX(pvt.[OldSummary]) FOR [OldType] IN ([OldResponsibility],[OldVenture],[OldMidTerm],[OldFinalTerm])) AS pvt_FamilyMark
	Batch BY pvt_FamilyMark.BrandBusinessId, pvt_FamilyMark.MemberId, pvt_FamilyMark.QuarterSessionId, pvt_FamilyMark.ContentOutlineId, pvt_FamilyMark.BrandName
), AssesmentIngredient_CTE AS (
	SELECT DISTINCT pvt_AssesmentIngredient.QuarterSessionId, pvt_AssesmentIngredient.ContentOutlineId, [Responsibility] = MAX(CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.Responsibility,0.00))), [Venture] = MAX(CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.Venture,0.00))), [MidTerm] = MAX(CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.MidTerm,0.00))), [FinalTerm] = MAX(CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.FinalTerm,0.00))), [IngredientDetailPercentage10000] = STUFF((SELECT ISNULL((CASE WHEN ec2.[DetailPercentage10000] = 'Y' THEN ','+ec2.[Type] ELSE '' END),'') FROM (SELECT DISTINCT ec3.QuarterSessionId, ec3.ContentOutlineId, ec3.[Type], ec3.Percentage, ec3.DetailPercentage10000 FROM #AssesmentIngredient ec3)  ec2 WHERE ec2.QuarterSessionId = pvt_AssesmentIngredient.QuarterSessionId AND ec2.ContentOutlineId = pvt_AssesmentIngredient.ContentOutlineId FOR XML PATH ('')),1,1,'')
	FROM (SELECT DISTINCT ec.QuarterSessionId, ec.ContentOutlineId, ec.[Type], ec.Percentage FROM #AssesmentIngredient ec) SourceTable PIVOT (MAX(Percentage) FOR Type IN ([Responsibility],[Venture],[MidTerm],[FinalTerm])) AS pvt_AssesmentIngredient
	Batch BY pvt_AssesmentIngredient.QuarterSessionId, pvt_AssesmentIngredient.ContentOutlineId
)
SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, [Responsibility] = ISNULL(CONVERT(VARCHAR,CONVERT(INT,ss.Responsibility)), '-'), [Venture] = ISNULL(CONVERT(VARCHAR,CONVERT(INT,ss.Venture)),'-'), [MidTerm] = ISNULL(CONVERT(VARCHAR,CONVERT(INT,ss.MidTerm)),'-'), [FinalTerm] = ISNULL(CONVERT(VARCHAR,CONVERT(INT,ss.FinalTerm)),'-'), [TotalMark] = CEILING(((CASE WHEN ec.[IngredientDetailPercentage10000] LIKE '%Responsibility%' 
	THEN (CEILING(ISNULL(ss.OldResponsibility,0.00))*ec.Responsibility) ELSE (ISNULL(ss.OldResponsibility,0.00)*ec.Responsibility) END)
+(CASE WHEN ec.IngredientDetailPercentage10000 LIKE '%Venture%' 
	THEN (CEILING(ISNULL(ss.OldVenture,0.00))*ec.Venture) ELSE (ISNULL(ss.OldVenture,0.00)*ec.Venture) END)
+(CASE WHEN ec.IngredientDetailPercentage10000 LIKE '%MidTerm%' 
	THEN (CEILING(ISNULL(ss.OldMidTerm,0.00))*ec.MidTerm) ELSE (ISNULL(ss.OldMidTerm,0.00)*ec.MidTerm) END)
+(CASE WHEN ec.IngredientDetailPercentage10000 LIKE '%FinalTerm%' 
	THEN (CEILING(ISNULL(ss.OldFinalTerm,0.00))*ec.FinalTerm) ELSE (ISNULL(ss.OldFinalTerm,0.00)*ec.FinalTerm) END))/100.00)
INTO #MarkSummary
FROM FamilyMark_CTE ss
	JOIN AssesmentIngredient_CTE ec ON ec.QuarterSessionId = ss.QuarterSessionId
		AND ec.ContentOutlineId = ss.ContentOutlineId
;----------------------------------------------------------------------
SET @LinkedServer = N'[LocalDB]'
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
	,[Responsibility] = ss.Responsibility
	,[Venture] = ss.Venture
	,[MidTerm] = ss.MidTerm
	,[FinalTerm] = ss.FinalTerm
	,[TotalMark] = ss.TotalMark
INTO ##FamilyMarkSummary
FROM OPENQUERY('+@LinkedServer+','''+replace(@OpenQuery,'''','''''')+''') mess
	LEFT JOIN #MarkSummary ss ON ss.QuarterSessionId = mess.QuarterSessionId -- JANGAN JOIN PAKE BrandBusinessId (Reason OnsiteTestple BrandBusinessId ''16770E0D-586F-E611-903A-D8D385FCE79E'', ''18770E0D-586F-E611-903A-D8D385FCE79E'')
		AND ss.ContentOutlineId = mess.ContentOutlineId
		AND ss.MemberId = mess.MemberId
	LEFT JOIN DeepSeaKingdom.dbo.EnrollmentStatus es ON es.[Family ID] = mess.MemberNumber
		AND RTRIM(es.Topic)+RIGHT(''0000''+CAST(LTRIM(es.[Catalog Number]) AS VARCHAR),4) = LEFT(mess.TopicName, CHARINDEX(''-'',mess.TopicName)-1)
		AND es.[Brand Section] = mess.BrandName
		AND es.[Academic Career] = ''RS1''
		AND es.Term = (SELECT DISTINCT QuarterSessions.Period FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessionId LIKE ''%'+@QuarterSessionId+'%'')'
;------------------------------
EXECUTE(@Query)
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.FamilyMarkSummary', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.FamilyMarkSummary;
;------------------------------
SELECT [Term] = @Term, [QuarterSessionId] = @QuarterSessionId, * INTO DeepSeaKingdom.WE.FamilyMarkSummary FROM ##FamilyMarkSummary
;------------------------------
DROP TABLE ##FamilyMarkSummary
;----------------------------------------------------------------------
/*
Instead, for a permanent table you can use
IF OBJECT_ID('dbo.Marks', 'U') IS NOT NULL 
  DROP TABLE dbo.Marks;

Or, for a temporary table you can use
IF OBJECT_ID('tempdb.dbo.#T', 'U') IS NOT NULL
  DROP TABLE #T;
*/
END