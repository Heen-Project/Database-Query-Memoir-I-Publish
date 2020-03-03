;------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1620'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @OnsiteTestDateStartAfter NVARCHAR(MAX) = '2017-06-15'
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------


/******************************************************************************************
 *								Generate Required Data 
 ******************************************************************************************//*
	EXECUTE [DeepSeaKingdom].[WE].[SP_GenerateContentLatitudeFirmware]
	EXECUTE [DeepSeaKingdom].[WE].[SP_GenerateOnsiteTestScheduleBeforePublish] @Term = @Term
	SELECT * INTO #PS_N_Content_ASSIGN
	FROM OPENQUERY([OPRO], 'SELECT DISTINCT Content_ID, Content_CODE, Content_TITLE_LONG FROM PS_N_Content_ASSIGN WHERE Department = ''YYS01'' AND Position = ''RS1'' AND Term = ''1620''') ca
	
	SELECT * FROM [DeepSeaKingdom].[WE].[ContentLatitudeFirmware]
	SELECT * FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish]
*/




/******************************************************************************************
 *	
 ******************************************************************************************//*
	/**********************************************************************
	 * ---------- ---------- Check Firmware Availability ---------- ----------
	 * Sampai Row yang bermasalah sudah tidak ada.
	 * Kalau [AvailableLatitudeByFirmware] NULL, ditanyain applikasinya ke (OnsiteTestination Scheduling Staff, Family Registration & Scheduling Center)
	 * Kalau ([AvailableLatitudeForAllocation] NULL OR [AvailableLatitudeForAllocation] = '') AND [AvailableLatitudeByFirmware] NOT NULL, berarti ga ada ruangan kosong yang bisa lagi untuk shift itu
	 * (StartA <= EndB) and (EndA >= StartB) :: Kalau macam Between
	 * (StartA <EndB) and (EndA > StartB) :: yang kita pake
	 **********************************************************************/*//*
	SELECT DISTINCT esbp.OnsiteTestDate, [ContentNameParent] = caParent.Content_CODE, [ContentNameParent] = caParent.Content_TITLE_LONG, [ContentNameDummy] = caDummy.Content_CODE, [ContentNameDummy] = caDummy.Content_TITLE_LONG, [Brand_Status] = ISNULL(esbp.Brand_Status,'Parent'), esbp.LatitudeAllocation, esbp.Brand_SECTION, esbp.ShiftStart, [ShiftEnd] = DATEADD(MINUTE, esbp.OnsiteTestDuration, esbp.ShiftStart), esbp.OnsiteTestType, esbp.House, esbp.FacilityID, esbp.Latitude
	,[AvailableLatitudeForAllocation] = ISNULL('[Galaxy] '+STUFF((SELECT DISTINCT ';'+crs2.LatitudeName FROM DeepSeaKingdom.WE.ContentLatitudeFirmware crs2 WHERE crs2.ContentCode = caParent.Content_CODE AND NOT EXISTS (
	SELECT NULL FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp2 
	WHERE esbp2.Latitude = crs2.LatitudeName 
		AND esbp2.OnsiteTestDate = esbp.OnsiteTestDate 
		AND ((esbp.ShiftStart < DATEADD(MINUTE, esbp2.OnsiteTestDuration, esbp2.ShiftStart)) AND (DATEADD(MINUTE, esbp.OnsiteTestDuration, esbp.ShiftStart) > esbp2.ShiftStart))
	) FOR XML PATH('')),1,1,''),'')+ISNULL('[Manual] '+STUFF((SELECT DISTINCT ';'+ers2.Latitude FROM DeepSeaKingdom.dbo.OnsiteTestLatitudeFirmware ers2 WHERE ers2.ContentCode = caParent.Content_CODE AND NOT EXISTS (
	SELECT NULL FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp2 
	WHERE esbp2.Latitude = ers2.Latitude 
		AND ers2.Valid = 'Y'
		AND ers2.StartTerm = esbp2.TERM
		AND esbp2.OnsiteTestDate = esbp.OnsiteTestDate 
		AND ((esbp.ShiftStart < DATEADD(MINUTE, esbp2.OnsiteTestDuration, esbp2.ShiftStart)) AND (DATEADD(MINUTE, esbp.OnsiteTestDuration, esbp.ShiftStart) > esbp2.ShiftStart))
	) FOR XML PATH('')),1,1,''),'')
	,[AvailableLatitudeByFirmware] = ISNULL('[Galaxy] '+STUFF((SELECT DISTINCT ';'+crs2.LatitudeName FROM DeepSeaKingdom.WE.ContentLatitudeFirmware crs2 WHERE crs2.ContentCode = caParent.Content_CODE FOR XML PATH('')),1,1,''),'')+ISNULL('[Manual] '+STUFF((SELECT DISTINCT ';'+ers2.Latitude FROM DeepSeaKingdom.dbo.OnsiteTestLatitudeFirmware ers2 WHERE ers2.ContentCode = caParent.Content_CODE AND ers2.Valid = 'Y' AND ers2.StartTerm = esbp.TERM FOR XML PATH('')),1,1,''),'')
	FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp
		JOIN #PS_N_Content_ASSIGN caParent ON esbp.Content_ID_Parent = caParent.Content_ID
		JOIN #PS_N_Content_ASSIGN caDummy ON esbp.Content_ID = caDummy.Content_ID
		JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID
			AND rm.FirmwareManaged = 'Y'
		LEFT JOIN DeepSeaKingdom.WE.ContentLatitudeFirmware crs ON crs.ContentCode = caParent.Content_CODE
			AND crs.LatitudeName = esbp.Latitude
		LEFT JOIN DeepSeaKingdom.dbo.OnsiteTestLatitudeFirmware ers ON ers.ContentCode = caParent.Content_CODE
			AND ers.Latitude = esbp.Latitude
			AND ers.StartTerm = esbp.TERM
			AND ers.Valid = 'Y'
	WHERE esbp.OnsiteTestDate > @OnsiteTestDateStartAfter
		AND crs.ContentCode IS NULL
		AND ers.ContentCode IS NULL
	ORDER BY esbp.OnsiteTestDate, esbp.ShiftStart, esbp.Latitude, [ShiftEnd], caParent.Content_CODE, Brand_Status, esbp.Brand_SECTION
	
	/* ---------- Move Latitude
	SELECT esbp.OnsiteTestDate, [ContentNameParent] = caParent.Content_CODE, [ContentNameParent] = caParent.Content_TITLE_LONG, [ContentNameDummy] = caDummy.Content_CODE, [ContentNameDummy] = caDummy.Content_TITLE_LONG, [Brand_Status] = ISNULL(esbp.Brand_Status,'Parent'), esbp.LatitudeAllocation, esbp.Brand_SECTION, esbp.ShiftStart, [ShiftEnd] = DATEADD(MINUTE, esbp.OnsiteTestDuration, esbp.ShiftStart), esbp.OnsiteTestType, esbp.House, esbp.FacilityID, esbp.Latitude
	FROM WE.[OnsiteTestScheduleBeforePublish] esbp
		JOIN #PS_N_Content_ASSIGN caParent ON esbp.Content_ID_Parent = caParent.Content_ID
		JOIN #PS_N_Content_ASSIGN caDummy ON esbp.Content_ID = caDummy.Content_ID
	--WHERE OnsiteTestDate = '2017-07-12' AND Latitude IN ('630','629') AND ShiftStart = '08:00:00'
	WHERE OnsiteTestDate = '2017-07-12' AND Latitude IN ('630','629') AND ShiftStart = '08:00:00'
	*/
	

	/**********************************************************************
	 * ---------- ---------- Check Latitude Capacity ---------- ----------
	 * [Status], Harus NULL. Kalau tidak NULL berarti jumlahnya melebihi batas ruangan
	 * [AllocatedLatitudeCount], Harus = 1. Kalau lebih dari 1 berarti ada data yang duplikat
	 **********************************************************************/*//*
	SELECT DISTINCT [Status] = (CASE WHEN SUM(esbp.LatitudeAllocation) OVER (PARTITION BY esbp.ShiftStart, esbp.OnsiteTestDate, esbp.Latitude) > rm.Capacity THEN 1 ELSE NULL END), [AllocatedLatitudeCount] = COUNT(esbp.OnsiteTestScheduleLatitudeID) OVER (PARTITION BY esbp.OnsiteTestScheduleDateID, esbp.Latitude), [FamilyCount] = SUM(esbp.LatitudeAllocation) OVER (PARTITION BY esbp.ShiftStart, esbp.OnsiteTestDate, esbp.Latitude), rm.Capacity, esbp.Latitude, esbp.*
	FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp
		JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID
			AND rm.FirmwareManaged = 'Y'
	WHERE esbp.OnsiteTestDate > @OnsiteTestDateStartAfter
	ORDER BY [Status] DESC, [AllocatedLatitudeCount] DESC, [FamilyCount] DESC

	/*---------- Check OnsiteTest ContentCode
	SELECT DISTINCT [Content_ID Parent] = caParent.Content_ID, [Content_CODE Parent] = caParent.Content_CODE, [Content_ID Dummy] = caDummy.Content_ID, [Content_CODE Dummy] = caDummy.Content_CODE, esbp.*
	FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp
		JOIN #PS_N_Content_ASSIGN caParent ON esbp.Content_ID_Parent = caParent.Content_ID
		JOIN #PS_N_Content_ASSIGN caDummy ON esbp.Content_ID = caDummy.Content_ID
		JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID
			AND rm.FirmwareManaged = 'Y'
	WHERE esbp.OnsiteTestScheduleDateID = '25952'*/

	
	/**********************************************************************
	 * ---------- ---------- Check Golbal or Smart Brand ---------- ----------
	 * Sampai Row yang bermasalah sudah tidak ada.
	 **********************************************************************/*//*
	SELECT DISTINCT *
	FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp
		JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID
			AND rm.FirmwareManaged = 'Y'
			AND esbp.OnsiteTestDate > @OnsiteTestDateStartAfter
		JOIN OPENQUERY ([OPRO], 'SELECT * FROM PS_Brand_ATTRIBUTE ca WHERE ca.Content_ATTR = ''SC'' OR ca.Content_ATTR = ''GC''') ca ON ca.Content_ID = esbp.Content_ID_Parent
			AND ca.Term = esbp.TERM
			AND ca.Brand_SECTION = esbp.Brand_SECTION
			AND ca.Content_ATTR_VALUE = 'Y'
			AND EXISTS (SELECT DISTINCT NULL
			FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp2
				JOIN DeepSeaKingdom.dbo.LatitudeBranch rm2 ON rm2.Latitude = esbp2.FacilityID
					AND rm2.FirmwareManaged = 'Y'
					AND esbp2.OnsiteTestDate > @OnsiteTestDateStartAfter
			WHERE NOT EXISTS (SELECT NULL FROM OPENQUERY ([OPRO], 'SELECT * FROM PS_Brand_ATTRIBUTE ca WHERE ca.Content_ATTR = ''SC'' OR ca.Content_ATTR = ''GC''') ca2 WHERE ca2.Content_ID = esbp2.Content_ID_Parent
					AND ca2.Term = esbp2.TERM
					AND ca2.Brand_SECTION = esbp2.Brand_SECTION
					AND ca2.Content_ATTR_VALUE = 'Y')
					AND esbp.OnsiteTestDate = esbp2.OnsiteTestDate AND esbp.ShiftStart = esbp2.ShiftStart AND esbp.Latitude = esbp2.Latitude)
	 

	/**********************************************************************
	 * ---------- ---------- Check OnsiteTest Using IBT ---------- ----------
	 * Sampai Row yang bermasalah sudah tidak ada.
	 **********************************************************************/*//*
	---------- IBT tidak boleh 1 ruangan dengan Non-IBT
	SELECT DISTINCT *
	FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp
		JOIN DeepSeaKingdom.dbo.Departments d ON d.Content_ID = esbp.Content_ID_Parent
			AND (d.DEPARTMENT <> 'LANG' OR (d.DEPARTMENT = 'LANG' AND d.Content_ATTR_VALUE <> 33))
			AND esbp.OnsiteTestDuration = '120'
			AND esbp.OnsiteTestDate > @OnsiteTestDateStartAfter
		JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID
			AND rm.FirmwareManaged = 'Y'
			AND EXISTS( SELECT DISTINCT NULL 
			FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp2 JOIN DeepSeaKingdom.dbo.Departments d2 ON d2.Content_ID = esbp2.Content_ID_Parent
				AND d2.DEPARTMENT = 'LANG'
				AND d2.Content_ATTR_VALUE = 33
			WHERE esbp.OnsiteTestDate = esbp2.OnsiteTestDate AND esbp.ShiftStart = esbp2.ShiftStart AND esbp.Latitude = esbp2.Latitude)
			
	---------- Kalau beda mata kuliah tapi sama-sama IBT, tanyakan apakah boleh digabung.
	SELECT DISTINCT *
	FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp
		JOIN DeepSeaKingdom.dbo.Departments d ON d.Content_ID = esbp.Content_ID_Parent
			AND (d.DEPARTMENT <> 'LANG' OR (d.DEPARTMENT = 'LANG' AND d.Content_ATTR_VALUE <> 33))
			AND esbp.OnsiteTestDuration = '120'
			AND esbp.OnsiteTestDate > @OnsiteTestDateStartAfter
		JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID
			AND rm.FirmwareManaged = 'Y'
			AND EXISTS( SELECT DISTINCT NULL 
			FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp2 JOIN DeepSeaKingdom.dbo.Departments d2 ON d2.Content_ID = esbp2.Content_ID_Parent
				AND d2.DEPARTMENT = 'LANG'
				AND d2.Content_ATTR_VALUE = 33
			WHERE esbp.OnsiteTestDate = esbp2.OnsiteTestDate AND esbp.ShiftStart = esbp2.ShiftStart AND esbp.Latitude = esbp2.Latitude AND esbp.Content_ID_Parent <> esbp2.Content_ID_Parent)

	
	/**********************************************************************
	 * ---------- Check Dummy Parent Schedule (Same Date, Same Shift) ----------
	 * Sampai Row yang bermasalah sudah tidak ada.
	 **********************************************************************/*//*
	SELECT DISTINCT OnsiteTest_parent.OnsiteTestScheduleDateID, OnsiteTest_dummy.OnsiteTestScheduleDateID, OnsiteTest_parent.SCTN_COMBINED_ID, OnsiteTest_dummy.SCTN_COMBINED_ID, OnsiteTest_parent.OnsiteTestDate, OnsiteTest_dummy.OnsiteTestDate, OnsiteTest_parent.ShiftStart, OnsiteTest_dummy.ShiftStart
	FROM (SELECT esbp.* FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID AND rm.FirmwareManaged = 'Y' WHERE (esbp.SCTN_COMBINED_ID IS NULL OR (esbp.SCTN_COMBINED_ID IS NOT NULL AND esbp.Brand_Status = 'Parent'))) OnsiteTest_parent
		LEFT JOIN (SELECT esbp.* FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID AND rm.FirmwareManaged = 'Y' WHERE (esbp.SCTN_COMBINED_ID IS NOT NULL AND esbp.Brand_Status = 'Dummy'))  OnsiteTest_dummy ON OnsiteTest_dummy.SCTN_COMBINED_ID = OnsiteTest_parent.SCTN_COMBINED_ID
		AND OnsiteTest_dummy.OnsiteTestType = OnsiteTest_parent.OnsiteTestType
		AND OnsiteTest_dummy.Orderline = OnsiteTest_parent.Orderline
		AND OnsiteTest_dummy.Department = OnsiteTest_parent.Department
		AND OnsiteTest_dummy.Position = OnsiteTest_parent.Position
		AND OnsiteTest_dummy.TERM = OnsiteTest_parent.TERM
	WHERE OnsiteTest_parent.OnsiteTestDate > @OnsiteTestDateStartAfter
		AND (OnsiteTest_parent.OnsiteTestDate <> OnsiteTest_dummy.OnsiteTestDate OR (OnsiteTest_parent.OnsiteTestDate = OnsiteTest_dummy.OnsiteTestDate AND OnsiteTest_parent.ShiftID <> OnsiteTest_dummy.ShiftID))
	ORDER BY  OnsiteTest_parent.OnsiteTestScheduleDateID
	

	/**********************************************************************
	 * ---------- ---------- Check Constraint Alokasi Ruang ---------- ----------
	 * Sampai Row yang bermasalah sudah tidak ada.
	 **********************************************************************/*//*
	--SELECT * INTO #MasterInLatitude FROM DeepSeaKingdom.WE.V_MasterInLatitude

	SELECT DISTINCT [ContentCodeParent] = caParent.Content_CODE
		, [ContentNameParent] = caParent.Content_TITLE_LONG
		, [ContentCodeDummy] = caDummy.Content_CODE
		, [ContentNameDummy] = caDummy.Content_TITLE_LONG
		, esbp.Department
		, esbp.TERM
		, esbp.OnsiteTestHouse
		, esbp.Brand_SECTION
		, esbp.ShiftStart
		, [ShiftEnd] = DATEADD(MINUTE, esbp.OnsiteTestDuration, esbp.ShiftStart) 
		, esbp.OnsiteTestDate
		, esbp.MLTP
		, esbp.OnsiteTestType
		, esbp.Brand_Status
		, esbp.DESCRSHORT
		, esbp.FacilityID
		, esbp.Latitude
		, esbp.LatitudeAllocation
		, esbp.LOCATION
		, esbp.House
		, eac.Description
		,[AvailableLatitudeForAllocation] = ISNULL('[Galaxy] '+STUFF((SELECT DISTINCT ';'+crs2.LatitudeName FROM DeepSeaKingdom.WE.ContentLatitudeFirmware crs2 WHERE crs2.ContentCode = caParent.Content_CODE AND NOT EXISTS (
	SELECT NULL FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp2 
	WHERE esbp2.Latitude = crs2.LatitudeName 
		AND esbp2.OnsiteTestDate = esbp.OnsiteTestDate 
		AND ((esbp.ShiftStart < DATEADD(MINUTE, esbp2.OnsiteTestDuration, esbp2.ShiftStart)) AND (DATEADD(MINUTE, esbp.OnsiteTestDuration, esbp.ShiftStart) > esbp2.ShiftStart))
	) FOR XML PATH('')),1,1,''),'')+ISNULL('[Manual] '+STUFF((SELECT DISTINCT ';'+ers2.Latitude FROM DeepSeaKingdom.dbo.OnsiteTestLatitudeFirmware ers2 WHERE ers2.ContentCode = caParent.Content_CODE AND NOT EXISTS (
	SELECT NULL FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp2 
	WHERE esbp2.Latitude = ers2.Latitude 
		AND ers2.Valid = 'Y'
		AND ers2.StartTerm = esbp2.TERM
		AND esbp2.OnsiteTestDate = esbp.OnsiteTestDate 
		AND ((esbp.ShiftStart < DATEADD(MINUTE, esbp2.OnsiteTestDuration, esbp2.ShiftStart)) AND (DATEADD(MINUTE, esbp.OnsiteTestDuration, esbp.ShiftStart) > esbp2.ShiftStart))
	) FOR XML PATH('')),1,1,''),'')
	,[AvailableLatitudeByFirmware] = ISNULL('[Galaxy] '+STUFF((SELECT DISTINCT ';'+crs2.LatitudeName FROM DeepSeaKingdom.WE.ContentLatitudeFirmware crs2 WHERE crs2.ContentCode = caParent.Content_CODE FOR XML PATH('')),1,1,''),'')+ISNULL('[Manual] '+STUFF((SELECT DISTINCT ';'+ers2.Latitude FROM DeepSeaKingdom.dbo.OnsiteTestLatitudeFirmware ers2 WHERE ers2.ContentCode = caParent.Content_CODE AND ers2.Valid = 'Y' AND ers2.StartTerm = esbp.TERM FOR XML PATH('')),1,1,''),'')
	FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp
		JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID
			AND rm.FirmwareManaged = 'Y'
			AND esbp.OnsiteTestDate > @OnsiteTestDateStartAfter
		JOIN DeepSeaKingdom.dbo.OnsiteTestAllocationConstraint eac ON eac.Valid = 'Y'
			AND esbp.OnsiteTestDate BETWEEN eac.DateStart AND eac.DateEnd
			AND ((esbp.ShiftStart < CHOOSE(eac.[Shift], '09:00:00', '11:00:00', '13:00:00', '15:00:00', '17:00:00', '19:00:00')) AND (DATEADD(MINUTE, esbp.OnsiteTestDuration, esbp.ShiftStart) > CHOOSE(eac.[Shift], '07:20:00', '09:20:00', '11:20:00', '13:20:00', '15:20:00', '17:20:00')))
			AND IIF(eac.Day IS NULL, '0', DATEPART(WEEKDAY, OnsiteTestDate)-1) = IIF(eac.Day IS NULL, '0', eac.Day)
			AND IIF(eac.Latitude IS NULL, '0', esbp.Latitude) = IIF(eac.Latitude IS NULL, '0', eac.Latitude)
			AND IIF(eac.NumberOfLatitude IS NULL, '0', (SELECT DISTINCT COUNT(DISTINCT rm2.AliasLatitude)
				FROM DeepSeaKingdom.dbo.LatitudeBranch rm2
					JOIN #MasterInLatitude mir ON mir.LatitudeId = rm2.LatitudeId
						AND rm2.FirmwareManaged = 'Y'
				WHERE IIF(CONVERT(VARCHAR(72),eac.LatitudeMasterId) IS NULL, '0', CONVERT(VARCHAR(72),mir.MasterId)) = IIF(CONVERT(VARCHAR(72),eac.LatitudeMasterId) IS NULL, '0', CONVERT(VARCHAR(72),eac.LatitudeMasterId))
					AND IIF(eac.Location IS NULL, '0', rm2.Location) = IIF(eac.Location IS NULL, '0', eac.Location)) - (SELECT DISTINCT COUNT(DISTINCT esbp2.Latitude)
				FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp2 
					JOIN DeepSeaKingdom.dbo.LatitudeBranch rm2 ON rm2.Latitude = esbp2.FacilityID
						AND rm2.FirmwareManaged = 'Y'
					JOIN #MasterInLatitude mir ON mir.LatitudeId = rm2.LatitudeId
				WHERE esbp2.OnsiteTestDate = esbp.OnsiteTestDate 
					AND esbp2.ShiftStart = esbp.ShiftStart
					AND ((esbp2.ShiftStart < CHOOSE(eac.[Shift], '09:00:00', '11:00:00', '13:00:00', '15:00:00', '17:00:00', '19:00:00')) AND (DATEADD(MINUTE, esbp2.OnsiteTestDuration, esbp2.ShiftStart) > CHOOSE(eac.[Shift], '07:20:00', '09:20:00', '11:20:00', '13:20:00', '15:20:00', '17:20:00')))
					AND IIF(CONVERT(VARCHAR(72),eac.LatitudeMasterId) IS NULL, '0', CONVERT(VARCHAR(72),mir.MasterId)) = IIF(CONVERT(VARCHAR(72),eac.LatitudeMasterId) IS NULL, '0', CONVERT(VARCHAR(72),eac.LatitudeMasterId))
					AND IIF(eac.Location IS NULL, '0', esbp2.Location) = IIF(eac.Location IS NULL, '0', eac.Location)
					AND IIF(eac.House IS NULL, '0', esbp2.House) = IIF(eac.House IS NULL, '0', eac.House))) < IIF(eac.NumberOfLatitude IS NULL, '1', eac.NumberOfLatitude)
		JOIN #PS_N_Content_ASSIGN caParent ON esbp.Content_ID_Parent = caParent.Content_ID
		JOIN #PS_N_Content_ASSIGN caDummy ON esbp.Content_ID = caDummy.Content_ID
	ORDER BY OnsiteTestDate, ShiftStart, ShiftEnd

	
	
	/**********************************************************************
	 * 
	 **********************************************************************/*//*
	--SELECT STUFF((SELECT DISTINCT ',['+ea.ShiftStart+']' FROM [ExternalDB].[OnsiteTest_DB].[dbo].[OnsiteTestShift] ea FOR XML PATH ('')),1,1,'')
	SELECT DISTINCT [OnsiteTestDate] = CONVERT(VARCHAR, pvt.OnsiteTestDate,107), pvt.Latitude, [07:20:00],[08:00:00],[08:20:00],[08:30:00],[09:20:00],[09:30:00],[09:40:00],[10:00:00],[10:40:00],[11:00:00],[11:20:00],[11:40:00],[12:00:00],[13:00:00],[13:20:00],[13:30:00],[14:30:00],[14:40:00],[15:00:00],[15:10:00],[15:20:00],[15:30:00],[16:20:00],[16:40:00],[17:00:00],[17:20:00],[18:00:00]
	FROM (SELECT DISTINCT esbp.OnsiteTestDate, esbp.Latitude, esbp.ShiftStart, [FamilyCount] = SUM(esbp.LatitudeAllocation) OVER (PARTITION BY esbp.ShiftStart, esbp.OnsiteTestDate, esbp.Latitude)
	FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp 
		JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID
				AND rm.FirmwareManaged = 'Y' WHERE esbp.OnsiteTestDate > @OnsiteTestDateStartAfter) AS SourceTable PIVOT (MAX(SourceTable.[FamilyCount]) FOR SourceTable.ShiftStart IN ([07:20:00],[08:00:00],[08:20:00],[08:30:00],[09:20:00],[09:30:00],[09:40:00],[10:00:00],[10:40:00],[11:00:00],[11:20:00],[11:40:00],[12:00:00],[13:00:00],[13:20:00],[13:30:00],[14:30:00],[14:40:00],[15:00:00],[15:10:00],[15:20:00],[15:30:00],[16:20:00],[16:40:00],[17:00:00],[17:20:00],[18:00:00])) AS pvt
	ORDER BY OnsiteTestDate, Latitude
	
	SELECT DISTINCT [OnsiteTestDate] = CONVERT(VARCHAR, pvt.OnsiteTestDate,107), pvt.ContentName, [07:20:00],[08:00:00],[08:20:00],[08:30:00],[09:20:00],[09:30:00],[09:40:00],[10:00:00],[10:40:00],[11:00:00],[11:20:00],[11:40:00],[12:00:00],[13:00:00],[13:20:00],[13:30:00],[14:30:00],[14:40:00],[15:00:00],[15:10:00],[15:20:00],[15:30:00],[16:20:00],[16:40:00],[17:00:00],[17:20:00],[18:00:00]
	FROM (SELECT DISTINCT esbp.OnsiteTestDate, crs.ContentName, esbp.ShiftStart, [FamilyCount] = SUM(esbp.LatitudeAllocation) OVER (PARTITION BY esbp.OnsiteTestDate, crs.ContentName, esbp.ShiftStart)
	FROM [DeepSeaKingdom].[WE].[OnsiteTestScheduleBeforePublish] esbp 
	JOIN #PS_N_Content_ASSIGN ca ON esbp.Content_ID_Parent = ca.Content_ID
		JOIN DeepSeaKingdom.dbo.LatitudeBranch rm ON rm.Latitude = esbp.FacilityID
			AND rm.FirmwareManaged = 'Y'
		RIGHT JOIN DeepSeaKingdom.WE.ContentLatitudeFirmware crs ON crs.ContentCode = ca.Content_CODE
			AND crs.LatitudeName = esbp.Latitude
	WHERE esbp.OnsiteTestDate > @OnsiteTestDateStartAfter) AS SourceTable PIVOT (MAX(SourceTable.[FamilyCount]) FOR SourceTable.ShiftStart IN ([07:20:00],[08:00:00],[08:20:00],[08:30:00],[09:20:00],[09:30:00],[09:40:00],[10:00:00],[10:40:00],[11:00:00],[11:20:00],[11:40:00],[12:00:00],[13:00:00],[13:20:00],[13:30:00],[14:30:00],[14:40:00],[15:00:00],[15:10:00],[15:20:00],[15:30:00],[16:20:00],[16:40:00],[17:00:00],[17:20:00],[18:00:00])) AS pvt
	ORDER BY OnsiteTestDate, ContentName
	
	
*/