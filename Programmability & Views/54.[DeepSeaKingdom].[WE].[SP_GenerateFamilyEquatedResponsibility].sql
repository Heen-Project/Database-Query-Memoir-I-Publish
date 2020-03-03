USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateFamilyEquatedResponsibility] (
	@Term NVARCHAR(MAX) = N''
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.FamilyEquatedResponsibility', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.FamilyEquatedResponsibility;
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
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @Query NVARCHAR(MAX)
;----------------------------------------------------------------------
SET @LinkedServer = N'[LocalDB]'
;------------------------------
SET @OpenQuery = N'SELECT DISTINCT ct.BrandBusinessId, ct.BrandName, ct.QuarterSessionId, ct.Note, ct.AssociateCode, ct.AssociateName, Topics.TopicId, Topics.Name [TopicName], Topics.DepartmentId, cts.BrandBusinessFamilyId, bFamilyXXX.MemberId, bFamilyXXX.Number [MemberNumber], bFamilyXXX.Name [MemberName], lab.WorkshopId, lab.Name [WorkshopName], co.ContentOutlineId, co.SessionRuleId, co.Name [ContentName], ctd.Session, ta.[Status]
	FROM Galaxy.dbo.BrandBusinesss ct 
		JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
			AND ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
			AND Topics.WorkshopId LIKE ''%'+@WorkshopId+'%''
			AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
		JOIN Galaxy.dbo.BrandBusinessFamilys cts ON cts.BrandBusinessId = ct.BrandBusinessId
			AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedBrandBusinessFamilys dcts WHERE dcts.BrandBusinessFamilyId = cts.BrandBusinessFamilyId AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = dcts.DeletedBrandBusinessFamilyId))
		JOIN Galaxy.dbo.BrandBusinessDetails ctd ON ctd.BrandBusinessId = ct.BrandBusinessId
			AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ctd.BrandBusinessDetailId)
		JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
		JOIN Galaxy.dbo.Workshops lab ON lab.WorkshopId = Topics.WorkshopId
		JOIN Galaxy.dbo.Members bFamilyXXX ON bFamilyXXX.MemberId = cts.MemberId
		JOIN Galaxy.dbo.VBusinessPresences ta ON ta.BrandBusinessDetailId = ctd.BrandBusinessDetailId
			AND ta.BrandBusinessDetailId = ta.BrandBusinessDetailId
			AND ta.MemberId = cts.MemberId
			AND EXISTS (SELECT NULL FROM Galaxy.dbo.VBusinessPresences ta2 WHERE ta2.BusinessPresenceId = ta.BusinessPresenceId HAVING ta.InsertedDate = MAX(ta2.InsertedDate))
			AND ta.Status LIKE ''Dispensation%'''
;------------------------------
SET @Query = N'
SELECT DISTINCT [FamilyXXX] = mess.MemberNumber
	,[FamilyName] = mess.MemberName
	,[ContentName] = mess.ContentName
	,[TopicName] = mess.TopicName
	,[BrandName] = RTRIM(LEFT(mess.BrandName,5))
	,[Session] = mess.Session
	,[ResponsibilityNumber] = asm.Number
	,[ResponsibilityCount] = asm.ResponsibilityCount
	,[Status] = mess.Status
	,[Term] = '''+@Term+'''
	,[QuarterSessionId] = '''+@QuarterSessionId+'''
	,[WorkshopName] = '''+@WorkshopName+'''
	,[WorkshopId] = '''+@WorkshopId+'''
INTO DeepSeaKingdom.WE.FamilyEquatedResponsibility
FROM OPENQUERY('+@LinkedServer+','''+replace(@OpenQuery,'''','''''')+''') mess
	JOIN DeepSeaKingdom.WE.UDFTV_AssesmentIngredientHorizontal('''+@QuarterSessionId+''') ec ON ec.ContentOutlineId = mess.ContentOutlineId
		AND ec.ContentOutlineId = mess.ContentOutlineId
		AND ec.QuarterSessionId = mess.QuarterSessionId
		AND ec.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
		AND ec.Responsibility <> 0
	LEFT JOIN (SELECT DISTINCT asm.*, [ResponsibilityCount] = COUNT(IIF(asm.Number <> 0, asm.Number,NULL)) OVER (PARTITION BY asm.ContentOutlineId,asm.QuarterSessionId) FROM DeepSeaKingdom.WE.V_ResponsibilitySessionBranch asm WHERE asm.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%'') asm ON asm.QuarterSessionId = mess.QuarterSessionId
		AND asm.ContentOutlineId = mess.ContentOutlineId
		AND asm.Session = mess.Session
WHERE asm.ContentOutlineId IS NOT NULL
	AND asm.Number <> 0
	AND asm.Number < asm.ResponsibilityCount
ORDER BY mess.MemberNumber'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END