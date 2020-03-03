;------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1610'
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------

/******************************************************************************************
 *							Generate Required Data 
 ******************************************************************************************//*
	--EXECUTE WE.SP_GenerateUploadFamilyAnswerData @Term = @Term
	--EXECUTE WE.SP_GenerateFamilyBatch @Term = @Term
	--EXECUTE WE.SP_GenerateJobScheduleForHonor @Term = @Term

	SELECT * FROM DeepSeaKingdom.WE.UploadFamilyResponsibilityAnswerData
	SELECT * FROM DeepSeaKingdom.WE.UploadFamilyOnsiteTestAnswerData
	SELECT * FROM DeepSeaKingdom.WE.UploadFamilyVentureAnswerData
	SELECT * FROM DeepSeaKingdom.WE.RealFamilyBatch
	SELECT * FROM DeepSeaKingdom.WE.FamilyResponsibilityBatch
	SELECT * FROM DeepSeaKingdom.WE.VentureScheduleForHonor
	SELECT * FROM DeepSeaKingdom.WE.CaseComposingScheduleForHonor
	SELECT * FROM DeepSeaKingdom.WE.VentureAppendixForHonor
*/


/******************************************************************************************
 *							Generate Honor Epitome
 ******************************************************************************************//*
	/**********************************************************************
	 * @VentureResponsibilityBatchContentCode :: Dipake Kalo misalnya ada matakuliah Responsibility yang mau di check berdasarkan jumlah kelompoknya
			Misalnya EXECUTE [WE].[SP_GenerateHonorEpitome] @VentureResponsibilityBatchContentCode = '''CPEN6098'',''CPEN6108'',''CPEN6109'',''CPEN6102'''
	 **********************************************************************/
	EXECUTE [WE].[SP_GenerateHonorEpitome]
	
	SELECT * FROM DeepSeaKingdom.WE.VentureHonorEpitomeDetail ORDER BY 1,2,3,5,6
	SELECT * FROM DeepSeaKingdom.WE.CaseComposingHonorEpitomeDetail ORDER BY 1,2,4,5
	SELECT * FROM DeepSeaKingdom.WE.VentureHonorAppendixEpitomeDetail ORDER BY 1,2,3,5,6
	SELECT * FROM DeepSeaKingdom.WE.VentureHonorEpitomeSummary ORDER BY 1
	SELECT * FROM DeepSeaKingdom.WE.CaseComposingHonorEpitomeSummary ORDER BY 1

	-- * CorrectorDiffCount = Perbedaan Antara Venture Schedule dengan Family Mark Entry (Harus sama semua).
	SELECT * FROM DeepSeaKingdom.WE.VentureHonorEpitomeDetail WHERE CorrectorDiffCount > 1 ORDER BY 1,2,3,5,6
*/


/******************************************************************************************
 *				Transfer Detail dan Summary Supaya bisa dilihat di Atlantis
 ******************************************************************************************//*
	EXECUTE [WE].[SP_TransferHonorEpitome] @Term = @Term
	
	SELECT * FROM DeepSeaKingdom.dbo.VentureHonorEpitomeDetail ORDER BY 2,4,3,5,6,10,11
	SELECT * FROM DeepSeaKingdom.dbo.CaseComposingHonorEpitomeDetail ORDER BY 2,4,3,7,8
	SELECT * FROM DeepSeaKingdom.dbo.HonorEpitomeSummary ORDER BY 2,4,3,5
*/


