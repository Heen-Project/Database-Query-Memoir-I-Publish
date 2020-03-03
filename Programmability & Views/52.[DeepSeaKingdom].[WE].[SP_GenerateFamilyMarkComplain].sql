USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateFamilyMarkComplain] (
	@Term NVARCHAR(MAX) = N''
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.FamilyMarkComplain', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.FamilyMarkComplain;
IF OBJECT_ID('tempdb.dbo.#CheckMarkComplainFamily', 'U') IS NOT NULL DROP TABLE #CheckMarkComplainFamily;
IF OBJECT_ID('tempdb.dbo.#CheckMarkComplainSummaryFamily', 'U') IS NOT NULL DROP TABLE #CheckMarkComplainSummaryFamily;
IF OBJECT_ID('tempdb.dbo.##FamilyMarkComplain', 'U') IS NOT NULL DROP TABLE ##FamilyMarkComplain;
;----------------------------------------------------------------------
SELECT * 
INTO #CheckMarkComplainFamily
FROM DeepSeaKingdom.WE.UDFTV_CheckMarkComplainFamily(@QuarterSessionId)
;------------------------------
SELECT * 
INTO #CheckMarkComplainSummaryFamily
FROM DeepSeaKingdom.WE.UDFTV_CheckMarkComplainSummaryFamily(@QuarterSessionId)
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @Query NVARCHAR(MAX), @QueryInner NVARCHAR(MAX)
;----------------------------------------------------------------------
SET @LinkedServer = N'[LocalDB]'
;----------------------------------------------------------------------
SET @OpenQuery = N'SELECT DISTINCT [WorkshopName] = lab.Name, [ContentOutline] = co.Name, [TopicName] = Topics.Name, [AssociateCode] = ct.AssociateCode, [AssociateName] = ct.AssociateName, [MemberNumber] = bFamilyXXX.Number, [MemberName] = bFamilyXXX.Name/*, [BrandName] = RTRIM(LEFT(ct.BrandName, 5))*/, [MemberId] = bFamilyXXX.MemberId, [QuarterSessionId] = ct.QuarterSessionId, [ContentOutlineId] = Topics.ContentOutlineId, [WorkshopId] = lab.WorkshopId, [TopicId] = Topics.TopicId
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
SET @QueryInner = 'SELECT DISTINCT [ContentOutline] = mess.ContentOutline
	,[TopicName] = mess.TopicName
	,[MemberNumber] = mess.MemberNumber
	,[MemberName] = mess.MemberName
	/*,[BrandName] = mess.BrandName*/
	,[OldMark] = ISNULL(csp.OldMark,0)
	,[NewMark] = ISNULL(csp.NewMark,0)
	,[Description] = csp.Description
	,[WorkshopName] = mess.WorkshopName
	,[LovelySiteIngredient] = mmd.LovelySiteIngredient
	,[LovelySitePercentage] = mmd.LovelySitePercentage
	,[GalaxyIngredient] = mmd.GalaxyIngredient
	,[GalaxyNumber] = mmd.GalaxyNumber
	,[GalaxyPercentage] = mmd.GalaxyPercentage
	,[LovelySiteIngredientCount] = COUNT (mmd.LovelySiteIngredient) OVER (PARTITION BY mess.ContentOutline, mess.TopicName, mess.MemberNumber/*, mess.BrandName*/, mmd.LovelySiteIngredient)
	,[GalaxyIngredientCount] = COUNT (mmd.GalaxyIngredient) OVER (PARTITION BY mess.ContentOutline, mess.TopicName, mess.MemberNumber/*, mess.BrandName*/, mmd.GalaxyIngredient, mmd.GalaxyNumber)
	,[SumGalaxyPercentage] = SUM(CONVERT(FLOAT,mmd.GalaxyPercentage)) OVER (PARTITION BY mess.ContentOutline, mess.TopicName, mess.MemberNumber, mmd.LovelySiteIngredient)
	,[SumLovelySitePercentage] = SUM(CONVERT(FLOAT,mmd.LovelySitePercentage)) OVER (PARTITION BY mess.ContentOutline, mess.TopicName, mess.MemberNumber/*, mess.BrandName*/, mmd.GalaxyIngredient, mmd.GalaxyNumber)
FROM (SELECT csps.QuarterSessionId, csps.WorkshopId, csps.FormNumber, csps.ComplainNumber, csps.CheckerId, csps.CheckerBy, csps.Description, csps.SavedBy, csps.SavedDate, csps.Type, csps.Number, csps.MemberId, csps.OldMark, csps.OldStatus, csps.NewMark, csps.NewStatus, csps.TopicId FROM #CheckMarkComplainFamily csps UNION SELECT cspss.QuarterSessionId, cspss.WorkshopId, cspss.FormNumber, cspss.ComplainNumber, cspss.CheckerId, cspss.CheckerBy, cspss.Description, cspss.SavedBy, cspss.SavedDate, cspss.Type, NULL, cspss.MemberId, cspss.OldMark, NULL, cspss.NewMark, NULL, cspss.TopicId FROM #CheckMarkComplainSummaryFamily cspss) csp
	JOIN OPENQUERY('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') mess ON mess.TopicId = csp.TopicId
		AND mess.MemberId = csp.MemberId
		AND mess.QuarterSessionId = csp.QuarterSessionId
		AND mess.WorkshopId = csp.WorkshopId
		AND csp.ComplainNumber = 1
	JOIN [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd ON mmd.ContentCode = LEFT(mess.ContentOutline,CHARINDEX(''-'',mess.ContentOutline)-1)
			AND mmd.GalaxyIngredient+RIGHT(''00''+CONVERT(VARCHAR,ISNULL(mmd.GalaxyNumber,0)),2) = csp.Type+RIGHT(''00''+CONVERT(VARCHAR,ISNULL(csp.Number,0)),2)
			AND mmd.Term = '''+@Term+''''
;------------------------------
SET @Query = 'WITH CheckMarkComplain_CTE AS('+@QueryInner+')
		SELECT DISTINCT [Term] = '''+@Term+''', csp.WorkshopName, csp.ContentOutline, csp.TopicName, csp.MemberNumber, csp.MemberName/*, csp.BrandName*/, [NewMark] = CEILING(SUM(CONVERT(FLOAT, csp.NewMark)*IIF(CONVERT(FLOAT,csp.GalaxyPercentage)=100,1,CONVERT(FLOAT,csp.GalaxyPercentage)/IIF(csp.GalaxyIngredientCount=1,CONVERT(FLOAT,csp.LovelySitePercentage),CONVERT(FLOAT,csp.SumLovelySitePercentage)))) OVER (PARTITION BY csp.ContentOutline, csp.TopicName, csp.MemberNumber/*, csp.BrandName*/, csp.LovelySiteIngredient)),[OldMark] = CEILING(SUM(CONVERT(FLOAT, csp.OldMark)*IIF(CONVERT(FLOAT,csp.GalaxyPercentage)=100,1,CONVERT(FLOAT,csp.GalaxyPercentage)/IIF(csp.GalaxyIngredientCount=1,CONVERT(FLOAT,csp.LovelySitePercentage),CONVERT(FLOAT,csp.SumLovelySitePercentage)))) OVER (PARTITION BY csp.ContentOutline, csp.TopicName, csp.MemberNumber/*, csp.BrandName*/, csp.LovelySiteIngredient)),  [Description] = REPLACE(REPLACE(REPLACE(REPLACE(CAST(spn.ExplanationFamily as nvarchar(max)),CHAR(13),NCHAR(0x21B5)),CHAR(10),NCHAR(0x21B5)),'','',''.''),CHAR(9),'' ''), csp.LovelySiteIngredient, [GalaxyIngredient] = RTRIM(csp.GalaxyIngredient+'' ''+REPLACE(ISNULL(RIGHT(''00''+CONVERT(VARCHAR,ISNULL(csp.GalaxyNumber,0)),2), ''''),''00'','''')), [TransferStatus] = CONVERT(VARCHAR(5),NULL) /*, csp.GalaxyIngredientCount, csp.LovelySiteIngredientCount, csp.GalaxyPercentage, csp.LovelySitePercentage, csp.SumGalaxyPercentage, csp.SumLovelySitePercentage*/
		INTO ##FamilyMarkComplain
		FROM CheckMarkComplain_CTE csp'
;------------------------------
EXECUTE (@Query)
;------------------------------
SET @Query = 'SELECT DISTINCT ssp.Term, ssp.WorkshopName, ssp.ContentOutline, ssp.TopicName, ssp.MemberNumber, ssp.MemberName, ssp.NewMark, ssp.OldMark, [Description] = STUFF((SELECT '' ''+NCHAR(0x21CC)+'' [''+ssp2.GalaxyIngredient+''] ''+ssp2.[Description] FROM ##FamilyMarkComplain ssp2 WHERE ssp2.Term = ssp.Term AND ssp2.TopicName = ssp.TopicName AND ssp2.MemberNumber = ssp.MemberNumber AND ssp2.LovelySiteIngredient = ssp.LovelySiteIngredient FOR XML PATH ('''')),1,3,''''), ssp.LovelySiteIngredient, ssp.TransferStatus
		INTO DeepSeaKingdom.WE.FamilyMarkComplain
		FROM ##FamilyMarkComplain ssp'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END