USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateAssistantFamilyPassingPercentage] (
	@Term NVARCHAR(MAX) = N''
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
	,@ExcludeMemberXXX NVARCHAR(MAX) = N''
	,@ExcludeMemberXXXTopicCodeBrandName NVARCHAR(MAX) = N''
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
IF OBJECT_ID('DeepSeaKingdom.WE.AssistantFamilyMark', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.AssistantFamilyMark;
IF OBJECT_ID('DeepSeaKingdom.WE.AssistantFamilyPassingPercentage', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.AssistantFamilyPassingPercentage;
IF OBJECT_ID('tempdb.dbo.#AssesmentIngredient', 'U') IS NOT NULL DROP TABLE #AssesmentIngredient;
;----------------------------------------------------------------------
SELECT * 
INTO #AssesmentIngredient 
FROM DeepSeaKingdom.WE.UDFTV_AssesmentIngredientVerticalDetail(@QuarterSessionId) ec
;----------------------------------------------------------------------
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @Query NVARCHAR(MAX), @SubqueryLEC NVARCHAR(MAX), @SubqueryLAB NVARCHAR(MAX) ,@LinkedServer2 NVARCHAR(MAX), @OpenQuery2 NVARCHAR(MAX), @Department NVARCHAR(MAX), @AcadCareer NVARCHAR(MAX), @ColumnStatusFinalTermOr NVARCHAR(MAX), @ColumnStatusMidTermOr NVARCHAR(MAX), @ColumnStatusVentureOr NVARCHAR(MAX), @ColumnStatusResponsibilityOr NVARCHAR(MAX), @ColumnStatusFinalTermAnd NVARCHAR(MAX), @ColumnStatusMidTermAnd NVARCHAR(MAX), @ColumnStatusVentureAnd NVARCHAR(MAX), @ColumnStatusResponsibilityAnd NVARCHAR(MAX), @ColumnStatusVentureCheating NVARCHAR(MAX)
;----------------------------------------------------------------------
SET @LinkedServer = N'[LocalDB]'
SET @LinkedServer2 = N'[OPRO]'
SET @Department = N'YYS01'
SET @AcadCareer = N'RS1'
;------------------------------
SELECT @ColumnStatusFinalTermOr = STUFF((SELECT DISTINCT 'OR (detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] NOT IN (''A'',''C'',''NF'') OR detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] IS NULL) ' FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.ContentOutlineId = Assesment.ContentOutlineId AND Topics.WorkshopId LIKE '%'+@WorkshopId+'%') ec WHERE ec.Type = 'FinalTerm' FOR XML PATH('')),1,3,'')
;------------------------------
SELECT @ColumnStatusMidTermOr = STUFF((SELECT DISTINCT 'OR (detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] NOT IN (''A'',''C'',''NF'') OR detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] IS NULL) ' FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.ContentOutlineId = Assesment.ContentOutlineId AND Topics.WorkshopId LIKE '%'+@WorkshopId+'%') ec WHERE ec.Type = 'MidTerm' FOR XML PATH('')),1,3,'')
;------------------------------
SELECT @ColumnStatusVentureOr = STUFF((SELECT DISTINCT 'OR (detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] NOT IN (''A'',''C'',''NF'') OR detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] IS NULL) ' FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.ContentOutlineId = Assesment.ContentOutlineId AND Topics.WorkshopId LIKE '%'+@WorkshopId+'%') ec WHERE ec.Type = 'Venture' FOR XML PATH('')),1,3,'')
;------------------------------
SELECT @ColumnStatusResponsibilityOr = STUFF((SELECT DISTINCT 'OR (detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] NOT IN (''A'',''C'',''NF'') OR detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] IS NULL) '  FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.ContentOutlineId = Assesment.ContentOutlineId AND Topics.WorkshopId LIKE '%'+@WorkshopId+'%') ec WHERE ec.Type = 'Responsibility' FOR XML PATH('')),1,3,'')
;------------------------------
SELECT @ColumnStatusFinalTermAnd = STUFF((SELECT DISTINCT 'AND (detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] NOT IN (''A'',''C'',''NF'') OR detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] IS NULL) ' FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.ContentOutlineId = Assesment.ContentOutlineId AND Topics.WorkshopId LIKE '%'+@WorkshopId+'%') ec WHERE ec.Type = 'FinalTerm' FOR XML PATH('')),1,4,'')
;------------------------------
SELECT @ColumnStatusMidTermAnd = STUFF((SELECT DISTINCT 'AND (detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] NOT IN (''A'',''C'',''NF'') OR detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] IS NULL) ' FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.ContentOutlineId = Assesment.ContentOutlineId AND Topics.WorkshopId LIKE '%'+@WorkshopId+'%') ec WHERE ec.Type = 'MidTerm' FOR XML PATH('')),1,4,'')
;------------------------------
SELECT @ColumnStatusVentureAnd = STUFF((SELECT DISTINCT 'AND (detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] NOT IN (''A'',''C'',''NF'') OR detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] IS NULL) ' FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.ContentOutlineId = Assesment.ContentOutlineId AND Topics.WorkshopId LIKE '%'+@WorkshopId+'%') ec WHERE ec.Type = 'Venture' FOR XML PATH('')),1,4,'')
;------------------------------
SELECT @ColumnStatusResponsibilityAnd = STUFF((SELECT DISTINCT 'AND (detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] NOT IN (''A'',''C'',''NF'') OR detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] IS NULL) '  FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.ContentOutlineId = Assesment.ContentOutlineId AND Topics.WorkshopId LIKE '%'+@WorkshopId+'%') ec WHERE ec.Type = 'Responsibility' FOR XML PATH('')),1,4,'')
;------------------------------
SELECT @ColumnStatusVentureCheating = STUFF((SELECT DISTINCT 'AND (detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] NOT IN (''C'') OR detail.[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+'] IS NULL) ' FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.ContentOutlineId = Assesment.ContentOutlineId AND Topics.WorkshopId LIKE '%'+@WorkshopId+'%') ec WHERE ec.Type = 'Venture' FOR XML PATH('')),1,4,'')
;------------------------------
SELECT @SubqueryLAB = STUFF((SELECT DISTINCT ','''+sr.ContentCode+''''
	FROM DeepSeaKingdom.dbo.SessionRule sr 
	WHERE sr.MarkManaged = 'Y' 
		AND sr.QuarterSessionId LIKE '%'+@QuarterSessionId+'%' 
		AND sr.Ingredient = 'LAB'
    FOR XML PATH('')), 1, 1, '')
;------------------------------
SELECT @SubqueryLEC = STUFF((SELECT DISTINCT ','''+sr.ContentCode+''''
	FROM DeepSeaKingdom.dbo.SessionRule sr 
	WHERE sr.MarkManaged = 'Y' 
		AND sr.QuarterSessionId LIKE '%'+@QuarterSessionId+'%' 
		AND sr.Ingredient = 'LEC'
    FOR XML PATH('')), 1, 1, '')
;------------------------------
SET @OpenQuery = N'SELECT DISTINCT ct.BrandBusinessId, ct.BrandName, ct.QuarterSessionId, ct.Note, ct.AssociateCode, ct.AssociateName, Topics.TopicId, Topics.Name [TopicName], Topics.DepartmentId, cts.BrandBusinessFamilyId, bFamilyXXX.MemberId, bFamilyXXX.Number [MemberNumber], bFamilyXXX.Name [MemberName], lab.WorkshopId, lab.Name [WorkshopName], co.ContentOutlineId, co.SessionRuleId, co.Name [ContentName], nm.PersonId, nm.PersonName
	FROM Galaxy.dbo.BrandBusinesss ct 
		JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
			AND ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
			AND Topics.WorkshopId LIKE ''%'+@WorkshopId+'%''
			AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
		JOIN Galaxy.dbo.BrandBusinessFamilys cts ON cts.BrandBusinessId = ct.BrandBusinessId
			AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedBrandBusinessFamilys dcts WHERE dcts.BrandBusinessFamilyId = cts.BrandBusinessFamilyId AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = dcts.DeletedBrandBusinessFamilyId))
		JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
		JOIN Galaxy.dbo.Workshops lab ON lab.WorkshopId = Topics.WorkshopId
			AND ((LEFT(co.Name,CHARINDEX(''-'',co.Name)-1) IN ('+@SubqueryLAB+') AND RTRIM(LEFT(ct.BrandName,5)) NOT LIKE ''L%'')
			OR (LEFT(co.Name,CHARINDEX(''-'',co.Name)-1) IN ('+@SubqueryLEC+') AND RTRIM(LEFT(ct.BrandName,5)) LIKE ''L%''))
		JOIN Galaxy.dbo.Members bFamilyXXX ON bFamilyXXX.MemberId = cts.MemberId
		JOIN Galaxy.dbo.BrandBusinessAssistants cta ON cta.BrandBusinessId = ct.BrandBusinessId
		JOIN Galaxy.dbo.NameBranchs nm ON nm.PersonId = cta.PersonId'
;------------------------------
SET @OpenQuery2 = N'SELECT * FROM SYSADM.PS_N_SF_OUTSTAND o WHERE o.Department = '''+@Department+''' AND o.Position = '''+@AcadCareer+''' AND o.ITEM_TERM = '''+@Term+''''
;------------------------------
SET @Query = N'SELECT DISTINCT [Personname] = mess.Personname
	,[ContentName] = summary.ContentOutline
	,[TopicName] = summary.TopicName
	,[BrandName] = summary.BrandName
	,[MemberNumber] = mess.MemberNumber
	,[FinalMark] = summary.TotalMark
INTO DeepSeaKingdom.WE.AssistantFamilyMark
FROM OPENQUERY('+@LinkedServer+','''+replace(@OpenQuery,'''','''''')+''') mess
	LEFT JOIN DeepSeaKingdom.WE.UDFTV_AssesmentIngredientHorizontal('''+@QuarterSessionId+''') ec ON ec.ContentOutlineId = mess.ContentOutlineId
		AND ec.ContentOutlineId = mess.ContentOutlineId
		AND ec.QuarterSessionId = mess.QuarterSessionId
	RIGHT JOIN DeepSeaKingdom.WE.FamilyMarkSummary summary ON summary.MemberNumber = mess.MemberNumber
		AND LEFT(summary.TopicName, CHARINDEX(''-'',summary.TopicName)-1) = LEFT(mess.TopicName, CHARINDEX(''-'',mess.TopicName)-1)
		AND LEFT(summary.ContentOutline, CHARINDEX(''-'',summary.ContentOutline)-1) = LEFT(mess.ContentName, CHARINDEX(''-'',mess.ContentName)-1)
		AND summary.BrandName = RTRIM(LEFT(mess.BrandName,5))
		AND summary.Term = '''+@Term+'''
	JOIN DeepSeaKingdom.WE.FamilyMarkDetail detail ON detail.MemberNumber = summary.MemberNumber
		AND LEFT(detail.TopicName, CHARINDEX(''-'',detail.TopicName)-1) = LEFT(summary.TopicName, CHARINDEX(''-'',summary.TopicName)-1)
		AND detail.BrandName = summary.BrandName
		AND detail.Term = summary.Term
		AND mess.WorkshopId = '''+@WorkshopId+'''
		AND mess.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
		'+CASE WHEN @ColumnStatusFinalTermOr IS NOT NULL OR @ColumnStatusMidTermOr IS NOT NULL OR @ColumnStatusVentureOr IS NOT NULL OR @ColumnStatusResponsibilityOr IS NOT NULL OR @ColumnStatusFinalTermAnd IS NOT NULL OR @ColumnStatusMidTermAnd IS NOT NULL OR @ColumnStatusVentureAnd IS NOT NULL OR @ColumnStatusResponsibilityAnd IS NOT NULL THEN 'AND (CASE 
			'+CASE WHEN (@ColumnStatusFinalTermAnd IS NOT NULL) THEN 'WHEN ec.FinalTerm >= 100 THEN (SELECT (CASE WHEN '+@ColumnStatusFinalTermAnd+' THEN 1 ELSE 0 END))' ELSE  '' END+'
			'+CASE WHEN (@ColumnStatusMidTermAnd IS NOT NULL) THEN 'WHEN ec.MidTerm >= 100 THEN (SELECT (CASE WHEN '+@ColumnStatusMidTermAnd+' THEN 1 ELSE 0 END))' ELSE  '' END+'
			'+CASE WHEN (@ColumnStatusVentureAnd IS NOT NULL) THEN 'WHEN ec.Venture >= 100 THEN (SELECT (CASE WHEN '+@ColumnStatusVentureAnd+' THEN 1 ELSE 0 END))' ELSE  '' END+'
			'+CASE WHEN (@ColumnStatusResponsibilityAnd IS NOT NULL) THEN 'WHEN ec.Responsibility >= 100 THEN (SELECT (CASE WHEN '+@ColumnStatusResponsibilityAnd+' THEN 1 ELSE 0 END))' ELSE  '' END+'
			'+CASE WHEN (@ColumnStatusFinalTermOr IS NOT NULL) THEN 'WHEN ec.FinalTerm > ec.MidTerm AND ec.FinalTerm > ec.Venture AND ec.FinalTerm > ec.Responsibility THEN (SELECT (CASE WHEN '+@ColumnStatusFinalTermOr+' THEN 1 ELSE 0 END))' ELSE  '' END+'
			'+CASE WHEN (@ColumnStatusMidTermOr IS NOT NULL) THEN 'WHEN ec.MidTerm > ec.Venture AND ec.MidTerm > ec.Responsibility THEN (SELECT (CASE WHEN '+@ColumnStatusMidTermOr+' THEN 1 ELSE 0 END))' ELSE  '' END+'
			'+CASE WHEN (@ColumnStatusVentureOr IS NOT NULL) THEN 'WHEN ec.Venture > ec.Responsibility THEN (SELECT (CASE WHEN '+@ColumnStatusVentureOr+' THEN 1 ELSE 0 END))' ELSE  '' END+'
			'+CASE WHEN (@ColumnStatusResponsibilityOr IS NOT NULL) THEN 'WHEN ec.Responsibility > 0 THEN (SELECT (CASE WHEN '+@ColumnStatusResponsibilityOr+' THEN 1 ELSE 0 END))' ELSE  '' END+'
		END) = 1' ELSE '' END+'
		'+CASE WHEN @ColumnStatusVentureCheating IS NOT NULL THEN 'AND (CASE 
			'+CASE WHEN (@ColumnStatusVentureCheating IS NOT NULL) THEN 'WHEN ec.Venture > 0 THEN (SELECT (CASE WHEN '+@ColumnStatusVentureCheating+' THEN 1 ELSE 0 END)) ELSE 1' ELSE  '' END+'
		END) = 1' ELSE '' END+'
		AND (ec.FinalTerm > 0 OR ec.MidTerm > 0 OR ec.Venture > 0 OR ec.Responsibility > 0)
		AND NOT EXISTS(SELECT NULL FROM DeepSeaKingdom.WE.[UDFTV_FamilyZeroingPracticumHistory]('''+@QuarterSessionId+''') szph WHERE szph.SummaryFamilyNumber+LEFT(szph.SummaryTopic, CHARINDEX(''-'',szph.SummaryTopic)-1)+szph.SummaryBrandName = summary.MemberNumber+LEFT(summary.TopicName, CHARINDEX(''-'',summary.TopicName)-1)+summary.BrandName)
		AND NOT EXISTS(SELECT NULL FROM DeepSeaKingdom.WE.[UDFTV_FamilyZeroingTheoryHistory]('''+@QuarterSessionId+''') szth WHERE szth.SummaryFamilyNumber+LEFT(szth.SummaryTopic, CHARINDEX(''-'',szth.SummaryTopic)-1)+szth.SummaryBrandName = summary.MemberNumber+LEFT(summary.TopicName, CHARINDEX(''-'',summary.TopicName)-1)+summary.BrandName)
		AND NOT EXISTS(SELECT NULL FROM OPENQUERY('+@LinkedServer2+','''+replace(@OpenQuery2,'''','''''')+''') o WHERE o.EXTERNAL_SYSTEM_ID = summary.MemberNumber)'
		+CASE WHEN @ExcludeMemberXXX IS NOT NULL AND @ExcludeMemberXXX <> '' THEN '
		AND summary.MemberNumber NOT IN('+@ExcludeMemberXXX+')' ELSE '' END 
		+CASE WHEN @ExcludeMemberXXXTopicCodeBrandName IS NOT NULL AND @ExcludeMemberXXXTopicCodeBrandName <> '' THEN '
		AND summary.MemberNumber+LEFT(summary.TopicName, CHARINDEX(''-'',summary.TopicName)-1)+summary.BrandName NOT IN('+@ExcludeMemberXXXTopicCodeBrandName+')' ELSE '' END 
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
EXECUTE ('DELETE ass FROM DeepSeaKingdom.WE.AssistantFamilyMark ass 
WHERE EXISTS (SELECT NULL FROM DeepSeaKingdom.WE.FamilyPresenceSummary sas LEFT JOIN DeepSeaKingdom.WE.V_PresenceLimit al ON sas.ContentOutlineId = al.ContentOutlineId AND sas.QuarterSessionId = al.QuarterSessionId WHERE /*CASE WHEN sas.MeetingCount-ISNULL(al.MaximumAbsence,IIF(sas.MeetingCount>6,2,1))>sas.TotalPresent THEN ''INELIGIBLE'' ELSE ''ELIGIBLE'' END = ''INELIGIBLE''*/ CASE WHEN sas.TotalAbsent>ISNULL(al.MaximumAbsence,IIF(sas.MeetingCount>6,2,1)) THEN ''INELIGIBLE'' ELSE ''ELIGIBLE'' END = ''INELIGIBLE'' AND sas.MemberNumber+LEFT(sas.TopicName, CHARINDEX(''-'',sas.TopicName)-1)+sas.BrandName = ass.MemberNumber+LEFT(ass.TopicName, CHARINDEX(''-'',ass.TopicName)-1)+ass.BrandName)')
;----------------------------------------------------------------------
EXECUTE ('WITH Eligible_Passed_Family_CTE AS (SELECT DISTINCT [PersonName] = ass.PersonName
	,[Eligible Family >= 65] = COUNT(ass.MemberNumber) OVER (PARTITION BY ass.PersonName)
FROM DeepSeaKingdom.WE.AssistantFamilyMark ass
WHERE ass.FinalMark >= 65
),
Eligible_Family_CTE AS (SELECT DISTINCT [PersonName] = ass.PersonName
	,[Eligible Family] = COUNT(ass.MemberNumber) OVER (PARTITION BY ass.PersonName)
FROM DeepSeaKingdom.WE.AssistantFamilyMark ass
)
SELECT DISTINCT [PersonName] = Eligible_Family_CTE.[PersonName]
	,[Family Mark >=65] = CASE WHEN Eligible_Passed_Family_CTE.[Eligible Family >= 65] IS NULL THEN 0 ELSE Eligible_Passed_Family_CTE.[Eligible Family >= 65] END
	,[Eligible Family] = CASE WHEN Eligible_Family_CTE.[Eligible Family] IS NULL THEN 0 ELSE Eligible_Family_CTE.[Eligible Family] END
	,[Passed Percentage] = CAST(CAST(CAST((CASE WHEN Eligible_Passed_Family_CTE.[Eligible Family >= 65] IS NULL THEN 0 ELSE Eligible_Passed_Family_CTE.[Eligible Family >= 65] END) AS numeric(12,2))/CAST((CASE WHEN Eligible_Family_CTE.[Eligible Family] IS NULL THEN 0 ELSE Eligible_Family_CTE.[Eligible Family] END) AS numeric(12,2)) * 100 AS numeric(10,2)) AS varchar)+''%''
INTO DeepSeaKingdom.WE.AssistantFamilyPassingPercentage
FROM Eligible_Family_CTE
	LEFT JOIN Eligible_Passed_Family_CTE ON Eligible_Passed_Family_CTE.[PersonName] = Eligible_Family_CTE.[PersonName]')
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