/******************************************************************************************
 *				Update Manual untuk Case Composer Appendix (FinalTerm)
 ******************************************************************************************//*
	SELECT @WorkshopId = Workshops.WorkshopId FROM [LocalDB].Galaxy.dbo.Workshops WHERE Workshops.Name LIKE '%'+@WorkshopName+'%'
	INSERT INTO [DeepSeaKingdom].[dbo].[CaseComposingHonorEpitomeDetail] ([Id],[Term],[Personname],[WorkshopName],[ContentName],[LimitStatus],[Appendix],[CaseType],[Variation],[Note],[QuarterSessionId]) VALUES (NEWID(), @Term, 'SG15-1', @WorkshopName, 'COMP6140-Data Mining', NULL, 'Y', 'FinalTerm', '1', NULL, @QuarterSessionId), (NEWID(), @Term, 'DF11-2', @WorkshopName, 'COMP6119-Database Administration', NULL, 'Y', 'FinalTerm', '1', NULL, @QuarterSessionId)
	;------------------------------
	INSERT INTO [dbo].[HonorEpitomeSummary] ([Id],[Term],[Personname],[WorkshopName],[HonorType],[TotalPaid],[ResponsibilityReguler],[FinalTermReguler],[MidTermReguler],[VentureReguler],[ResponsibilityAppendix],[FinalTermAppendix],[MidTermAppendix],[VentureAppendix],[Note],[QuarterSessionId]) VALUES (NEWID(), @term, 'SG15-1', @WorkshopName, 'CaseCompose', 0, 0, 0, NULL, 0, 0, 1, NULL, 0, NULL, @QuarterSessionId), (NEWID(), @term, 'DF11-2', @WorkshopName, 'CaseCompose', 0, 0, 0, NULL, 0, 0, 1, NULL, 0, NULL, @QuarterSessionId)
	;------------------------------
	EXECUTE [WE].[SP_RecalculateHonorEpitomeSummary] @Term = @Term
*/


/******************************************************************************************
 *				Generate Honor Data From Galaxy Items Model
 ******************************************************************************************//*
	EXECUTE [WE].[SP_GenerateGalaxyVentureAndCaseComposingReportForHonor] @Term = @Term

	SELECT * FROM DeepSeaKingdom.WE.GalaxyVentureReportForHonor
	SELECT * FROM DeepSeaKingdom.WE.GalaxyCaseComposingReportForHonor
	SELECT * FROM DeepSeaKingdom.WE.GalaxyTotalVentureAndCaseComposingReportForHonor
	SELECT * FROM [DeepSeaKingdom].[WE].[V_GalaxyHonorEpitomeSummary]
*/


