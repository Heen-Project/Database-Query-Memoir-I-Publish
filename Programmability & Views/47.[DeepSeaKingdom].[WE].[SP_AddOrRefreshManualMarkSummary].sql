USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_AddOrRefreshManualMarkSummary](
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
DECLARE @Query NVARCHAR(MAX), @Department NVARCHAR(MAX), @AcadCareer NVARCHAR(MAX), @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @LinkedServer2 NVARCHAR(MAX), @OpenQuery2 NVARCHAR(MAX), @SubqueryLEC NVARCHAR(MAX), @SubqueryLAB NVARCHAR(MAX)
;------------------------------
SET @LinkedServer = N'[OPRO]'
SET @LinkedServer2 = N'[LocalDB]'
SET @Department = N'YYS01'
SET @AcadCareer = N'RS1'
;----------------------------------------------------------------------
DELETE FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] WHERE Term = @Term
;----------------------------------------------------------------------
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
SET @OpenQuery = N'SELECT * FROM SYSADM.PS_N_Content_ASSIGN ca WHERE ca.Department = '''+@Department+''' AND ca.Position = '''+@AcadCareer+''' AND ca.Term = '''+@Term+''''
;------------------------------
SET @OpenQuery2 = N'SELECT DISTINCT ct.BrandBusinessId, ct.BrandName, ct.QuarterSessionId, ct.Note, ct.AssociateCode, ct.AssociateName, Topics.TopicId, Topics.Name [TopicName], Topics.DepartmentId, co.ContentOutlineId, co.Name [ContentName], co.SessionRuleId, lab.WorkshopId, lab.Name [WorkshopName], cts.BrandBusinessFamilyId, cts.SeatNumber, bFamilyXXX.MemberId, bFamilyXXX.Number [MemberNumber], bFamilyXXX.Name [MemberName], bFamilyXXX.BirthDate, bFamilyXXX.PictureId
FROM Galaxy.dbo.BrandBusinesss ct
	JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
		AND ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
		AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
	JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
	JOIN Galaxy.dbo.Workshops lab ON lab.WorkshopId = Topics.WorkshopId
		AND ((LEFT(co.Name,CHARINDEX(''-'',co.Name)-1) IN ('+@SubqueryLAB+') AND RTRIM(LEFT(ct.BrandName,5)) NOT LIKE ''L%'')
			OR (LEFT(co.Name,CHARINDEX(''-'',co.Name)-1) IN ('+@SubqueryLEC+') AND RTRIM(LEFT(ct.BrandName,5)) LIKE ''L%''))
	JOIN Galaxy.dbo.BrandBusinessFamilys cts ON cts.BrandBusinessId = ct.BrandBusinessId
		AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedBrandBusinessFamilys dcts WHERE dcts.BrandBusinessFamilyId = cts.BrandBusinessFamilyId AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = dcts.DeletedBrandBusinessFamilyId))
	JOIN Galaxy.dbo.Members bFamilyXXX ON bFamilyXXX.MemberId = cts.MemberId'
;------------------------------
SET @Query = N'WITH ManualMark_CTE AS (
		SELECT DISTINCT [Term] = '''+@Term+''' 
		,[WorkshopName] = mess.WorkshopName
		,[BrandNbr] = DeepSeaKingdom.[dbo].[UDF_Split](mess.Note,''-'',3)
		,[BrandNbrTheory] = NULL
		,[ContentID] = NULL
		,[ContentIDParent] = mmd.ContentID
		,[ContentName] = mess.ContentName
		,[TopicName] = mess.TopicName
		,[AssociateCode] = UPPER(mess.AssociateCode)
		,[AssociateName] = UPPER(mess.AssociateName)
		,[MemberYY] = NULL
		,[MemberNumber] = UPPER(mess.MemberNumber)
		,[MemberName] = UPPER(mess.MemberName)
		,[BrandName] = RTRIM(LEFT(mess.BrandName,5))
		,[BrandNameTheory] = NULL
		,[Mark] = NULL
		,[Status] = NULL
		,[LovelySiteIngredient] = mmd.LovelySiteIngredient
		,[LovelySitePercentage] = mmd.LovelySitePercentage
		,[Orderline] = NULL
		,[Note] = NULL
		,[QuarterSessionId] = mess.QuarterSessionId
		,[WorkshopId] = mess.WorkshopId
		,[TopicId] = mess.TopicId
		,[BrandBusinessId] = mess.BrandBusinessId
		,[BrandBusinessFamilyId] = mess.BrandBusinessFamilyId
		,[MemberIdXXX] = mess.MemberId
		FROM OPENQUERY ('+@LinkedServer2+','''+REPLACE(@OpenQuery2,'''','''''')+''') mess
			--JOIN OPENQUERY ('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') caTopic ON caTopic.Content_CODE = LEFT(mess.TopicName, CHARINDEX(''-'',mess.TopicName)-1)
			--JOIN OPENQUERY ('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') caContent ON caContent.Content_CODE = LEFT(mess.ContentName, CHARINDEX(''-'',mess.ContentName)-1)
	JOIN [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd ON mmd.ContentCode = LEFT(mess.ContentName, CHARINDEX(''-'',mess.ContentName)-1)
		--AND mmd.LovelySiteIngredient = caContent.DESCR
		AND mmd.Term = '''+@Term+'''
		AND mmd.QuarterSessionId = mess.QuarterSessionId
		)
	INSERT INTO [DeepSeaKingdom].[dbo].[ManualMarkSummary]
	SELECT NEWID(), ms.* 
	FROM ManualMark_CTE ms'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
