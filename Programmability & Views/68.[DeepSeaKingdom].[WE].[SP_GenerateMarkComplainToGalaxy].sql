USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateMarkComplainToGalaxy](
	@Term NVARCHAR(MAX) = N''
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.MarkComplainToGalaxy', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.MarkComplainToGalaxy;
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
;----------------------------------------------------------------------
DECLARE @Query NVARCHAR(MAX)
;----------------------------------------------------------------------
SET @Query = 'SELECT DISTINCT [Term] = spn.Term
	,[Workshop] = mmd.WorkshopName
	--,[BrandNameTheory] = spn.Brand_SECTION
	,[Date] = CONVERT(date,spn.ComplainDate)
	,[FamilyId] = spn.EXTERNAL_SYSTEM_ID
	,[BrandName] = mss.BrandName
	,[TopicCode] = spn.Topic+RIGHT(''0000''+CAST(LTRIM(spn.CATALOG_NBR) AS VARCHAR),4)
	,[GalaxyIngredient] = mmd.GalaxyIngredient
	,[Reason] = STUFF((SELECT DISTINCT '' ''+NCHAR(0x21CC)+'' [''+mmd2.LovelySiteIngredient+'' | ''+STUFF((SELECT DISTINCT '';''+mmd3.GalaxyIngredient+ISNULL(''(''+CONVERT(VARCHAR,mmd3.GalaxyNumber)+'')'','''') FROM DeepSeaKingdom.dbo.ManualBranchDescription mmd3 WHERE mmd2.ContentID = mmd3.ContentID AND mmd2.LovelySiteIngredient = mmd3.LovelySiteIngredient AND mmd2.Term = mmd3.Term FOR XML PATH ('''')),1,1,'''')+''] ''+ REPLACE(REPLACE(REPLACE(REPLACE(CAST(spn.ExplanationFamily as nvarchar(max)),CHAR(13),NCHAR(0x21B5)),CHAR(10),NCHAR(0x21B5)),'','',''.''),CHAR(9),'' '')
		FROM [ExternalDB].Mark_DB.dbo.FamilyComplainMark spn2
			JOIN (SELECT DISTINCT Term, BrandNbrTheory, ContentID, ContentIDParent, MemberYY, LovelySiteIngredient FROM DeepSeaKingdom.dbo.ManualMarkSummary WHERE Term = '''+@Term+''') mss2 ON mss2.Term = spn2.Term
				AND mss2.LovelySiteIngredient = spn2.TYPE_DESCR
				AND mss2.BrandNbrTheory = spn2.Brand_NBR
				AND mss2.ContentID = spn2.Content_ID
				AND mss2.MemberYY = spn2.ASCID
				AND (spn2.ASCID_Associate = '''' OR spn2.ASCID_Associate = ''A0001'') AND spn2.Department = ''YYS01''AND spn2.Position = ''RS1'' AND spn2.Term <> ''D''AND spn2.Status = ''2''AND spn2.Term = '''+@Term+'''
			JOIN DeepSeaKingdom.dbo.ManualBranchDescription mmd2 ON mmd2.ContentID = mss2.ContentIDParent
				AND mmd2.LovelySiteIngredient = mss2.LovelySiteIngredient
				AND mmd2.Term = mss2.Term
		WHERE mmd.ContentID = mmd2.ContentID AND mmd.GalaxyIngredient = mmd2.GalaxyIngredient AND spn.ASCID = spn2.ASCID AND spn.Content_ID = spn2.Content_ID AND mmd.Term = mmd2.Term FOR XML PATH('''')),1,3,'''')
	,[LovelySiteIngredient] = spn.TYPE_DESCR
	,[GalaxyIngredientDuplicateCount] = COUNT(spn.TYPE_DESCR) OVER (PARTITION BY spn.Term, spn.Brand_NBR, spn.Content_ID, spn.ASCID, mmd.GalaxyIngredient)
	,[InsertedDate] = spn.ComplainDate
INTO DeepSeaKingdom.WE.MarkComplainToGalaxy
FROM [ExternalDB].Mark_DB.dbo.FamilyComplainMark spn
	JOIN (SELECT DISTINCT Term, BrandNbrTheory, ContentID, ContentIDParent, MemberYY, LovelySiteIngredient, BrandName FROM DeepSeaKingdom.dbo.ManualMarkSummary WHERE Term = '''+@Term+''') mss ON mss.Term = spn.Term
		AND mss.BrandNbrTheory = spn.Brand_NBR
		AND mss.ContentID = spn.Content_ID
		AND mss.MemberYY = spn.ASCID
		AND mss.LovelySiteIngredient = spn.TYPE_DESCR
		AND (spn.ASCID_Associate = '''' OR spn.ASCID_Associate = ''A0001'')
		AND spn.Department = ''YYS01''
		AND spn.Position = ''RS1''
		AND spn.Term <> ''D''
		AND spn.Status = ''2''
		AND spn.PersonIn = spn.ASCID --Supaya yang dimasukin ke Galaxy cuman satu aja (yang pencet Complain, biar ga duplicates)
		AND spn.Term = '''+@Term+'''
	JOIN DeepSeaKingdom.dbo.ManualBranchDescription mmd ON mmd.ContentID = mss.ContentIDParent
		AND mmd.LovelySiteIngredient = mss.LovelySiteIngredient
		AND mmd.Term = mss.Term'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END