/******************************************************************************************
 *					Check Galaxy Data VS Atlantis Data For Honor
 ******************************************************************************************//*
 	SELECT DISTINCT hrs.Term, hrs.Personname, hrs.HonorType
	, [Description] = LTRIM(IIF(ISNULL(mhrs.ResponsibilityAppendix,0) <> ISNULL(hrs.ResponsibilityAppendix,0) , ' ResponsibilityAppendix','')
			+IIF(ISNULL(mhrs.ResponsibilityReguler,0) <> ISNULL(hrs.ResponsibilityReguler,0), ' ResponsibilityReguler','')
			+IIF(ISNULL(mhrs.VentureAppendix,0) <> ISNULL(hrs.VentureAppendix,0), ' VentureAppendix','')
			+IIF(ISNULL(mhrs.VentureReguler,0) <> ISNULL(hrs.VentureReguler,0), ' VentureReguler','')
			+IIF(ISNULL(mhrs.FinalTermAppendix,0) <> ISNULL(hrs.FinalTermAppendix,0), ' FinalTermAppendix','')
			+IIF(ISNULL(mhrs.FinalTermReguler,0) <> ISNULL(hrs.FinalTermReguler,0), ' FinalTermReguler','')), [GalaxyResponsibilityReguler] = mhrs.ResponsibilityReguler, [AtlantisResponsibilityReguler] = hrs.ResponsibilityReguler, [GalaxyFinalTermReguler] = mhrs.FinalTermReguler, [AtlantisFinalTermReguler] = hrs.FinalTermReguler, [GalaxyVentureReguler] = mhrs.VentureReguler, [AtlantisVentureReguler] = hrs.VentureReguler, [GalaxyResponsibilityAppendix] = mhrs.ResponsibilityAppendix, [AtlantisResponsibilityAppendix] = hrs.ResponsibilityAppendix, [GalaxyFinalTermAppendix] = mhrs.FinalTermAppendix, [AtlantisFinalTermAppendix] = hrs.FinalTermAppendix, [GalaxyVentureAppendix] = mhrs.VentureAppendix, [AtlantisVentureAppendix] = hrs.VentureAppendix
	FROM [DeepSeaKingdom].[dbo].[HonorEpitomeSummary] hrs
		JOIN [DeepSeaKingdom].[WE].[V_GalaxyHonorEpitomeSummary] mhrs ON mhrs.Term = hrs.Term
			AND mhrs.Personname = hrs.Personname
			AND mhrs.HonorType = hrs.HonorType
	WHERE (ISNULL(mhrs.ResponsibilityAppendix,0) <> ISNULL(hrs.ResponsibilityAppendix,0) 
		OR ISNULL(mhrs.ResponsibilityReguler,0) <> ISNULL(hrs.ResponsibilityReguler,0)
		OR ISNULL(mhrs.VentureAppendix,0) <> ISNULL(hrs.VentureAppendix,0)
		OR ISNULL(mhrs.VentureReguler,0) <> ISNULL(hrs.VentureReguler,0)
		OR ISNULL(mhrs.FinalTermAppendix,0) <> ISNULL(hrs.FinalTermAppendix,0)
		OR ISNULL(mhrs.FinalTermReguler,0) <> ISNULL(hrs.FinalTermReguler,0))


	SELECT DISTINCT hrs.Term, hrs.Personname, hrs.HonorType, [Atlantis] = hrs.TotalPaid*(CASE WHEN hrs.HonorType = 'CaseCompose' THEN 27750 WHEN hrs.HonorType = 'Venture' THEN 3000 END), [Galaxy] = (CASE WHEN mhrs.HonorType = 'CaseCompose' THEN mhrs.HonorComposing WHEN mhrs.HonorType = 'Venture' THEN mhrs.HonorVenture END)
	FROM [DeepSeaKingdom].[dbo].[HonorEpitomeSummary] hrs
		JOIN [DeepSeaKingdom].[WE].[V_GalaxyHonorEpitomeSummary] mhrs ON mhrs.Term = hrs.Term
			AND mhrs.Personname = hrs.Personname
			AND mhrs.HonorType = hrs.HonorType
	WHERE hrs.TotalPaid*(CASE WHEN hrs.HonorType = 'CaseCompose' THEN 27750 WHEN hrs.HonorType = 'Venture' THEN 3000 END) <> (CASE WHEN mhrs.HonorType = 'CaseCompose' THEN mhrs.HonorComposing WHEN mhrs.HonorType = 'Venture' THEN mhrs.HonorVenture END)


	SELECT DISTINCT as_hrs.Term, as_hrs.Personname, as_hrs.Total, mhrs.TotalHonor
	FROM (SELECT hrs.Term, hrs.Personname, [Total] = SUM(hrs.TotalPaid*(CASE WHEN hrs.HonorType = 'CaseCompose' THEN 27750 WHEN hrs.HonorType = 'Venture' THEN 3000 END)) OVER (PARTITION BY hrs.Term, hrs.Personname)
	FROM [DeepSeaKingdom].[dbo].[HonorEpitomeSummary] hrs) as_hrs
		JOIN [DeepSeaKingdom].[WE].[V_GalaxyHonorEpitomeSummary] mhrs ON mhrs.Term = as_hrs.Term
			AND mhrs.Personname = as_hrs.Personname
	WHERE as_hrs.Total <> mhrs.TotalHonor
*/


/******************************************************************************************
 *				Internal Epitome (Dikirim ke ci Rita [Head Operation724])
 ******************************************************************************************//*
	SELECT DISTINCT * 
	FROM [DeepSeaKingdom].[WE].[V_InternalHonorEpitomeVentureSummary]
	ORDER BY 2
	
	SELECT DISTINCT * 
	FROM [DeepSeaKingdom].[WE].[V_InternalHonorEpitomeCaseComposeSummary]
	ORDER BY 2
*/
-- note: kadang suka di cekin sama resman, kalo resman ceknya dari job Epitome. Nah count di job Epitome suka salah.