DECLARE @SpecialBrand NVARCHAR(MAX)
;------------------------------
SELECT @SpecialBrand = STUFF((SELECT DISTINCT ','''+cm.[Brand Nbr]+''''
	FROM CheckMeeting cm 
	WHERE cm.[Academic Department] = @Department
		AND cm.[Academic Career] = @AcadCareer 
		AND cm.Term = @Term
		AND cm.Latitude LIKE 'JUR%'
    FOR XML PATH('')), 1, 1, '')
;------------------------------
SET @Query = 'DELETE FROM mss
	FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
	WHERE mss.Term = '+@Term+'
		AND mss.BrandNbr IN ('+@SpecialBrand+')'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
UPDATE mss SET mss.MemberYY = es.ASCID
FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
	JOIN OPENQUERY(OPRO,'SELECT * FROM SYSADM.PS_EXTERNAL_SYSTEM') es ON es.EXTERNAL_SYSTEM_ID = mss.MemberNumber
WHERE mss.Term = @Term
;----------------------------------------------------------------------
UPDATE mss SET mss.BrandNbrTheory = cmParent.[Brand Nbr], mss.BrandNameTheory = cmParent.[Section], [ContentID] = cmChild.[Content ID]
FROM [DeepSeaKingdom].dbo.ManualMarkSummary mss
	JOIN DeepSeaKingdom.dbo.CheckMeeting cmChild ON cmChild.[Academic Department] = @Department
		AND cmChild.[Academic Career] = @AcadCareer
		AND cmChild.[Brand Nbr] = mss.BrandNbr
		AND cmChild.Term = mss.Term
		AND cmChild.Term = @Term
	JOIN DeepSeaKingdom.dbo.CheckMeeting cmParent
		ON cmParent.Section = CASE WHEN cmChild.[Auto Enrol] IS NULL OR cmChild.[Auto Enrol] LIKE 'C%' OR cmChild.[Auto Enrol] = '' THEN cmChild.Section ELSE cmChild.[Auto Enrol] END
		--AND cmChild.Topic  = cmParent.Topic
		--AND cmChild.[Catalog Nbr] = cmParent.[Catalog Nbr] 
		AND cmChild.[Content ID] = cmParent.[Content ID]
		AND cmChild.Term = cmParent.Term
;----------------------------------------------------------------------
END