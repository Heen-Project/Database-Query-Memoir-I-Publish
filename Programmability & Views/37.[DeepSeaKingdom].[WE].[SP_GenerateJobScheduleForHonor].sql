USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateJobScheduleForHonor] (
	@Term NVARCHAR(MAX) = N''
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @Query NVARCHAR(MAX), @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
SELECT @WorkshopId = Workshops.WorkshopId FROM [LocalDB].Galaxy.dbo.Workshops WHERE Workshops.Name LIKE '%'+@WorkshopName+'%'
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
IF @WorkshopId IS NULL SET @WorkshopName = NULL
;------------------------------
SET @LinkedServer = N'[LocalDB]'
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.VentureScheduleForHonor', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.VentureScheduleForHonor;
IF OBJECT_ID('DeepSeaKingdom.WE.CaseComposingScheduleForHonor', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.CaseComposingScheduleForHonor;
IF OBJECT_ID('DeepSeaKingdom.WE.VentureAppendixForHonor', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.VentureAppendixForHonor;
IF OBJECT_ID('tempdb.dbo.#FamilyMark', 'U') IS NOT NULL DROP TABLE #FamilyMark;
IF OBJECT_ID('tempdb.dbo.#FamilyMarkEntry', 'U') IS NOT NULL DROP TABLE #FamilyMarkEntry;
IF OBJECT_ID('tempdb.dbo.#AssesmentIngredient', 'U') IS NOT NULL DROP TABLE #AssesmentIngredient;
IF OBJECT_ID('tempdb.dbo.#ResponsibilitySessionBranch', 'U') IS NOT NULL DROP TABLE #ResponsibilitySessionBranch;
;----------------------------------------------------------------------
SELECT * INTO #FamilyMark
FROM DeepSeaKingdom.WE.V_FamilyMark WHERE QuarterSessionId LIKE '%'+@QuarterSessionId+'%'
;------------------------------
SELECT * INTO #FamilyMarkEntry 
FROM DeepSeaKingdom.WE.UDFTV_FamilyMarkEntry(@QuarterSessionId)
;------------------------------
SELECT * INTO #AssesmentIngredient 
FROM DeepSeaKingdom.WE.UDFTV_AssesmentIngredientHorizontal(@QuarterSessionId)
;------------------------------
SELECT * INTO #ResponsibilitySessionBranch
FROM DeepSeaKingdom.WE.V_ResponsibilitySessionBranch WHERE QuarterSessionId LIKE '%'+@QuarterSessionId+'%'
;----------------------------------------------------------------------
SET @OpenQuery = N'SELECT DISTINCT nm.PersonId, nm.PersonName, nm.MemberId, uil.WorkshopId
FROM Galaxy.dbo.NameBranchs nm JOIN Galaxy.dbo.PersonInWorkshops uil ON uil.PersonId = nm.PersonId
		AND uil.WorkshopId = '''+@WorkshopId+''''
;----------------------------------------------------------------------
SET @Query = N'SELECT DISTINCT cs.Id, cs.QuarterSessionId, cs.CorrectorId, cs.Corrector, cs.ContentOutlineId, cs.ContentName, cs.BrandName, cs.StartDate, cs.EndDate, cs.FinishDate, cs.ExtendedDate, cs.ExtensionReason, cs.Status, cs.Type, cs.Number, asm.Description, asm.isOnline, asm.isNoFile, asm.isTakeHome, [LimitStatus] = (CASE
	WHEN cs.ExtendedDate IS NULL THEN
		CASE
			WHEN cs.EndDate IS NULL THEN 
				CASE 
					WHEN cs.Status = ''Not Done'' OR cs.Status = ''NotDone'' THEN ''Not Done''
					WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting''
					ELSE cs.Status
				END
			WHEN cs.EndDate IS NOT NULL THEN 
				CASE
					WHEN cs.FinishDate IS NULL THEN 
						CASE
							WHEN CONVERT(DATE,GETDATE()) > CONVERT(DATE,cs.EndDate) AND cs.Status != ''Approved'' THEN ''Limit''
							WHEN cs.Status = ''Not Done'' THEN ''Not Done''
							WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting''
							ELSE cs.Status
						END
					WHEN cs.FinishDate IS NOT NULL THEN 
						CASE
							WHEN CONVERT(DATE, cs.FinishDate) > CONVERT(DATE,cs.EndDate) THEN ''Limit''
							WHEN cs.Status = ''Not Done'' OR cs.Status = ''NotDone'' THEN ''Not Done''
							WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting''
							ELSE cs.Status
						END
				END
		END
	WHEN cs.ExtendedDate IS NOT NULL THEN
		CASE
			WHEN cs.FinishDate IS NULL THEN 
				CASE 
					WHEN CONVERT(DATE,GETDATE()) > CONVERT(DATE,cs.ExtendedDate) AND cs.Status != ''Approved'' THEN ''Limit''
					WHEN cs.Status = ''Not Done'' THEN ''Not Done''
					WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting''
					ELSE cs.Status
				END
			WHEN cs.FinishDate IS NOT NULL THEN 
				CASE 
					WHEN CONVERT(DATE, cs.FinishDate) > CONVERT(DATE,cs.ExtendedDate) THEN ''Limit''
					WHEN cs.Status = ''Not Done'' THEN ''Not Done''
					WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting''
					ELSE cs.Status
				END
		END
END), [PaidStatus] = IIF(cs.Type <> (CASE WHEN ec.FinalTerm > 0 THEN ''FinalTerm'' WHEN ec.MidTerm > 0 THEN ''MidTerm'' WHEN ec.Venture > 0 THEN ''Venture'' WHEN ec.Responsibility > 0 THEN ''Responsibility'' END), ''Unpaid'', ''Paid''), sse.[Family MemberNumber] , sse.[Family BatchNumber], sse.[Family Status], sse.[Family UpdateReason], [CorrectorDiff] = IIF(cs.CorrectorId <> sse.PersonId, ''Y'', ''N'')
INTO DeepSeaKingdom.WE.VentureScheduleForHonor
FROM DeepSeaKingdom.WE.V_VentureSchedule cs
	JOIN OPENQUERY('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') mess ON mess.PersonId = cs.CorrectorId
		AND cs.QuarterSessionId = '''+@QuarterSessionId+'''
	JOIN #AssesmentIngredient ec ON ec.QuarterSessionId = cs.QuarterSessionId
		AND ec.ContentOutlineId = cs.ContentOutlineId
		AND (cs.Type = (CASE 
				WHEN ec.FinalTerm > 0 THEN ''FinalTerm''
				WHEN ec.MidTerm > 0 THEN ''MidTerm''
				WHEN ec.Venture > 0 THEN ''Venture''
				WHEN ec.Responsibility > 0 THEN ''Responsibility''
			END) OR ( cs.Type <> (CASE WHEN ec.FinalTerm > 0 THEN ''FinalTerm'' WHEN ec.MidTerm > 0 THEN ''MidTerm'' WHEN ec.Venture > 0 THEN ''Venture'' WHEN ec.Responsibility > 0 THEN ''Responsibility'' END) 
				AND 
				''Limit'' = (CASE WHEN cs.ExtendedDate IS NULL THEN CASE WHEN cs.EndDate IS NULL THEN CASE WHEN cs.Status = ''Not Done'' OR cs.Status = ''NotDone'' THEN ''Not Done'' WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting'' ELSE cs.Status END WHEN cs.EndDate IS NOT NULL THEN CASE WHEN cs.FinishDate IS NULL THEN CASE WHEN CONVERT(DATE,GETDATE()) > CONVERT(DATE,cs.EndDate) AND cs.Status != ''Approved'' THEN ''Limit'' WHEN cs.Status = ''Not Done'' THEN ''Not Done'' WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting'' ELSE cs.Status END WHEN cs.FinishDate IS NOT NULL THEN  CASE WHEN CONVERT(DATE, cs.FinishDate) > CONVERT(DATE,cs.EndDate) THEN ''Limit'' WHEN cs.Status = ''Not Done'' OR cs.Status = ''NotDone'' THEN ''Not Done'' WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting'' ELSE cs.Status END END END WHEN cs.ExtendedDate IS NOT NULL THEN CASE WHEN cs.FinishDate IS NULL THEN CASE WHEN CONVERT(DATE,GETDATE()) > CONVERT(DATE,cs.ExtendedDate) AND cs.Status != ''Approved'' THEN ''Limit'' WHEN cs.Status = ''Not Done'' THEN ''Not Done'' WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting'' ELSE cs.Status END WHEN cs.FinishDate IS NOT NULL THEN CASE WHEN CONVERT(DATE, cs.FinishDate) > CONVERT(DATE,cs.ExtendedDate) THEN ''Limit'' WHEN cs.Status = ''Not Done'' THEN ''Not Done'' WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting'' ELSE cs.Status END END END) ))
	LEFT JOIN #ResponsibilitySessionBranch asm ON cs.Type = ''Responsibility''
		AND asm.QuarterSessionId = cs.QuarterSessionId 
		AND asm.ContentOutlineId = cs.ContentOutlineId
		AND asm.Number = cs.Number
	JOIN #FamilyMarkEntry sse ON sse.QuarterSessionId = cs.QuarterSessionId
		AND sse.ContentOutlineId = cs.ContentOutlineId
		AND sse.BrandName = cs.BrandName
		AND sse.Type = cs.Type
		AND sse.Number = cs.Number'
		/*, [PaidStatus] = IIF(cs.Type <> (CASE WHEN ec.FinalTerm > ec.MidTerm AND ec.FinalTerm > ec.Venture AND ec.FinalTerm > ec.Responsibility THEN ''FinalTerm'' WHEN ec.MidTerm > ec.Venture AND ec.MidTerm > ec.Responsibility THEN ''MidTerm'' WHEN ec.Venture > ec.Responsibility THEN ''Venture'' WHEN ec.Responsibility > 0 THEN ''Responsibility'' END) */
		/*AND (cs.Type = (CASE 
				WHEN ec.FinalTerm > ec.MidTerm AND ec.FinalTerm > ec.Venture AND ec.FinalTerm > ec.Responsibility THEN ''FinalTerm''
				WHEN ec.MidTerm > ec.Venture AND ec.MidTerm > ec.Responsibility THEN ''MidTerm''
				WHEN ec.Venture > ec.Responsibility THEN ''Venture''
				WHEN ec.Responsibility > 0 THEN ''Responsibility''
			END) OR ( cs.Type <> (CASE WHEN ec.FinalTerm > ec.MidTerm AND ec.FinalTerm > ec.Venture AND ec.FinalTerm > ec.Responsibility THEN ''FinalTerm'' WHEN ec.MidTerm > ec.Venture AND ec.MidTerm > ec.Responsibility THEN ''MidTerm'' WHEN ec.Venture > ec.Responsibility THEN ''Venture'' WHEN ec.Responsibility > 0 THEN ''Responsibility'' END) 
				AND 
				''Limit'' = (CASE WHEN cs.ExtendedDate IS NULL THEN CASE WHEN cs.EndDate IS NULL THEN CASE WHEN cs.Status = ''Not Done'' OR cs.Status = ''NotDone'' THEN ''Not Done'' WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting'' ELSE cs.Status END WHEN cs.EndDate IS NOT NULL THEN CASE WHEN cs.FinishDate IS NULL THEN CASE WHEN CONVERT(DATE,GETDATE()) > CONVERT(DATE,cs.EndDate) AND cs.Status != ''Approved'' THEN ''Limit'' WHEN cs.Status = ''Not Done'' THEN ''Not Done'' WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting'' ELSE cs.Status END WHEN cs.FinishDate IS NOT NULL THEN  CASE WHEN CONVERT(DATE, cs.FinishDate) > CONVERT(DATE,cs.EndDate) THEN ''Limit'' WHEN cs.Status = ''Not Done'' OR cs.Status = ''NotDone'' THEN ''Not Done'' WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting'' ELSE cs.Status END END END WHEN cs.ExtendedDate IS NOT NULL THEN CASE WHEN cs.FinishDate IS NULL THEN CASE WHEN CONVERT(DATE,GETDATE()) > CONVERT(DATE,cs.ExtendedDate) AND cs.Status != ''Approved'' THEN ''Limit'' WHEN cs.Status = ''Not Done'' THEN ''Not Done'' WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting'' ELSE cs.Status END WHEN cs.FinishDate IS NOT NULL THEN CASE WHEN CONVERT(DATE, cs.FinishDate) > CONVERT(DATE,cs.ExtendedDate) THEN ''Limit'' WHEN cs.Status = ''Not Done'' THEN ''Not Done'' WHEN cs.Status = ''Waiting For Approval'' THEN ''Waiting'' ELSE cs.Status END END END) ))*/ -- Komponen Terbesar
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @Query = N'SELECT DISTINCT cms.Id, cms.QuarterSessionId, cms.WorkshopId, cms.CaseComposerId, cms.CaseComposer, cms.ContentOutlineId, cms.ContentName, cms.StartDate, cms.EndDate, cms.FinishDate, cms.ExtendedDate, cms.ExtensionReason, cms.Status, cms.Type, cms.Variation, cms.ApproveBy, cms.fileDetail, cms.NoteFromCoordinator, [LimitStatus] = (CASE
	WHEN cms.ExtendedDate IS NULL THEN
		CASE
			WHEN cms.EndDate IS NULL THEN 
				CASE 
					WHEN cms.Status = ''Not Done'' OR cms.Status = ''NotDone'' THEN ''Not Done''
					WHEN cms.Status = ''Waiting For Approval'' THEN ''Waiting''
					ELSE cms.Status
				END
			WHEN cms.EndDate IS NOT NULL THEN 
				CASE
					WHEN cms.FinishDate IS NULL THEN 
						CASE
							WHEN CONVERT(DATE,GETDATE()) > CONVERT(DATE,cms.EndDate) AND cms.Status != ''Approved'' THEN ''Limit''
							WHEN cms.Status = ''Not Done'' THEN ''Not Done''
							WHEN cms.Status = ''Waiting For Approval'' THEN ''Waiting''
							ELSE cms.Status
						END
					WHEN cms.FinishDate IS NOT NULL THEN 
						CASE
							WHEN CONVERT(DATE, cms.FinishDate) > CONVERT(DATE,cms.EndDate) THEN ''Limit''
							WHEN cms.Status = ''Not Done'' OR cms.Status = ''NotDone'' THEN ''Not Done''
							WHEN cms.Status = ''Waiting For Approval'' THEN ''Waiting''
							ELSE cms.Status
						END
				END
		END
	WHEN cms.ExtendedDate IS NOT NULL THEN
		CASE
			WHEN cms.FinishDate IS NULL THEN 
				CASE 
					WHEN CONVERT(DATE,GETDATE()) > CONVERT(DATE,cms.ExtendedDate) AND cms.Status != ''Approved'' THEN ''Limit''
					WHEN cms.Status = ''Not Done'' THEN ''Not Done''
					WHEN cms.Status = ''Waiting For Approval'' THEN ''Waiting''
					ELSE cms.Status
				END
			WHEN cms.FinishDate IS NOT NULL THEN 
				CASE 
					WHEN CONVERT(DATE, cms.FinishDate) > CONVERT(DATE,cms.ExtendedDate) THEN ''Limit''
					WHEN cms.Status = ''Not Done'' THEN ''Not Done''
					WHEN cms.Status = ''Waiting For Approval'' THEN ''Waiting''
					ELSE cms.Status
				END
		END
END), [PaidStatus] = IIF(cms.Type IN (''FinalTerm''), ''Paid'', ''Unpaid'')
INTO DeepSeaKingdom.WE.CaseComposingScheduleForHonor
FROM DeepSeaKingdom.WE.V_CaseComposingSchedule cms
WHERE cms.WorkshopId = '''+@WorkshopId+'''
		AND cms.QuarterSessionId = '''+@QuarterSessionId+''''
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @Query = N'SELECT DISTINCT ss.Id, ss.QuarterSessionId, ss.CorrectorId, [Corrector] = mess.Personname, ss.ContentOutlineId, [ContentName] = co.Name, ss.BrandName, ss.Status, ss.Type, ss.Number, asm.Description, asm.isOnline, asm.isNoFile, asm.isTakeHome, ss.MemberId, [MemberNumber] = bFamilyXXX.Number, ss.UpdateReason, [CorrectorDiff] = ''N''
INTO DeepSeaKingdom.WE.VentureAppendixForHonor
FROM #FamilyMark ss
	JOIN OPENQUERY('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') mess ON mess.PersonId = ss.CorrectorId
		AND ss.QuarterSessionId = '''+@QuarterSessionId+'''
	JOIN [LocalDB].Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = ss.ContentOutlineId
	JOIN [LocalDB].Galaxy.dbo.Members bFamilyXXX ON bFamilyXXX.MemberId = ss.MemberId
	JOIN #AssesmentIngredient ec ON ec.QuarterSessionId = ss.QuarterSessionId
		AND ec.ContentOutlineId = ss.ContentOutlineId
		AND ss.Type = (CASE 
				WHEN ec.FinalTerm > 0 THEN ''FinalTerm''
				WHEN ec.MidTerm > 0 THEN ''MidTerm''
				WHEN ec.Venture > 0 THEN ''Venture''
				WHEN ec.Responsibility > 0 THEN ''Responsibility''
			END)
	LEFT JOIN #ResponsibilitySessionBranch asm ON ss.Type = ''Responsibility''
		AND asm.QuarterSessionId = ss.QuarterSessionId 
		AND asm.ContentOutlineId = ss.ContentOutlineId
		AND asm.Number = ss.Number
WHERE ss.UpdateReason LIKE ''Appendix%'''
		/*AND ss.Type = (CASE 
				WHEN ec.FinalTerm > ec.MidTerm AND ec.FinalTerm > ec.Venture AND ec.FinalTerm > ec.Responsibility THEN ''FinalTerm''
				WHEN ec.MidTerm > ec.Venture AND ec.MidTerm > ec.Responsibility THEN ''MidTerm''
				WHEN ec.Venture > ec.Responsibility THEN ''Venture''
				WHEN ec.Responsibility > 0 THEN ''Responsibility''
			END)*/ -- Komponen Terbesar
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END