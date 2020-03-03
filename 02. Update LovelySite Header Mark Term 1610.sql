;------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1610'
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------


--EXECUTE WE.SP_GenerateFamilyMarkSummaryGalaxy @Term
--EXECUTE WE.SP_GenerateFamilyMarkDetailGalaxy @Term
--EXECUTE WE.SP_GenerateFamilyPresenceSummary @Term


/******************************************************************************************
 *							Update Manual Mark Summary
 ******************************************************************************************//*
	/**********************************************************************
	 * @Update = 0, Kalo misalnya mau liat yang bakal kena update. Jadi cek selisihnya kalo yang ini, kalo ga ada yang beda row-nya 0.
	 * @Update = 1, Kalo misalnya mau update Mark-nya.
	 **********************************************************************/
	EXECUTE [WE].[SP_UpdateManualMarkSummary] @Term = @Term, @Update = 0	--Update :: 1 Row(s) 09-05-2017
	

 	/**********************************************************************
	 * @LamBrandActvPostDate : Diisikan dengan tanggal pertama seharusnya posting (Tanggal Initial, bukan tanggal publish Complain maupun lain-nya). Kalau tidak mau ada perubahan ketika publish hasil Complain Mark atau konfirmasi berkas, maka jangan diisi.
		Misal: @LamBrandActvPostDate = '2017-05-19 11:00:00.000'
	 * @FamilyMarkDtlSubmitDate : Diisikan dengan tanggal tampil berikutnya (Tanggal Mulai ComplainMark), kalau ga mau diganti jangan diisi.
		Misal: @FamilyMarkDtlSubmitDate = '2017-05-19 11:00:00.000'
	 * @Update = 0, Kalo misalnya mau liat yang bakal kena update. Jadi cek selisihnya kalo yang ini, kalo ga ada yang beda row-nya 0.
	 * @Update = 1, Kalo misalnya mau update Mark-nya.
	 **********************************************************************/
	EXECUTE [WE].[SP_UpdateLamBrandActvAndFamilyMarkDtl] @Term = @Term
		,@Update = 0
		,@ASCID = '1701301076'
*/