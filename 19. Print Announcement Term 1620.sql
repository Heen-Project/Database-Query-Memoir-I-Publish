
DECLARE @House NVARCHAR(MAX) = 'CSKMG', @Term NVARCHAR(MAX) = '1620', @QuarterSessionId NVARCHAR(MAX)
;------------------------------
--SELECT * INTO #PS_N_Family_PRSNLDT FROM OPENQUERY ([OPRO], 'SELECT * FROM PS_N_Family_PRSNLDT WHERE Department = ''YYS01'' AND Position = ''RS1''')
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------
--SELECT * INTO #AssesmentIngredient 
--FROM DeepSeaKingdom.WE.UDFTV_AssesmentIngredientVerticalDetail(@QuarterSessionId)
;------------------------------
--SELECT DISTINCT ',[Mark' + ec.[Type]+RIGHT('00'+ec.Number,2)+']' FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH('')
--;------------------------------
--SELECT DISTINCT ',[Status' + ec.[Type]+RIGHT('00'+ec.Number,2)+']' FROM (SELECT DISTINCT Assesment.[Type], Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH('')
;------------------------------

SELECT DISTINCT [FamilyID] = pnsp.EXTERNAL_SYSTEM_ID
	,[Name] = pnsp.NAME
	,[Brand] = RTRIM(LEFT(galaxion.BrandName,5))
	,[Topic] = mss.TopicName
	,[Reason] = 'Late'
	,[Mark Type] = galaxion.Type + ' ' + CONVERT(VARCHAR,galaxion.Number)
	,[Mark] = '0'
FROM [Temporary].[WE].[Firmware_GalaxionMark_1620] galaxion
	JOIN DeepSeaKingdom.dbo.ManualMarkSummary mss ON mss.MemberNumber = galaxion.MemberNumber
		AND mss.ContentName = galaxion.ContentName
		AND mss.Term = @Term
		AND galaxion.MarkAtGalaxy > 0 
		AND galaxion.StatusAtGalaxy = 'A' 
		AND galaxion.StatusMoving = 'Move Success'
	LEFT JOIN #PS_N_Family_PRSNLDT pnsp ON pnsp.EXTERNAL_SYSTEM_ID = galaxion.MemberNumber
WHERE pnsp.House = @House
UNION 
SELECT DISTINCT [FamilyID] = pnsp.EXTERNAL_SYSTEM_ID
	,[Name] = pnsp.NAME
	,[Brand] = sszc.BrandName
	,[Topic] = sszc.[Topic]
	,[Reason] = 'Venture Cheating'
	,[Mark Type] = 'Practicum'
	,[Mark] = sszc.MarkAfter
FROM [Temporary].[WE].[Firmware_FamilyMarkZeroingCheating_1620] sszc
	LEFT JOIN #PS_N_Family_PRSNLDT pnsp ON pnsp.EXTERNAL_SYSTEM_ID = sszc.FamilyNumber
WHERE pnsp.House = @House
UNION 
SELECT DISTINCT [FamilyID] = pnsp.EXTERNAL_SYSTEM_ID
	,[Name] = pnsp.NAME
	,[Brand] = unpvt2.BrandName
	,[Topic] = unpvt2.TopicName
	,[Reason] = 'No File'
	,[Mark Type] = CASE WHEN unpvt2.MarkType LIKE '%Responsibility%' THEN 'Responsibility '+ CONVERT(VARCHAR,CONVERT(FLOAT,RIGHT(unpvt2.MarkType,2)))
		WHEN unpvt2.MarkType LIKE '%FinalTerm%' THEN 'Final OnsiteTest'
		WHEN unpvt2.MarkType LIKE '%MidTerm%' THEN 'Mid OnsiteTest'
		WHEN unpvt2.MarkType LIKE '%Venture%' THEN 'Venture' END
	,[Mark] = '0' 
FROM (SELECT * FROM DeepSeaKingdom.WE.FamilyMarkDetail ssd) AS SourceTable 
	UNPIVOT (Mark FOR MarkType IN ([MarkResponsibility01],[MarkResponsibility02],[MarkResponsibility03],[MarkResponsibility04],[MarkResponsibility05],[MarkResponsibility06],[MarkResponsibility07],[MarkResponsibility08],[MarkResponsibility09],[MarkResponsibility10],[MarkResponsibility11],[MarkResponsibility12],[MarkResponsibility13],[MarkFinalTerm01],[MarkMidTerm01],[MarkVenture01],[MarkVenture02])) unpvt1
	UNPIVOT ([Status] FOR StatusType IN ([StatusResponsibility01],[StatusResponsibility02],[StatusResponsibility03],[StatusResponsibility04],[StatusResponsibility05],[StatusResponsibility06],[StatusResponsibility07],[StatusResponsibility08],[StatusResponsibility09],[StatusResponsibility10],[StatusResponsibility11],[StatusResponsibility12],[StatusResponsibility13],[StatusFinalTerm01],[StatusMidTerm01],[StatusVenture01],[StatusVenture02])) unpvt2
	LEFT JOIN #PS_N_Family_PRSNLDT pnsp ON pnsp.EXTERNAL_SYSTEM_ID = unpvt2.MemberNumber
WHERE REPLACE(unpvt2.MarkType, 'Mark','') = REPLACE(unpvt2.StatusType, 'Status','') AND pnsp.House = @House AND unpvt2.WorkshopName = 'Firmware' AND unpvt2.[Status] = 'NF' AND unpvt2.Term = @Term
UNION 
SELECT DISTINCT [FamilyID] = pnsp.EXTERNAL_SYSTEM_ID
	,[Name] = pnsp.NAME
	,[Brand] = sidz.BrandName
	,[Topic] = sidz.TopicName
	,[Reason] = 'In Loan'
	,[Mark Type] = CASE WHEN sidz.Ingredient = 'Responsibility' THEN 'Responsibility '+ CONVERT(VARCHAR,CONVERT(FLOAT,RIGHT(sidz.ResponsibilityNumber,2)))
		WHEN sidz.Ingredient = 'FinalTerm' THEN 'Final OnsiteTest'
		WHEN sidz.Ingredient = 'MidTerm' THEN 'Mid OnsiteTest'
		WHEN sidz.Ingredient = 'Venture' THEN 'Venture' END
	,[Mark] = '0'
FROM DeepSeaKingdom.WE.FamilyInLoanRemoved sidz
	LEFT JOIN #PS_N_Family_PRSNLDT pnsp ON pnsp.EXTERNAL_SYSTEM_ID = sidz.MemberNumber
WHERE pnsp.House = @House AND sidz.Term = @Term

--Yang dari QMAN tambahin manual aja, soalnya bisa berubah kalo ambil dr table(Items) jadi agak rancu 