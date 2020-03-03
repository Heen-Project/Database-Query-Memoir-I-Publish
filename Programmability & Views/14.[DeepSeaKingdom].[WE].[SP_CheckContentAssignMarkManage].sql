USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_CheckContentAssignMarkManage] (
	@WorkshopName NVARCHAR(MAX) = N''
	,@Term NVARCHAR(MAX) = N''
	,@LamType NVARCHAR(MAX) = N''
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
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @Query NVARCHAR(MAX), @Department NVARCHAR(MAX), @AcadCareer NVARCHAR(MAX), @LovelySiteIngredient NVARCHAR(MAX), @LovelySiteIngredientShow NVARCHAR(MAX), @LinkedServer2 NVARCHAR(MAX), @OpenQuery2 NVARCHAR(MAX)
;------------------------------
SET @LinkedServer = N'OPRO'
SET @Department = N'YYS01'
SET @AcadCareer = N'RS1'
IF @LamType = '' OR @LamType IS NULL OR @LamType <> 'LAB' SET @LamType = 'ca.TYPE <> ''LAB''' ELSE SET @LamType = 'ca.TYPE = ''LAB'''
SET @LinkedServer2 = N'[LocalDB]'
;----------------------------------------------------------------------
SET @OpenQuery = N'SELECT * FROM SYSADM.PS_N_Content_ASSIGN ca WHERE ca.Department = '''+@Department+''' AND ca.Position = '''+@AcadCareer+''' AND ca.Term = '''+@Term+''' AND '+@LamType
;----------------------------------------------------------------------
SET @OpenQuery2 = N'SELECT DISTINCT ct.BrandBusinessId, ct.BrandName, ct.QuarterSessionId, ct.Note, ct.AssociateCode, ct.AssociateName, Topics.TopicId, Topics.Name [TopicName], Topics.DepartmentId, co.ContentOutlineId, co.Name [ContentName], co.SessionRuleId, lab.WorkshopId, lab.Name [WorkshopName]
FROM Galaxy.dbo.BrandBusinesss ct
	JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
		AND ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
		AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
	JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
	JOIN Galaxy.dbo.Workshops lab ON Topics.WorkshopId = lab.WorkshopId
		AND lab.Name LIKE ''%'+@WorkshopName+'%'''
;----------------------------------------------------------------------
SET @Query = N'SELECT DISTINCT ca.DESCR [LovelySiteIngredient]
		FROM OPENQUERY('+@LinkedServer+','''+replace(@OpenQuery,'''','''''')+''') ca
			JOIN Seaweed.dbo.QuarterSessions ON ca.Term = QuarterSessions.Period
			JOIN DeepSeaKingdom.dbo.SessionRule sr ON sr.QuarterSessionId = QuarterSessions.QuarterSessionId
				AND sr.ContentCode = ca.Content_CODE
				AND sr.MarkManaged = ''Y''
				AND sr.Shop LIKE ''%'+@WorkshopName+'%'''
;------------------------------
DECLARE @IngredientTable TABLE (Ingredient NVARCHAR(MAX))
INSERT @IngredientTable EXECUTE (@Query)
;------------------------------
SET @LovelySiteIngredient = STUFF((SELECT ',['+c.Ingredient+']' FROM @IngredientTable c FOR XML PATH('')),1,1,'')
SET @LovelySiteIngredientShow = (SELECT ',['+c.Ingredient+'] = ISNULL(CONVERT(VARCHAR,['+c.Ingredient+']),''-'')' FROM @IngredientTable c FOR XML PATH(''))
;----------------------------------------------------------------------
SET @Query = N'SELECT DISTINCT as_pivot.Shop [WorkshopName], as_pivot.Content_CODE [ContentCode], as_pivot.Content_ID [ContentId], as_pivot.Content_TITLE_LONG [ContentName]'+@LovelySiteIngredientShow+', ec.Responsibility [Galaxy: Responsibility], ec.Venture[Galaxy: Venture], ec.MidTerm[Galaxy: MidTerm], ec.FinalTerm[Galaxy: FinalTerm]
	FROM (
		SELECT DISTINCT ca.Content_CODE, ca.Content_ID, ca.Content_TITLE_LONG, ca.DESCR, ca.LAM_WEIGHT, sr.Shop
		FROM OPENQUERY('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') ca
			JOIN Seaweed.dbo.QuarterSessions ON ca.Term = QuarterSessions.Period
			JOIN DeepSeaKingdom.dbo.SessionRule sr ON sr.QuarterSessionId = QuarterSessions.QuarterSessionId
				AND sr.ContentCode = ca.Content_CODE
				AND sr.Shop LIKE ''%'+@WorkshopName+'%''
				AND sr.MarkManaged = ''Y''
	) as_query
	PIVOT (
		SUM(as_query.LAM_WEIGHT)
		FOR as_query.DESCR IN ('+@LovelySiteIngredient+')
	) as_pivot
	JOIN OPENQUERY ('+@LinkedServer2+','''+REPLACE(@OpenQuery2,'''','''''')+''') as_query2 ON LEFT(as_query2.ContentName,CHARINDEX(''-'',ContentName)-1) = as_pivot.Content_CODE
	JOIN DeepSeaKingdom.WE.UDFTV_AssesmentIngredientHorizontal('''+@QuarterSessionId+''') ec ON as_query2.QuarterSessionId = ec.QuarterSessionId
		AND as_query2.ContentOutlineId = ec.ContentOutlineId
	ORDER BY as_pivot.Content_ID'
;----------------------------------------------------------------------
EXECUTE (@Query)
;------------------------------
END