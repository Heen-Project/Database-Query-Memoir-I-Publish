;------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1620'
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX), @ImportedMarkIngredientBranchTable NVARCHAR(MAX)
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------


/******************************************************************************************
 *				Add or Refresh ManualMarkSummary and ManualBranchDescription
 ******************************************************************************************/
	/**********************************************************************
	 * Harus isi data di ManualBranchDescription dulu baru ManualMarkSummary
	 * ManualMarkSummary Additional Information
		- Kelas Khusus Sudah di Exclude (Ruangan JUR%)
		- Kelas Kelas Theory diambil yang awalan 'L%', Kalau Komponen Lab diambil selain 'L%'
	 * ManualBranchDescription Additional Information
		- Kalo tidak ada GalaxyNumber [GalaxyPercentage] = [Percentage Ingredient]
		- Kalo ada GalaxyNumber [GalaxyPercentage] = [Percentage DetailIngredient] * [Percentage Ingredient]
	 **********************************************************************/
	SET @ImportedMarkIngredientBranchTable = '[DeepSeaKingdom].[WE].[MarkIngredient_Branch_'+@Term+']'
	--EXECUTE [WE].[SP_AddOrRefreshManualBranchDescription] @Term = @Term, @ImportedMarkIngredientBranchTable = @ImportedMarkIngredientBranchTable
	--EXECUTE [WE].[SP_AddOrRefreshManualMarkSummary] @Term
	
	--SELECT * FROM [DeepSeaKingdom].[dbo].[ManualBranchDescription] WHERE Term = @Term --194 Before :: 205, After :: 399
	--SELECT * FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] WHERE Term = @Term ORDER BY 2,3,8,15,13,19 --31648 Before :: 24589, After ::56237


/******************************************************************************************
 *				Update Manual Branch Description for Lab Hardware
 ******************************************************************************************//*
	/**********************************************************************
	 * ManualBranchDescription Percentage
		- GalaxyPercentage, Persentase Komponen Galaxy yang digunakan untuk perhitungan sebelum Marknya di transfer ke LovelySite, Totalnya Harus 100%
		- LovelySitePercentage, Persentase Komponen LovelySite yang diambil dari Table Oracle SYSADM.PS_N_Content_ASSIGN, Seharusnya 100% totalnya, kecuali kalo cuman memiliki satu komponen peMarkan
	 * Untuk periode 1620 ini tidak ada perhitungan khusus (Misal STAT8066[1610], PSYC6018[1610], STAT6109[1610], etc)
	 * Pastikan persentasenya kalau hanya ingin Branch (tidak terdapat kalkukasi) besar persentase di komponen Galaxy dan komponen LovelySite harus sama. (Kalau beda dia akan melakukan kalkulasi di storedprosedure perhitungan berikutnya (untuk keluar Mark biasa maupun Complain Mark))
	 **********************************************************************/
	 --UPDATE mmd SET mmd.GalaxyPercentage = IIF(ABS(CONVERT(FLOAT, mmd.LovelySitePercentage) - CONVERT(FLOAT, mmd.GalaxyPercentage)) < 1, mmd.LovelySitePercentage, mmd.GalaxyPercentage)
	 SELECT IIF(ABS(CONVERT(FLOAT, mmd.LovelySitePercentage) - CONVERT(FLOAT, mmd.GalaxyPercentage)) < 1, mmd.LovelySitePercentage, mmd.GalaxyPercentage),mmd.GalaxyPercentage, mmd.LovelySitePercentage, mmd.* 
	 FROM [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd
	 WHERE mmd.Term = @Term
		AND mmd.WorkshopName = 'Hardware'
		AND mmd.GalaxyNumber IS NOT NULL
		AND mmd.LovelySitePercentage <> mmd.GalaxyPercentage
*/


/******************************************************************************************
 *							Upload HYUS Brand Attributes
 ******************************************************************************************//*
	SELECT DISTINCT [Department] = 'YYS01', [AcadCareer] = 'RS1', [Term] = mss.Term, [ContentID] = mss.ContentID, [BrandNbr] = mss.BrandNbr, [ContentAttribute] = 'HYUS', [ContentAttributeValue] = sr.Ingredient, [Replace] = 'N'
	FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
		JOIN DeepSeaKingdom.dbo.SessionRule sr ON sr.ContentCode = LEFT(mss.ContentName,CHARINDEX('-',mss.ContentName)-1)
			AND sr.QuarterSessionId = mss.QuarterSessionId
			AND mss.Term = @Term
	ORDER BY 1,2,3,4,5,7

	/**
	 * Check yang sudah berhasil terinput
	 **/
	DECLARE @ContentAttribute NVARCHAR(MAX) = 'HYUS'
	DECLARE @OpenQuery NVARCHAR(MAX) = N'SELECT * FROM SYSADM.PS_Brand_ATTRIBUTE ca WHERE ca.Term = '''+@Term+''' AND ca.Content_ATTR = '''+@ContentAttribute+''''
	DECLARE @Query NVARCHAR(MAX) = 'SELECT DISTINCT csprd.*
		FROM OPENQUERY([OPRO],'''+replace(@OpenQuery,'''','''''')+''') csprd'
	EXECUTE (@Query)

	/**
	 * Check yang masih belum berhasil terinput
	 **/
	SET @Query = 'SELECT DISTINCT [Department] = ''YYS01'', [AcadCareer] = ''RS1'', [Term] = mss.Term, [ContentID] = mss.ContentID, [BrandNbr] = mss.BrandNbr, [ContentAttribute] = ''HYUS'', [ContentAttributeValue] = sr.Ingredient, [Replace] = ''N''
		FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss 
			LEFT JOIN OPENQUERY([OPRO],'''+replace(@OpenQuery,'''','''''')+''') csprd ON mss.BrandName = csprd.Brand_SECTION
				AND mss.ContentID = csprd.Content_ID
				AND mss.Term = csprd.Term
			JOIN DeepSeaKingdom.dbo.SessionRule sr ON sr.ContentCode = LEFT(mss.ContentName,CHARINDEX(''-'',mss.ContentName)-1)
				AND sr.QuarterSessionId = mss.QuarterSessionId	
				AND mss.Term = '''+@Term+'''
		WHERE csprd.Term IS NULL
		ORDER BY 1,2,3,4,5,7'
	EXECUTE (@Query)
*/


/**********************************************************************
 *						Update Final OnsiteTest Status
 * Yang tampil atau diupdate datanya dari OnsiteTestPresenceVerification (View Pertama) dan AppendixSchedule (View Kedua)
 * @WorkshopName kalau dikosongin check semua lab
 * @UpdateRepeat = 1, kalau mau diupdate
 * @UpdateRepeat = 0, kalau tidak mau diupdate
 **********************************************************************//*
	EXECUTE [WE].[SP_UpdateOnsiteTestPresencePresenceOnManualMarkSummary] @Term = @Term
		,@WorkshopName = ''
		,@Update = 0
*/