/******************************************************************************************
 *				Insert Atlantis Access for Honor Menu
 ******************************************************************************************//*
	--INSERT INTO Seaweed.dbo.MenuRoles
	SELECT NEWID(), '528A6692-CA25-41CE-B80C-A99B2F1DBECD', r.PositionId, '5E3C57D2-6EAA-E411-82C0-D8D385FCE79C', GETDATE()
	FROM Seaweed.dbo.MenuRoles r
		JOIN Seaweed.dbo.MenuItems i ON r.MenuItemId = i.MenuItemId
			AND i.Description = 'Vote Best Assistant'
		JOIN Seaweed.dbo.Positions p ON p.PositionId = r.PositionId
	WHERE NOT EXISTS (SELECT NULL FROM Seaweed.dbo.MenuRoles r2 WHERE r2.PositionId = r.PositionId AND r2.MenuItemId = '528A6692-CA25-41CE-B80C-A99B2F1DBECD' AND NOT EXISTS ( SELECT NULL FROM Seaweed.dbo.DeletedItems di WHERE di.DataId = r2.MenuRoleId))
*/


/******************************************************************************************
 *			Insert Employee Data + Employee Information Data - Report Honor Galaxy
 ******************************************************************************************//*
--INSERT INTO [LocalDB].Galaxy.dbo.Employees
SELECT DISTINCT NEWID(), up.EmployeeId, up.AccountName, up.BirthPlace, up.Birthdate, up.Gender, nm.MemberId
FROM Seaweed.dbo.Persons u 
	JOIN Seaweed.dbo.PersonProfiles up ON u.PersonId = up.PersonId
		--AND NOT EXISTS (SELECT NULL FROM Seaweed.dbo.DeletedItems di WHERE di.DataId = u.PersonId) 
		AND NOT EXISTS (SELECT NULL FROM Seaweed.dbo.DeletedItems di WHERE di.DataId = up.PersonProfileId) 
	JOIN [LocalDB].Galaxy.dbo.NameBranchs nm ON nm.PersonName = u.Personname
	JOIN [LocalDB].Galaxy.dbo.PersonInWorkshops uil ON uil.PersonId = nm.PersonId
		AND uil.WorkshopId = 'F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C'
WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.Employees e2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = e2.EmployeeId) AND e2.Number = up.EmployeeId)
	AND (up.EmployeeId IS NOT NULL AND up.EmployeeId <> '')
	AND u.Personname LIKE '__16-2' -- '____-_'
*//*
--INSERT INTO [LocalDB].Galaxy.dbo.EmployeeInformations --45
SELECT DISTINCT NEWID(), e.EmployeeId, '', up.ResidenceAddress, up.ResidenceTelephone, up.Email, up.AccountNumber+','+up.AccountName+','+up.BankName+','+up.BranchBankName,'',ISNULL(up.Title,'-'), up.UndergraduateMajor+ISNULL(','+IIF(up.GraduateMajor = '',NULL,up.GraduateMajor),''),GETDATE()
FROM Seaweed.dbo.Persons u 
	JOIN Seaweed.dbo.PersonProfiles up ON u.PersonId = up.PersonId
		--AND NOT EXISTS (SELECT NULL FROM Seaweed.dbo.DeletedItems di WHERE di.DataId = u.PersonId) 
		AND NOT EXISTS (SELECT NULL FROM Seaweed.dbo.DeletedItems di WHERE di.DataId = up.PersonProfileId) 
	JOIN [LocalDB].Galaxy.dbo.NameBranchs nm ON nm.PersonName = u.Personname
	JOIN [LocalDB].Galaxy.dbo.PersonInWorkshops uil ON uil.PersonId = nm.PersonId
		AND uil.WorkshopId = 'F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C'
	JOIN [LocalDB].Galaxy.dbo.Employees e ON e.MemberId = nm.MemberId
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = e.EmployeeId) 
WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.EmployeeInformations ei WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = ei.EmployeeInformationId) AND ei.EmployeeId = e.EmployeeId)
	AND (up.EmployeeId IS NOT NULL AND up.EmployeeId <> '')
	AND u.Personname LIKE '__16-2' -- '____-_'
	AND u.Personname NOT IN ('RK14-0','RI13-0','VE15-1','YR12-0','GP11-1','NI11-2')
*/