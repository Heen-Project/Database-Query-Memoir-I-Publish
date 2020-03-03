;------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1620'
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------


/**********************************************************************
 *						Update Final OnsiteTest Status
 * Yang tampil atau diupdate datanya dari OnsiteTestPresenceVerification (View Pertama) dan AppendixSchedule (View Kedua)
 * @WorkshopName kalau dikosongin check semua lab
 * @UpdateRepeat = 1, kalau mau diupdate
 * @UpdateRepeat = 0, kalau tidak mau diupdate
 **********************************************************************//*
	EXECUTE [WE].[SP_UpdateOnsiteTestPresencePresenceOnManualMarkSummary] @Term = @Term
		--,@WorkshopName = 'Firmware'
		,@Update = 1
*/


/******************************************************************************************
 *							Generate Required Data 
 ******************************************************************************************//*
	EXECUTE [WE].[SP_GenerateFamilyMarkSummaryGalaxy] @Term
	EXECUTE [WE].[SP_GenerateFamilyPresenceSummary] @Term
*/


/******************************************************************************************
 *					Generate Mark Epitome Appendix (Lampiran)
 ******************************************************************************************/
	/**********************************************************************
	 * Ambil Filenya di Drive D: [Atlantis]
		\\DeepSeaKingdom\d$
	 * Check di Tab 'Messages' (Sebelah Kanan Tab Result - Grid Result)
		-- Kalo misalnya length-nya = 8000, berarti udah mencapai batas string query-nya jadi ga ke export, maka store procedurenya jalanin execute query (copy hasil select terus masukin ke excel)
		-- Kalo misalnya ada error di hasil tampilan select-nya ada row ke 8 biasanya. kalo berhasil cuman sampai 7 dan isinya null di row ke 7-nya
	 **********************************************************************//*
	EXECUTE [WE].[SP_ExportOverviewReportLovelySiteIngredient] @Term
	EXECUTE [WE].[SP_ExportOverviewReportGalaxyIngredient] @Term
*/