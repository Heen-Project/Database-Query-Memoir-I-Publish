USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateFamilyInLoanRemoved] (
	@Term NVARCHAR(MAX) = N''
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
	,@FamilyInLoanTable NVARCHAR(MAX) = N''
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.FamilyInLoanRemoved', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.FamilyInLoanRemoved;
IF OBJECT_ID('tempdb.dbo.#AssesmentIngredient', 'U') IS NOT NULL DROP TABLE #AssesmentIngredient;
IF OBJECT_ID('tempdb.dbo.#FamilyMark', 'U') IS NOT NULL DROP TABLE #FamilyMark;
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
SELECT * 
INTO #FamilyMark 
FROM DeepSeaKingdom.WE.V_FamilyMark ss WHERE ss.QuarterSessionId LIKE '%'+@QuarterSessionId+'%'
;------------------------------
/*Komponen Terbesar*/
SELECT DISTINCT ech.*, [Ingredient] = CASE WHEN ech.FinalTerm>ech.MidTerm AND ech.FinalTerm>ech.Venture AND ech.FinalTerm>ech.Responsibility AND ech.FinalTerm>0 THEN 'FinalTerm' WHEN ech.MidTerm>ech.Venture AND ech.MidTerm>ech.Responsibility AND ech.MidTerm>0 THEN 'MidTerm' WHEN ech.Venture>ech.Responsibility AND ech.Venture>0 THEN 'Venture' WHEN ech.Responsibility>0 THEN 'Responsibility' END 
INTO #AssesmentIngredient
FROM DeepSeaKingdom.WE.UDFTV_AssesmentIngredientHorizontal(@QuarterSessionId) ech
/*Komponen Praktikum*/
--SELECT DISTINCT ecv.*, [Ingredient] = ecv.Type INTO #AssesmentIngredient
--FROM  DeepSeaKingdom.WE.UDFTV_AssesmentIngredientVertical(@QuarterSessionId) ecv
;----------------------------------------------------------------------
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @LinkedServer2 NVARCHAR(MAX), @OpenQuery2 NVARCHAR(MAX), @Query NVARCHAR(MAX), @Department NVARCHAR(MAX), @AcadCareer NVARCHAR(MAX)
;----------------------------------------------------------------------
SET @LinkedServer = N'[OPRO]'
SET @LinkedServer2 = N'[LocalDB]'
SET @Department = N'YYS01'
SET @AcadCareer = N'RS1'
;------------------------------
SET @OpenQuery2 = N'SELECT DISTINCT ct.BrandBusinessId, ct.BrandName, ct.QuarterSessionId, ct.Note, ct.AssociateCode, ct.AssociateName, Topics.TopicId, Topics.Name [TopicName], Topics.DepartmentId, cts.BrandBusinessFamilyId, bFamilyXXX.MemberId, bFamilyXXX.Number [MemberNumber], bFamilyXXX.Name [MemberName], lab.WorkshopId, lab.Name [WorkshopName], co.ContentOutlineId, co.SessionRuleId, co.Name [ContentName]
	FROM Galaxy.dbo.BrandBusinesss ct 
		JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
			AND ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
			AND Topics.WorkshopId LIKE ''%'+@WorkshopId+'%''
			AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
		JOIN Galaxy.dbo.BrandBusinessFamilys cts ON cts.BrandBusinessId = ct.BrandBusinessId
			AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedBrandBusinessFamilys dcts WHERE dcts.BrandBusinessFamilyId = cts.BrandBusinessFamilyId AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = dcts.DeletedBrandBusinessFamilyId))
		JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
		JOIN Galaxy.dbo.Workshops lab ON lab.WorkshopId = Topics.WorkshopId
		JOIN Galaxy.dbo.Members bFamilyXXX ON bFamilyXXX.MemberId = cts.MemberId'
;------------------------------
SET @OpenQuery = N'SELECT DISTINCT o.EXTERNAL_SYSTEM_ID FROM PS_N_SF_OUTSTAND o WHERE o.Department = '''+@Department+''' AND o.Position = '''+@AcadCareer+''' AND o.ITEM_TERM = '''+@Term+''''
;------------------------------
IF @FamilyInLoanTable IS NULL OR @FamilyInLoanTable = '' SET @FamilyInLoanTable = 'OPENQUERY('+@LinkedServer+','''+replace(@OpenQuery,'''','''''')+''')' 
;------------------------------
SET @Query = N'
SELECT DISTINCT [BrandName] = RTRIM(LEFT(mess.BrandName,5))
	,[MemberNumber] = mess.MemberNumber
	,[MemberName] = mess.MemberName
	,[TopicName] = mess.TopicName
	,[ContentName] = mess.ContentName
	,[Ingredient] = ec.Ingredient
	,[ResponsibilityNumber] = asm.Number
	,[ResponsibilitySession] = asm.Session
	,[ResponsibilityDescription] = asm.Description
	,[Mark] = ss.[Mark]
	,[Status] = ss.[Status]
	,[UpdateReason] = ss.UpdateReason
	,[Corrector] = nm.PersonName
	,[Phone] = es.Phone
	,[Email] = es.Email
	,[House] = es.House
	,[Term] = '''+@Term+'''
	,[QuarterSessionId] = '''+@QuarterSessionId+'''
	,[WorkshopName] = '''+@WorkshopName+'''
	,[WorkshopId] = '''+@WorkshopId+'''
INTO DeepSeaKingdom.WE.FamilyInLoanRemoved
FROM OPENQUERY('+@LinkedServer2+','''+replace(@OpenQuery2,'''','''''')+''') mess
	JOIN '+@FamilyInLoanTable+' Loan ON Loan.EXTERNAL_SYSTEM_ID = mess.MemberNumber
	JOIN DeepSeaKingdom.dbo.SessionRule sr ON sr.ContentCode = LEFT(mess.ContentName, CHARINDEX(''-'',mess.ContentName)-1)
		AND sr.QuarterSessionId = mess.QuarterSessionId
		AND sr.MarkManaged = ''Y''
	JOIN #AssesmentIngredient ec ON ec.ContentOutlineId = mess.ContentOutlineId
		AND ec.ContentOutlineId = mess.ContentOutlineId
		AND ec.QuarterSessionId = mess.QuarterSessionId
	LEFT JOIN DeepSeaKingdom.WE.V_ResponsibilitySessionBranch asm ON asm.QuarterSessionId = mess.QuarterSessionId
		AND asm.ContentOutlineId = mess.ContentOutlineId
		AND ec.Ingredient = ''Responsibility''
	LEFT JOIN #FamilyMark ss ON ss.BrandBusinessId = mess.BrandBusinessId
		AND ss.QuarterSessionId = mess.QuarterSessionId
		AND ss.ContentOutlineId = mess.ContentOutlineId
		AND ss.MemberId = mess.MemberId
		AND ss.Type = ec.Ingredient
		AND ss.Number = (CASE WHEN ec.Ingredient = ''Responsibility'' THEN asm.Number ELSE 1 END)
	LEFT JOIN [LocalDB].Galaxy.dbo.NameBranchs nm ON nm.PersonId = ss.CorrectorId
	LEFT JOIN DeepSeaKingdom.dbo.EnrollmentStatus es ON es.[Family ID] = mess.MemberNumber
		AND es.[Academic Career] = '''+@AcadCareer+'''
		AND es.Term = '''+@Term+''''
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END