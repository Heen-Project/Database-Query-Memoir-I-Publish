--GO
--EXECUTE WE.SP_GenerateFamilyPresenceSummary '1610'


	/**********************************************************************
	 *						Update Final OnsiteTest Status
	 * Yang tampil atau diupdate datanya dari OnsiteTestPresenceVerification (View Pertama) dan AppendixSchedule (View Kedua)
	 * @WorkshopName kalau dikosongin check semua lab
	 * @UpdateRepeat = 1, kalau mau diupdate
	 * @UpdateRepeat = 0, kalau tidak mau diupdate
	 **********************************************************************//*
	EXECUTE [WE].[SP_UpdateOnsiteTestPresencePresenceOnManualMarkSummary] @Term = '1610'
		,@WorkshopName = ''
		,@Update = 0
	*/

/******************************************************************************************
 *					Generate Mark Epitome Appendix (Lampiran)
 ******************************************************************************************//*
	/**********************************************************************
	 * Ambil Filenya di Drive D: [Atlantis]
		\\DeepSeaKingdom\d$
	 **********************************************************************/
	EXECUTE [WE].[SP_ExportMarkEpitomeAppendix] '1610'
*/