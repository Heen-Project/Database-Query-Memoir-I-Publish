USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateFamilyMarkSummaryGalaxy] (
    @Term NVARCHAR(MAX) = N''
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
IF OBJECT_ID('tempdb.dbo.#AssesmentIngredient', 'U') IS NOT NULL DROP TABLE #AssesmentIngredient;
IF OBJECT_ID('tempdb.dbo.#FamilyMark', 'U') IS NOT NULL DROP TABLE #FamilyMark;
IF OBJECT_ID('tempdb.dbo.#MarkSummary', 'U') IS NOT NULL DROP TABLE #MarkSummary;
IF OBJECT_ID('tempdb.dbo.#FamilyMarkSummary', 'U') IS NOT NULL DROP TABLE #FamilyMarkSummary;
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
    ,[Responsibility] = CASE WHEN ec.Responsibility > 0.00 THEN ''N/A'' ELSE ''-'' END
    ,[Venture] = CASE WHEN ec.Venture > 0.00 THEN ''N/A'' ELSE ''-'' END
    ,[MidTerm] = CASE WHEN ec.MidTerm > 0.00 THEN ''N/A'' ELSE ''-'' END
    ,[FinalTerm] = CASE WHEN ec.FinalTerm > 0.00 THEN ''N/A'' ELSE ''-'' END
    ,[TotalMark] = CASE WHEN ec.Responsibility > 0.00 OR ec.Venture > 0.00 OR ec.MidTerm > 0.00 OR ec.FinalTerm > 0.00 THEN ''N/A'' ELSE ''-'' END
    ,[MemberId] = mess.MemberId
    ,[QuarterSessionId] = mess.QuarterSessionId
    ,[ContentOutlineId] = mess.ContentOutlineId
INTO ##FamilyMarkSummary
FROM OPENQUERY('+@LinkedServer+','''+replace(@OpenQuery,'''','''''')+''') mess
    JOIN (
        SELECT DISTINCT pvt_AssesmentIngredient.QuarterSessionId, pvt_AssesmentIngredient.ContentOutlineId, [Responsibility] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.Responsibility,0.00)), [Venture] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.Venture,0.00)), [MidTerm] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.MidTerm,0.00)), [FinalTerm] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.FinalTerm,0.00))
        FROM (SELECT DISTINCT ec.QuarterSessionId, ec.ContentOutlineId, ec.[Type], ec.Percentage FROM #AssesmentIngredient ec) SourceTable PIVOT (MAX(Percentage) FOR Type IN ([Responsibility],[Venture],[MidTerm],[FinalTerm])) AS pvt_AssesmentIngredient
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
SELECT * INTO #FamilyMarkSummary FROM ##FamilyMarkSummary
;------------------------------
DROP TABLE ##FamilyMarkSummary
;----------------------------------------------------------------------
;WITH FamilyMark_CTE AS (
    SELECT DISTINCT pvt_FamilyMark.BrandBusinessId, pvt_FamilyMark.MemberId, pvt_FamilyMark.QuarterSessionId, pvt_FamilyMark.ContentOutlineId, pvt_FamilyMark.BrandName, [Responsibility] = MAX(pvt_FamilyMark.Responsibility), [Venture] = MAX(pvt_FamilyMark.Venture), [MidTerm] = MAX(pvt_FamilyMark.MidTerm), [FinalTerm] = MAX(pvt_FamilyMark.FinalTerm), [OldResponsibility] = MAX(pvt_FamilyMark.OldResponsibility), [OldVenture] = MAX(pvt_FamilyMark.OldVenture), [OldMidTerm] = MAX(pvt_FamilyMark.OldMidTerm), [OldFinalTerm] = MAX(pvt_FamilyMark.OldFinalTerm)
    FROM (
    SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, ss.Type, [Summary] = (CASE WHEN COUNT(ss.MemberId) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type) = ec.Count THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2),CEILING(SUM((CONVERT(NUMERIC(10,2),ISNULL(ss.Mark,0.00)) * CONVERT(NUMERIC(10,2), ec.DetailPercentage))/100.00) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type)))) ELSE 'N/A' END),[OldSummary] = (CASE WHEN COUNT(ss.MemberId) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type) = ec.Count THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2),SUM((CONVERT(NUMERIC(10,2),ISNULL(ss.Mark,0.00)) * CONVERT(NUMERIC(10,2), ec.DetailPercentage))/100.00) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type))) ELSE 'N/A' END), [OldType] = 'Old'+ss.Type
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
SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, [Responsibility] = ISNULL(ss.Responsibility, '?'), [Venture] = ISNULL(ss.Venture,'?'), [MidTerm] = ISNULL(ss.MidTerm,'?'), [FinalTerm] = ISNULL(ss.FinalTerm,'?'), [TotalMark] = CONVERT(VARCHAR,CEILING(((CASE WHEN ec.[IngredientDetailPercentage10000] LIKE '%Responsibility%' AND ISNUMERIC(ss.OldResponsibility) = 1
    THEN (CEILING(ISNULL(CONVERT(NUMERIC(10,2),ss.OldResponsibility),0.00))*ec.Responsibility) WHEN ISNUMERIC(ss.OldResponsibility) = 1 THEN (ISNULL(CONVERT(NUMERIC(10,2),ss.OldResponsibility),0.00)*ec.Responsibility) ELSE 0 END)
+(CASE WHEN ec.IngredientDetailPercentage10000 LIKE '%Venture%' AND ISNUMERIC(ss.OldVenture) = 1
    THEN (CEILING(ISNULL(CONVERT(NUMERIC(10,2),ss.OldVenture),0.00))*ec.Venture) WHEN ISNUMERIC(ss.OldVenture) = 1 THEN (ISNULL(CONVERT(NUMERIC(10,2),ss.OldVenture),0.00)*ec.Venture) ELSE 0 END)
+(CASE WHEN ec.IngredientDetailPercentage10000 LIKE '%MidTerm%' AND ISNUMERIC(ss.OldMidTerm) = 1
    THEN (CEILING(ISNULL(CONVERT(NUMERIC(10,2),ss.OldMidTerm),0.00))*ec.MidTerm) WHEN ISNUMERIC(ss.OldMidTerm) = 1 THEN (ISNULL(CONVERT(NUMERIC(10,2),ss.OldMidTerm),0.00)*ec.MidTerm) ELSE 0 END)
+(CASE WHEN ec.IngredientDetailPercentage10000 LIKE '%FinalTerm%' AND ISNUMERIC(ss.OldFinalTerm) = 1
    THEN (CEILING(ISNULL(CONVERT(NUMERIC(10,2),ss.OldFinalTerm),0.00))*ec.FinalTerm) WHEN ISNUMERIC(ss.OldFinalTerm) = 1 THEN (ISNULL(CONVERT(NUMERIC(10,2),ss.OldFinalTerm),0.00)*ec.FinalTerm) ELSE 0 END))/100.00))
