;------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1620'
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------


	/******************************************************************************************
	 *								Generate Required Data 
	 ******************************************************************************************//*
	EXECUTE WE.SP_GenerateFamilyMarkSummaryGalaxy @Term
	EXECUTE WE.SP_GenerateFamilyMarkDetailGalaxy @Term
*/


	/**********************************************************************
	 * ----------  ---------- Update Manual Mark Summary ---------- ----------
	 * @Update = 0, Kalo misalnya mau liat yang bakal kena update. Jadi cek selisihnya kalo yang ini, kalo ga ada yang beda row-nya 0.
	 * @Update = 1, Kalo misalnya mau update Mark-nya.
	 * @MidTermOnly = 1, Kalo misalnya cuman mau update Mark MID aja
	 * @MidTermOnly = 0, Kalo misalnya cuman mau update semuanya
	 **********************************************************************//*
	EXECUTE [WE].[SP_UpdateManualMarkSummary] @Term = @Term
		,@MidTermOnly = 0
		,@Update = 0
*/


	/**********************************************************************
	 * ----------  Transfer Mark from Galaxy to LovelySite ----------
	 * @LamBrandActvPostDate : Diisikan dengan tanggal pertama seharusnya posting (Tanggal Initial, bukan tanggal publish Complain maupun lain-nya). Kalau tidak mau ada perubahan ketika publish hasil Complain Mark atau konfirmasi berkas, maka jangan diisi.
		Misal: @LamBrandActvPostDate = '2017-08-01 11:00:00.000'
	 * @FamilyMarkDtlSubmitDate : Diisikan dengan tanggal tampil berikutnya (Tanggal Mulai ComplainMark), kalau ga mau diganti jangan diisi.
		Misal: @FamilyMarkDtlSubmitDate = '2017-08-01 11:00:00.000'
	 * @Update = 0, Kalo misalnya mau liat yang bakal kena update. Jadi cek selisihnya kalo yang ini, kalo ga ada yang beda row-nya 0.
	 * @Update = 1, Kalo misalnya mau update Mark-nya.
	 **********************************************************************//*
	EXECUTE [WE].[SP_UpdateLamBrandActvAndFamilyMarkDtl] @Term = @Term
		,@Update = 0
		--,@LamBrandActvPostDate = '2017-08-01 11:00:00.000'
		--,@FamilyMarkDtlSubmitDate = '2017-08-01 11:00:00.000'
		,@ASCID = '1701301076'
		,@ExcludeMemberYY = ''
--		,@ExcludeMemberNumber = ''
*/


	/**********************************************************************
	 *						Check Update History
	 **********************************************************************//*
	SELECT * FROM DeepSeaKingdom.dbo.History_LAM_Brand_ACTV ORDER BY InsertedDate DESC
	SELECT * FROM DeepSeaKingdom.dbo.History_Family_Mark_DTL ORDER BY InsertedDate DESC
*/

--SELECT COUNT (GalaxyIngredient) OVER (PARTITION BY ContentID, LovelySiteIngredient), COUNT (LovelySiteIngredient) OVER (PARTITION BY ContentID, GalaxyIngredient+''+CONVERT(VARCHAR,COALESCE(GalaxyNumber,''))),* FROM ManualBranchDescription WHERE TERM = '1610' ORDER BY 1 DESC,2 DESC,5,7,9