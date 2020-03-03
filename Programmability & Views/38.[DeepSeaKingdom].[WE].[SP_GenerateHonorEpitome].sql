USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateHonorEpitome](
	@VentureResponsibilityBatchContentCode NVARCHAR(MAX) = N''
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @Query NVARCHAR(MAX), @ResponsibilityWeight NVARCHAR(MAX) = N'0.5', @VentureWeight NVARCHAR(MAX) = N'2.0', @FinalTermWeight NVARCHAR(MAX) = N'1.0', @MidTermWeight NVARCHAR(MAX) = N'1.0'
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.VentureHonorEpitomeDetail', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.VentureHonorEpitomeDetail;
IF OBJECT_ID('DeepSeaKingdom.WE.CaseComposingHonorEpitomeDetail', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.CaseComposingHonorEpitomeDetail;
IF OBJECT_ID('DeepSeaKingdom.WE.VentureHonorAppendixEpitomeDetail', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.VentureHonorAppendixEpitomeDetail;
IF OBJECT_ID('DeepSeaKingdom.WE.VentureHonorEpitomeSummary', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.VentureHonorEpitomeSummary;
IF OBJECT_ID('DeepSeaKingdom.WE.CaseComposingHonorEpitomeSummary', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.CaseComposingHonorEpitomeSummary;
;----------------------------------------------------------------------
SET @Query = N'WITH Responsibility_CTE AS (
SELECT DISTINCT csfp.Id, csfp.Corrector, csfp.ContentName, csfp.BrandName, csfp.LimitStatus, csfp.PaidStatus, csfp.Type, csfp.Number, csfp.[Family MemberNumber], csfp.[Family Status], csfp.[Family BatchNumber], [HonorException] = IIF(pe.Id IS NULL, NULL, ''Exception''), [HasFile] = IIF(usaad.Id IS NULL, ''N'', ''Y''), csfp.CorrectorDiff
FROM DeepSeaKingdom.WE.VentureScheduleForHonor csfp
	LEFT JOIN DeepSeaKingdom.WE.FamilyResponsibilityBatch sag ON sag.FamilyNumber = csfp.[Family MemberNumber]
		AND sag.fContentOutlineId = csfp.ContentOutlineId
		AND sag.BrandName = csfp.BrandName
		AND sag.Number = csfp.Number
		AND sag.BatchNumber = csfp.[Family BatchNumber]
		AND sag.fQuarterSessionId = csfp.QuarterSessionId
		AND csfp.Type = ''Responsibility''
	LEFT JOIN (
		SELECT DISTINCT sag.BatchNumber, usaad.*
		FROM DeepSeaKingdom.WE.FamilyResponsibilityBatch sag 
			RIGHT JOIN DeepSeaKingdom.WE.UploadFamilyResponsibilityAnswerData usaad ON usaad.MemberId = sag.FamilyId
			AND usaad.ContentOutlineId = sag.fContentOutlineId
			AND LEFT(usaad.BrandName, CHARINDEX('' '',usaad.BrandName)-1) = sag.BrandName
			AND usaad.QuarterSessionId = sag.fQuarterSessionId
			AND usaad.ResponsibilityNumber = sag.Number	
	) usaad ON (usaad.BatchNumber = csfp.[Family BatchNumber] OR usaad.MemberNumber = csfp.[Family MemberNumber])
		AND usaad.ContentOutlineId = csfp.ContentOutlineId
		AND LEFT(usaad.BrandName, CHARINDEX('' '',usaad.BrandName)-1) = csfp.BrandName
		AND usaad.ResponsibilityNumber = csfp.Number
		AND usaad.QuarterSessionId = csfp.QuarterSessionId
		AND csfp.Type = ''Responsibility''
	LEFT JOIN DeepSeaKingdom.WE.V_HonorException pe ON pe.ContentOutlineId = csfp.ContentOutlineId
		AND pe.QuarterSessionId = csfp.QuarterSessionId
WHERE csfp.Type = ''Responsibility'')
,Venture_CTE AS (
SELECT DISTINCT csfp.Id, csfp.Corrector, csfp.ContentName, csfp.BrandName, csfp.LimitStatus, csfp.PaidStatus, csfp.Type, csfp.Number, csfp.[Family MemberNumber], csfp.[Family Status], csfp.[Family BatchNumber], [HonorException] = IIF(pe.Id IS NULL, NULL, ''Exception''), [HasFile] = IIF(uspad.Id IS NULL, ''N'', ''Y''), csfp.CorrectorDiff
FROM DeepSeaKingdom.WE.VentureScheduleForHonor csfp
	LEFT JOIN DeepSeaKingdom.WE.RealFamilyBatch rsg ON rsg.FamilyNumber = csfp.[Family MemberNumber]
		AND rsg.fContentOutlineId = csfp.ContentOutlineId
		AND rsg.fBrandName = csfp.BrandName
		AND csfp.Number = 1
		AND rsg.BatchNumber = csfp.[Family BatchNumber]
		AND csfp.Type = ''Venture''
	LEFT JOIN DeepSeaKingdom.WE.UploadFamilyVentureAnswerData uspad ON (uspad.BatchNumber = csfp.[Family BatchNumber] OR uspad.People = csfp.[Family MemberNumber])
		AND uspad.ContentOutlineId = csfp.ContentOutlineId
		AND RTRIM(LEFT(uspad.BrandName,5)) = csfp.BrandName
		AND csfp.Number = 1
		AND csfp.Type = ''Venture''
	LEFT JOIN DeepSeaKingdom.WE.V_HonorException pe ON pe.ContentOutlineId = csfp.ContentOutlineId
		AND pe.QuarterSessionId = csfp.QuarterSessionId
WHERE csfp.Type = ''Venture'')
,FinalTerm_CTE AS (
SELECT DISTINCT csfp.Id, csfp.Corrector, csfp.ContentName, csfp.BrandName, csfp.LimitStatus, csfp.PaidStatus, csfp.Type, csfp.Number, csfp.[Family MemberNumber], csfp.[Family Status], csfp.[Family BatchNumber], [HonorException] = IIF(pe.Id IS NULL, NULL, ''Exception''), [HasFile] = IIF(usead.Id IS NULL, ''N'', ''Y''), csfp.CorrectorDiff
FROM DeepSeaKingdom.WE.VentureScheduleForHonor csfp
	LEFT JOIN DeepSeaKingdom.WE.UploadFamilyOnsiteTestAnswerData usead ON usead.MemberNumber = csfp.[Family MemberNumber]
		AND usead.ContentOutlineId = csfp.ContentOutlineId
		AND csfp.Number = 1
		AND csfp.Type = ''FinalTerm''
	LEFT JOIN DeepSeaKingdom.WE.V_HonorException pe ON pe.ContentOutlineId = csfp.ContentOutlineId
		AND pe.QuarterSessionId = csfp.QuarterSessionId
WHERE csfp.Type = ''FinalTerm'')
SELECT DISTINCT as_union.*, [Deviation] = IIF(as_union.FileCount<>as_union.HasFileCount, ABS(as_union.FileCount-as_union.HasFileCount), NULL), [FileProcessed] = ROUND(CONVERT(FLOAT, as_union.FileCount)*as_union.Weight*IIF(as_union.LimitStatus=''Limit'',IIF(as_union.PaidStatus=''Unpaid'',-1,0),1),1), [HasFileProcessed] = ROUND(CONVERT(FLOAT, as_union.HasFileCount)*as_union.Weight*IIF(as_union.LimitStatus=''Limit'',IIF(as_union.PaidStatus=''Unpaid'',-1,0),1),1), [DeviationProcessed] =  ROUND(CONVERT(FLOAT, IIF(as_union.FileCount<>as_union.HasFileCount, ABS(as_union.FileCount-as_union.HasFileCount), NULL))*as_union.Weight*IIF(as_union.LimitStatus=''Limit'',IIF(as_union.PaidStatus=''Unpaid'',-1,0),1),1)
INTO DeepSeaKingdom.WE.VentureHonorEpitomeDetail
FROM (
	SELECT DISTINCT ftc.Corrector, ftc.ContentName, ftc.BrandName, ftc.LimitStatus, ftc.PaidStatus, ftc.Type, ftc.Number, [Weight] = '+@FinalTermWeight+', [FileCount] = COUNT(ftc.[Family MemberNumber]) OVER (PARTITION BY ftc.ContentName, ftc.BrandName, ftc.Type, ftc.Number), [HasFileCount] = COUNT(IIF(ftc.HasFile = ''Y'' OR ftc.[HonorException] IS NOT NULL,1,NULL)) OVER (PARTITION BY ftc.ContentName, ftc.BrandName, ftc.Type, ftc.Number), [CorrectorDiffCount] = COUNT(IIF(ftc.CorrectorDiff IS NOT NULL AND ftc.CorrectorDiff = ''Y'',1,NULL)) OVER (PARTITION BY ftc.ContentName, ftc.BrandName, ftc.Type, ftc.Number)
	FROM FinalTerm_CTE ftc
	WHERE (ftc.[Family Status] NOT IN (''A'', ''NF'') OR ftc.[Family Status] IS NULL)
	UNION
	SELECT DISTINCT pc.Corrector, pc.ContentName, pc.BrandName, pc.LimitStatus, pc.PaidStatus, pc.Type, pc.Number, [Weight] = '+@VentureWeight+', [FileCount] = (DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY pc.[Family BatchNumber] ASC) + DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY pc.[Family BatchNumber] DESC) - 1 + IIF(MIN(ISNULL(pc.[Family BatchNumber],''-'')) OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number) = ''-'',-1,0)), [HasFileCount] = (DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY IIF(pc.HasFile = ''Y'' OR pc.[HonorException] IS NOT NULL, pc.[Family BatchNumber],NULL) ASC) + DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY IIF(pc.HasFile = ''Y'' OR pc.[HonorException] IS NOT NULL,pc.[Family BatchNumber],NULL) DESC) - 1 + IIF(MIN(IIF(pc.HasFile = ''Y'' OR pc.[HonorException] IS NOT NULL,ISNULL(pc.[Family BatchNumber],''-''),''-'')) OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number) = ''-'',-1,0)), [CorrectorDiffCount] = (DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY IIF(pc.CorrectorDiff IS NOT NULL AND pc.CorrectorDiff = ''Y'', pc.[Family BatchNumber],NULL) ASC) + DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY IIF(pc.CorrectorDiff IS NOT NULL AND pc.CorrectorDiff = ''Y'',pc.[Family BatchNumber],NULL) DESC) - 1 + IIF(MIN(IIF(pc.CorrectorDiff IS NOT NULL AND pc.CorrectorDiff = ''Y'',ISNULL(pc.[Family BatchNumber],''-''),''-'')) OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number) = ''-'',-1,0))
	FROM Venture_CTE pc
	WHERE (pc.[Family Status] NOT IN (''A'', ''NF'') OR pc.[Family Status] IS NULL)
	UNION
	SELECT DISTINCT ac.Corrector, ac.ContentName, ac.BrandName, ac.LimitStatus, ac.PaidStatus, ac.Type, ac.Number, [Weight] = '+@ResponsibilityWeight+', [FileCount] = COUNT(ac.[Family MemberNumber]) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number), [HasFileCount] = COUNT(IIF(ac.HasFile = ''Y'' OR ac.[HonorException] IS NOT NULL,1,NULL)) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number), [CorrectorDiffCount] = COUNT(IIF(ac.CorrectorDiff IS NOT NULL AND ac.CorrectorDiff = ''Y'',1,NULL)) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number)
	FROM Responsibility_CTE ac
	WHERE (ac.[Family Status] NOT IN (''A'', ''NF'') OR ac.[Family Status] IS NULL)'+
	(CASE WHEN @VentureResponsibilityBatchContentCode IS NOT NULL AND @VentureResponsibilityBatchContentCode <> '' THEN
	'	AND LEFT(ac.ContentName, CHARINDEX(''-'', ac.ContentName)-1) NOT IN ('+@VentureResponsibilityBatchContentCode+')
	UNION
	SELECT DISTINCT ac.Corrector, ac.ContentName, ac.BrandName, ac.LimitStatus, ac.PaidStatus, ac.Type, ac.Number, [Weight] = '+@ResponsibilityWeight+', [FileCount] = (DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY ac.[Family BatchNumber] ASC) + DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY ac.[Family BatchNumber] DESC) - 1 + IIF(MIN(ISNULL(ac.[Family BatchNumber],''-'')) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number) = ''-'',-1,0)), [HasFileCount] = (DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY IIF(ac.HasFile = ''Y'' OR ac.[HonorException] IS NOT NULL, ac.[Family BatchNumber],NULL) ASC) + DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY IIF(ac.HasFile = ''Y'' OR ac.[HonorException] IS NOT NULL,ac.[Family BatchNumber],NULL) DESC) - 1 + IIF(MIN(IIF(ac.HasFile = ''Y'' OR ac.[HonorException] IS NOT NULL, ISNULL(ac.[Family BatchNumber],''-''),''-'')) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number) = ''-'',-1,0)), [CorrectorDiffCount] = (DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY IIF(ac.CorrectorDiff IS NOT NULL AND ac.CorrectorDiff = ''Y'', ac.[Family BatchNumber],NULL) ASC) + DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY IIF(ac.CorrectorDiff IS NOT NULL AND ac.CorrectorDiff = ''Y'',ac.[Family BatchNumber],NULL) DESC) - 1 + IIF(MIN(IIF(ac.CorrectorDiff IS NOT NULL AND ac.CorrectorDiff = ''Y'', ISNULL(ac.[Family BatchNumber],''-''),''-'')) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number) = ''-'',-1,0))
	FROM Responsibility_CTE ac
	WHERE (ac.[Family Status] NOT IN (''A'', ''NF'') OR ac.[Family Status] IS NULL)
		AND LEFT(ac.ContentName, CHARINDEX(''-'', ac.ContentName)-1) IN ('+@VentureResponsibilityBatchContentCode+')' ELSE '' END)+'
)as_union'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @Query = N'SELECT DISTINCT cmsfp.CaseComposer, cmsfp.ContentName, cmsfp.LimitStatus, cmsfp.Type, cmsfp.Variation, [CaseCount] = COUNT(cmsfp.Id) OVER (PARTITION BY cmsfp.CaseComposer, cmsfp.ContentName, cmsfp.LimitStatus, cmsfp.Type, cmsfp.Variation)
INTO DeepSeaKingdom.WE.CaseComposingHonorEpitomeDetail
FROM DeepSeaKingdom.WE.CaseComposingScheduleForHonor cmsfp
WHERE cmsfp.PaidStatus = ''Paid'''
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @Query = N'WITH Responsibility_CTE AS (
SELECT DISTINCT cafp.Id, cafp.Corrector, cafp.ContentName, cafp.BrandName, cafp.Type, cafp.Number, [BatchNumber] = sag.BatchNumber, cafp.MemberNumber, cafp.Status, [HonorException] = IIF(pe.Id IS NULL, NULL, ''Exception''), [HasFile] = IIF(usaad.Id IS NULL, ''N'', ''Y''), cafp.CorrectorDiff
FROM DeepSeaKingdom.WE.VentureAppendixForHonor cafp
	LEFT JOIN DeepSeaKingdom.WE.FamilyResponsibilityBatch sag ON sag.FamilyNumber = cafp.MemberNumber
		AND sag.fContentOutlineId = cafp.ContentOutlineId
		AND sag.BrandName = cafp.BrandName
		AND sag.Number = cafp.Number
		AND sag.fQuarterSessionId = cafp.QuarterSessionId
		AND cafp.Type = ''Responsibility''
	LEFT JOIN (
		SELECT DISTINCT sag.BatchNumber, usaad.*
		FROM DeepSeaKingdom.WE.FamilyResponsibilityBatch sag 
			RIGHT JOIN DeepSeaKingdom.WE.UploadFamilyResponsibilityAnswerData usaad ON usaad.MemberId = sag.FamilyId
			AND usaad.ContentOutlineId = sag.fContentOutlineId
			AND LEFT(usaad.BrandName, CHARINDEX('' '',usaad.BrandName)-1) = sag.BrandName
			AND usaad.QuarterSessionId = sag.fQuarterSessionId
			AND usaad.ResponsibilityNumber = sag.Number	
	) usaad ON (usaad.BatchNumber = sag.BatchNumber OR usaad.MemberNumber = cafp.MemberNumber)
		AND usaad.ContentOutlineId = cafp.ContentOutlineId
		AND LEFT(usaad.BrandName, CHARINDEX('' '',usaad.BrandName)-1) = cafp.BrandName
		AND usaad.ResponsibilityNumber = cafp.Number
		AND usaad.QuarterSessionId = cafp.QuarterSessionId
		AND cafp.Type = ''Responsibility''
	LEFT JOIN DeepSeaKingdom.WE.V_HonorException pe ON pe.ContentOutlineId = cafp.ContentOutlineId
		AND pe.QuarterSessionId = cafp.QuarterSessionId
WHERE cafp.Type = ''Responsibility'')
,Venture_CTE AS (
SELECT DISTINCT cafp.Id, cafp.Corrector, cafp.ContentName, cafp.BrandName, cafp.Type, cafp.Number, [BatchNumber] = rsg.BatchNumber, cafp.MemberNumber, cafp.Status, [HonorException] = IIF(pe.Id IS NULL, NULL, ''Exception''), [HasFile] = IIF(uspad.Id IS NULL, ''N'', ''Y''), cafp.CorrectorDiff
FROM DeepSeaKingdom.WE.VentureAppendixForHonor cafp
	LEFT JOIN DeepSeaKingdom.WE.RealFamilyBatch rsg ON rsg.FamilyNumber = cafp.MemberNumber
		AND rsg.fContentOutlineId = cafp.ContentOutlineId
		AND rsg.fBrandName = cafp.BrandName
		AND cafp.Number = 1
		AND cafp.Type = ''Venture''
	LEFT JOIN DeepSeaKingdom.WE.UploadFamilyVentureAnswerData uspad ON (uspad.BatchNumber = rsg.BatchNumber OR uspad.People = cafp.MemberNumber)
		AND uspad.ContentOutlineId = cafp.ContentOutlineId
		AND RTRIM(LEFT(uspad.BrandName,5)) = cafp.BrandName
		AND cafp.Number = 1
		AND cafp.Type = ''Venture''
	LEFT JOIN DeepSeaKingdom.WE.V_HonorException pe ON pe.ContentOutlineId = cafp.ContentOutlineId
		AND pe.QuarterSessionId = cafp.QuarterSessionId
WHERE cafp.Type = ''Venture'')
,FinalTerm_CTE AS (
SELECT DISTINCT cafp.Id, cafp.Corrector, cafp.ContentName, cafp.BrandName, cafp.Type, cafp.Number, [BatchNumber] = NULL, cafp.MemberNumber, cafp.Status, [HonorException] = IIF(pe.Id IS NULL, NULL, ''Exception''), [HasFile] = IIF(usead.Id IS NULL, ''N'', ''Y''), cafp.CorrectorDiff
FROM DeepSeaKingdom.WE.VentureAppendixForHonor cafp
	LEFT JOIN DeepSeaKingdom.WE.UploadFamilyOnsiteTestAnswerData usead ON usead.MemberNumber = cafp.MemberNumber
		AND usead.ContentOutlineId = cafp.ContentOutlineId
		AND cafp.Number = 1
		AND cafp.Type = ''FinalTerm''
	LEFT JOIN DeepSeaKingdom.WE.V_HonorException pe ON pe.ContentOutlineId = cafp.ContentOutlineId
		AND pe.QuarterSessionId = cafp.QuarterSessionId
WHERE cafp.Type = ''FinalTerm'')
SELECT DISTINCT as_union.*, [Deviation] = IIF(as_union.FileCount<>as_union.HasFileCount, ABS(as_union.FileCount-as_union.HasFileCount), NULL), [FileProcessed] = ROUND(CONVERT(FLOAT, as_union.FileCount)*as_union.Weight,1), [HasFileProcessed] = ROUND(CONVERT(FLOAT, as_union.HasFileCount)*as_union.Weight,1), [DeviationProcessed] =  ROUND(CONVERT(FLOAT, IIF(as_union.FileCount<>as_union.HasFileCount, ABS(as_union.FileCount-as_union.HasFileCount), NULL))*as_union.Weight,1)
INTO DeepSeaKingdom.WE.VentureHonorAppendixEpitomeDetail
FROM (
	SELECT DISTINCT ftc.Corrector, ftc.ContentName, ftc.BrandName, ftc.Type, ftc.Number, [Weight] = '+@FinalTermWeight+', [FileCount] = COUNT(ftc.MemberNumber) OVER (PARTITION BY ftc.ContentName, ftc.BrandName, ftc.Type, ftc.Number), [HasFileCount] = COUNT(IIF(ftc.HasFile = ''Y'' OR ftc.[HonorException] IS NOT NULL,1,NULL)) OVER (PARTITION BY ftc.ContentName, ftc.BrandName, ftc.Type, ftc.Number), [CorrectorDiffCount] = COUNT(IIF(ftc.CorrectorDiff IS NOT NULL AND ftc.CorrectorDiff = ''Y'',1,NULL)) OVER (PARTITION BY ftc.ContentName, ftc.BrandName, ftc.Type, ftc.Number)
	FROM FinalTerm_CTE ftc
	WHERE (ftc.Status NOT IN (''A'', ''NF'') OR ftc.Status IS NULL)
	UNION
	SELECT DISTINCT pc.Corrector, pc.ContentName, pc.BrandName, pc.Type, pc.Number, [Weight] = '+@VentureWeight+', [FileCount] = (DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY pc.BatchNumber ASC) + DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY pc.BatchNumber DESC) - 1 + IIF(MIN(ISNULL(pc.BatchNumber,''-'')) OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number) = ''-'',-1,0)), [HasFileCount] = (DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY IIF(pc.HasFile = ''Y'' OR pc.[HonorException] IS NOT NULL, pc.BatchNumber,NULL) ASC) + DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY IIF(pc.HasFile = ''Y'' OR pc.[HonorException] IS NOT NULL,pc.BatchNumber,NULL) DESC) - 1 + IIF(MIN(IIF(pc.HasFile = ''Y'' OR pc.[HonorException] IS NOT NULL,ISNULL(pc.BatchNumber,''-''),''-'')) OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number) = ''-'',-1,0)), [CorrectorDiffCount] = (DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY IIF(pc.CorrectorDiff IS NOT NULL AND pc.CorrectorDiff = ''Y'', pc.BatchNumber,NULL) ASC) + DENSE_RANK() OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number ORDER BY IIF(pc.CorrectorDiff IS NOT NULL AND pc.CorrectorDiff = ''Y'',pc.BatchNumber,NULL) DESC) - 1 + IIF(MIN(IIF(pc.CorrectorDiff IS NOT NULL AND pc.CorrectorDiff = ''Y'',ISNULL(pc.BatchNumber,''-''),''-'')) OVER (PARTITION BY pc.ContentName, pc.BrandName, pc.Type, pc.Number) = ''-'',-1,0))
	FROM Venture_CTE pc
	WHERE (pc.Status NOT IN (''A'', ''NF'') OR pc.Status IS NULL)
	UNION
	SELECT DISTINCT ac.Corrector, ac.ContentName, ac.BrandName, ac.Type, ac.Number, [Weight] = '+@ResponsibilityWeight+', [FileCount] = COUNT(ac.MemberNumber) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number), [HasFileCount] = COUNT(IIF(ac.HasFile = ''Y'' OR ac.[HonorException] IS NOT NULL,1,NULL)) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number), [CorrectorDiffCount] = COUNT(IIF(ac.CorrectorDiff IS NOT NULL AND ac.CorrectorDiff = ''Y'',1,NULL)) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number)
	FROM Responsibility_CTE ac
	WHERE (ac.Status NOT IN (''A'', ''NF'') OR ac.Status IS NULL)'+
	(CASE WHEN @VentureResponsibilityBatchContentCode IS NOT NULL AND @VentureResponsibilityBatchContentCode <> '' THEN
	'	AND LEFT(ac.ContentName, CHARINDEX(''-'', ac.ContentName)-1) NOT IN ('+@VentureResponsibilityBatchContentCode+')
	UNION
	SELECT DISTINCT ac.Corrector, ac.ContentName, ac.BrandName, ac.Type, ac.Number, [Weight] = '+@ResponsibilityWeight+', [FileCount] = (DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY ac.BatchNumber ASC) + DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY ac.BatchNumber DESC) - 1 + IIF(MIN(ISNULL(ac.BatchNumber,''-'')) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number) = ''-'',-1,0)), [HasFileCount] = (DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY IIF(ac.HasFile = ''Y'' OR ac.[HonorException] IS NOT NULL, ac.BatchNumber,NULL) ASC) + DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY IIF(ac.HasFile = ''Y'' OR ac.[HonorException] IS NOT NULL,ac.BatchNumber,NULL) DESC) - 1 + IIF(MIN(IIF(ac.HasFile = ''Y'' OR ac.[HonorException] IS NOT NULL, ISNULL(ac.BatchNumber,''-''),''-'')) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number) = ''-'',-1,0)), [CorrectorDiffCount] = (DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY IIF(ac.CorrectorDiff IS NOT NULL AND ac.CorrectorDiff = ''Y'', ac.BatchNumber,NULL) ASC) + DENSE_RANK() OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number ORDER BY IIF(ac.CorrectorDiff IS NOT NULL AND ac.CorrectorDiff = ''Y'',ac.BatchNumber,NULL) DESC) - 1 + IIF(MIN(IIF(ac.CorrectorDiff IS NOT NULL AND ac.CorrectorDiff = ''Y'', ISNULL(ac.BatchNumber,''-''),''-'')) OVER (PARTITION BY ac.ContentName, ac.BrandName, ac.Type, ac.Number) = ''-'',-1,0))
	FROM Responsibility_CTE ac
	WHERE (ac.Status NOT IN (''A'', ''NF'') OR ac.Status IS NULL)
		AND LEFT(ac.ContentName, CHARINDEX(''-'', ac.ContentName)-1) IN ('+@VentureResponsibilityBatchContentCode+')' ELSE '' END)+'
)as_union'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @Query = N'SELECT DISTINCT [Corrector] = UPPER(pvt.Corrector), [TotalPaid] = IIF(CEILING(ISNULL(pvt.[FinalTerm],0)+ISNULL(pvt.[Venture],0)+ISNULL(pvt.[Responsibility],0)+ISNULL(pvt.[FinalTerm Appendix],0)+ISNULL(pvt.[Venture Appendix],0)+ISNULL(pvt.[Responsibility Appendix],0)) < 0, 0, CEILING(ISNULL(pvt.[FinalTerm],0)+ISNULL(pvt.[Venture],0)+ISNULL(pvt.[Responsibility],0)+ISNULL(pvt.[FinalTerm Appendix],0)+ISNULL(pvt.[Venture Appendix],0)+ISNULL(pvt.[Responsibility Appendix],0))), [FinalTerm] = ISNULL(pvt.[FinalTerm],0), [Venture] = ISNULL(pvt.[Venture],0), [Responsibility] = ISNULL(pvt.[Responsibility],0), [FinalTerm Appendix] = ISNULL(pvt.[FinalTerm Appendix],0), [Venture Appendix] = ISNULL(pvt.[Venture Appendix],0), [Responsibility Appendix] = ISNULL(pvt.[Responsibility Appendix],0)
INTO DeepSeaKingdom.WE.VentureHonorEpitomeSummary
FROM 
(SELECT DISTINCT chrd.Corrector, chrd.Type
	,[Processed] = 
	--SUM(chrd.FileProcessed) OVER (PARTITION BY chrd.Corrector, chrd.Type)
	SUM(chrd.HasFileProcessed) OVER (PARTITION BY chrd.Corrector, chrd.Type)
	--SUM(chrd.DeviationProcessed) OVER (PARTITION BY chrd.Corrector, chrd.Type)
FROM DeepSeaKingdom.WE.VentureHonorEpitomeDetail chrd
UNION
SELECT DISTINCT chard.Corrector, chard.Type+'' Appendix''
	,[Processed] = 
		SUM(chard.FileProcessed) OVER (PARTITION BY chard.Corrector, chard.Type)
	--SUM(chard.HasFileProcessed) OVER (PARTITION BY chard.Corrector, chard.Type)
	--SUM(chard.DeviationProcessed) OVER (PARTITION BY chard.Corrector, chard.Type)
FROM DeepSeaKingdom.WE.VentureHonorAppendixEpitomeDetail chard) p
PIVOT (MAX(p.[Processed]) FOR p.[Type] IN ([Responsibility],[Venture],[FinalTerm],[Responsibility Appendix],[Venture Appendix],[FinalTerm Appendix])) AS pvt'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @Query = N'SELECT DISTINCT CaseComposer = UPPER(pvt.CaseComposer), [Total] = ISNULL(pvt.[FinalTerm],0)+ISNULL(pvt.[Venture],0)+ISNULL(pvt.[Responsibility],0), [FinalTerm] = ISNULL(pvt.[FinalTerm],0), [Venture] = ISNULL(pvt.[Venture],0), [Responsibility] = ISNULL(pvt.[Responsibility],0)
INTO DeepSeaKingdom.WE.CaseComposingHonorEpitomeSummary
FROM 
(SELECT DISTINCT cmhrd.CaseComposer, [Type] = cmhrd.Type, [CaseCount] = SUM(cmhrd.CaseCount) OVER (PARTITION BY cmhrd.CaseComposer, cmhrd.Type)
FROM DeepSeaKingdom.WE.CaseComposingHonorEpitomeDetail cmhrd) p
PIVOT (MAX(p.[CaseCount]) FOR p.[Type] IN ([Responsibility],[Venture],[FinalTerm])) AS pvt'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END