INTO #MarkSummary
FROM FamilyMark_CTE ss
    JOIN AssesmentIngredient_CTE ec ON ec.QuarterSessionId = ss.QuarterSessionId
        AND ec.ContentOutlineId = ss.ContentOutlineId
;----------------------------------------------------------------------
ALTER TABLE #FamilyMarkSummary  ALTER COLUMN Responsibility NVARCHAR(MAX)
;----------------------------------------------------------------------
ALTER TABLE #FamilyMarkSummary  ALTER COLUMN Venture NVARCHAR(MAX)
;----------------------------------------------------------------------
ALTER TABLE #FamilyMarkSummary  ALTER COLUMN MidTerm NVARCHAR(MAX)
;----------------------------------------------------------------------
ALTER TABLE #FamilyMarkSummary  ALTER COLUMN FinalTerm NVARCHAR(MAX)
;----------------------------------------------------------------------
ALTER TABLE #FamilyMarkSummary  ALTER COLUMN TotalMark NVARCHAR(MAX)
;----------------------------------------------------------------------
UPDATE summary 
SET summary.Responsibility = (CASE WHEN summary.Responsibility <> '-' THEN IIF(ISNUMERIC(Mark.Responsibility)= 1, Mark.Responsibility, summary.Responsibility) ELSE summary.Responsibility END)
    ,summary.Venture = (CASE WHEN summary.Venture <> '-' THEN IIF(ISNUMERIC(Mark.Venture)= 1, Mark.Venture, summary.Venture) ELSE summary.Venture END)
    ,summary.MidTerm = (CASE WHEN summary.MidTerm <> '-' THEN IIF(ISNUMERIC(Mark.MidTerm)= 1, Mark.MidTerm, summary.MidTerm) ELSE summary.MidTerm END)
    ,summary.FinalTerm = (CASE WHEN summary.FinalTerm <> '-' THEN IIF(ISNUMERIC(Mark.FinalTerm)= 1, Mark.FinalTerm, summary.FinalTerm) ELSE summary.FinalTerm END)
    ,summary.TotalMark = Mark.TotalMark
FROM #FamilyMarkSummary summary
    JOIN #MarkSummary Mark ON summary.MemberId = Mark.MemberId
        AND summary.QuarterSessionId = Mark.QuarterSessionId
        AND summary.ContentOutlineId = Mark.ContentOutlineId
        AND summary.BrandName = Mark.BrandName
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.FamilyMarkSummary', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.FamilyMarkSummary;
;------------------------------
SELECT DISTINCT  [Term] = @Term, [QuarterSessionId] = @QuarterSessionId, [House], [WorkshopName], [ContentOutline], [TopicName], [AssociateCode], [AssociateName], [MemberNumber], [MemberName], [BrandName]
, [Responsibility] = (CASE WHEN ISNUMERIC([Responsibility]) = 1 AND [Responsibility] <> '-' THEN CONVERT(VARCHAR,CONVERT(INT,CONVERT(NUMERIC(10,2),[Responsibility]))) ELSE [Responsibility] END)
, [Venture] = (CASE WHEN ISNUMERIC([Venture]) = 1 AND [Venture] <> '-' THEN CONVERT(VARCHAR,CONVERT(INT,CONVERT(NUMERIC(10,2),[Venture]))) ELSE [Venture] END)
, [MidTerm] = (CASE WHEN ISNUMERIC([MidTerm]) = 1 AND [MidTerm] <> '-' THEN CONVERT(VARCHAR,CONVERT(INT,CONVERT(NUMERIC(10,2),[MidTerm]))) ELSE [MidTerm] END)
, [FinalTerm] = (CASE WHEN ISNUMERIC([FinalTerm]) = 1 AND [FinalTerm] <> '-' THEN CONVERT(VARCHAR,CONVERT(INT,CONVERT(NUMERIC(10,2),[FinalTerm]))) ELSE [FinalTerm] END)
, [TotalMark] = IIF([Responsibility]='N/A' OR [Venture]='N/A' OR [MidTerm]='N/A' OR [FinalTerm]='N/A', 'N/A', [TotalMark])
INTO DeepSeaKingdom.WE.FamilyMarkSummary 
FROM #FamilyMarkSummary
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