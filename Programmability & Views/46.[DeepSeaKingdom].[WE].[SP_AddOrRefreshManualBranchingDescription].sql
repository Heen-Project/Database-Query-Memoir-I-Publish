USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_AddOrRefreshManualBranchDescription](
	@Term NVARCHAR(MAX) = N''
	,@ImportedMarkIngredientBranchTable NVARCHAR(MAX)
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
DECLARE @Query NVARCHAR(MAX), @Department NVARCHAR(MAX), @AcadCareer NVARCHAR(MAX), @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @LinkedServer2 NVARCHAR(MAX), @OpenQuery2 NVARCHAR(MAX)
;------------------------------
SET @LinkedServer = N'[OPRO]'
SET @LinkedServer2 = N'[LocalDB]'
SET @Department = N'YYS01'
SET @AcadCareer = N'RS1'
;----------------------------------------------------------------------
DELETE FROM [DeepSeaKingdom].[dbo].[ManualBranchDescription] WHERE Term = @Term
;----------------------------------------------------------------------
SET @OpenQuery = N'SELECT * FROM SYSADM.PS_N_Content_ASSIGN ca WHERE ca.Department = '''+@Department+''' AND ca.Position = '''+@AcadCareer+''' AND ca.Term = '''+@Term+''''
;------------------------------
SET @OpenQuery2 = N'SELECT DISTINCT ct.QuarterSessionId, co.ContentOutlineId, co.Name[ContentName]
FROM Galaxy.dbo.BrandBusinesss ct
	JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
		AND ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
		AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
	JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId'
;------------------------------
--[GalaxyPercentage] = IIF(cm.GalaxyNumber IS NULL, ISNULL(ec.Percentage,0), CONVERT(FLOAT,ISNULL(ec.DetailPercentage,0))*ec.Percentage/100)
--[GalaxyPercentage] = IIF(cm.GalaxyNumber IS NULL, ISNULL(ec.Percentage,0), CONVERT(FLOAT,ISNULL(ec.DetailPercentage,0)))
SET @Query = N'WITH ManualBranch_CTE AS (SELECT DISTINCT as_ca.Term, lab.Name, as_ca.Content_ID, cm.ContentCode, cm.ContentName, cm.GalaxyNumber, ec.Type, IIF(cm.GalaxyNumber IS NULL, ISNULL(ec.Percentage,0), CONVERT(FLOAT,ISNULL(ec.DetailPercentage,0))*ec.Percentage/100) [GalaxyPercentage], as_ca.DESCR, as_ca.LAM_WEIGHT, NULL [Note], as_ec.QuarterSessionId, lab.WorkshopId
		FROM '+@ImportedMarkIngredientBranchTable+' cm
		JOIN '+@LinkedServer2+'.Galaxy.dbo.Workshops lab ON lab.Name = cm.Workshop
		JOIN OPENQUERY ('+@LinkedServer2+','''+REPLACE(@OpenQuery2,'''','''''')+''') as_ec ON LEFT(as_ec.ContentName, CHARINDEX(''-'',as_ec.ContentName)-1) = cm.ContentCode
		JOIN (SELECT DISTINCT QuarterSessionId, ContentOutlineId, Type, Percentage, DetailNumber, Detailpercentage FROM DeepSeaKingdom.WE.UDFTV_AssesmentIngredientVerticalDetail('''+@QuarterSessionId+''')) ec ON ec.QuarterSessionId = as_ec.QuarterSessionId
			AND ec.ContentOutlineId = as_ec.ContentOutlineId
			AND ec.Type = cm.GalaxyIngredient
			AND ISNULL(cm.GalaxyNumber,0) = IIF(cm.GalaxyNumber IS NULL, 0, ec.DetailNumber)
		JOIN OPENQUERY ('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') as_ca ON as_ca.Content_CODE = cm.ContentCode
			AND as_ca.DESCR = cm.LovelySiteIngredient)
	INSERT INTO [DeepSeaKingdom].[dbo].[ManualBranchDescription]
	SELECT NEWID(), mm.* 
	FROM ManualBranch_CTE mm'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END