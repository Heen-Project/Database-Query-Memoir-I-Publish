;------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1620'
	,@Date NVARCHAR(MAX) = N'2017-05-22'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------

	/****************************************************************************************************
	 * Check New Complain Family - V1 - Update Status from 1 into 2
	 ****************************************************************************************************//*
	--UPDATE spn SET spn.Status = '2'
	SELECT spn.*
	FROM [DeepSeaKingdom].[WE].[V_CheckNewComplain_ExternalDB.Mark_DB.dbo.FamilyComplainMark] spn
	WHERE spn.Term = @Term
		AND spn.DateIn > @Date
	ORDER BY spn.ComplainDate
	*/


	/****************************************************************************************************
	 * Check Complain Family - V2 - Insert CSV into 
	 * Perhatikan Duplicate Count, Berarti untuk 1 komponen Galaxy yang bisa diinput terdapat beberapa komponen LovelySite
	 * Sebisa mungkin diinput diakhir, karna jika mahasiswa memiliki Lebih dari satu komponen LovelySite untuk satu komponen Galaxy. 
		Hari pertama dia Complain komponen pertama dan hari kedua dia Complain untuk komponen kedua atau lebih maka kolom reason akan update (reason-nya berubah / ditambah).
	 * Kalo di MID seharusnya gamungkin duplikat jadi gamasalah langsung insert Galaxy
	 ****************************************************************************************************//*
	EXECUTE [WE].[SP_GenerateMarkComplainToGalaxy] @Term = @Term
	SELECT * FROM DeepSeaKingdom.WE.MarkComplainToGalaxy WHERE InsertedDate > @Date ORDER BY InsertedDate
	*/


	/**********************************************************************
	 * Generate Hasil Mark Complain dari Galaxy
	 **********************************************************************//*
	EXECUTE [WE].[SP_GenerateFamilyMarkComplain] @Term = @Term
	SELECT * FROM DeepSeaKingdom.WE.FamilyMarkComplain
	*/


	/**********************************************************************
	 * @Update = 0 , Ketika mau lihat yang diupdate
		Tampilan Pertama	 : Tampilin yang Akan Keupdate
		Tampilan Kedua		 : Tampilin [ExternalDB].[Mark_DB].[dbo].[FamilyComplainMark] yang ga Keupdate (Atau Ga di process)
		Tampilan Ketiga		 : Tampilin [DeepSeaKingdom].[WE].[FamilyMarkComplain] yang ga Ketemu (Atau Perlu dibuatin Form Perubahan Datanya)
	 * @Update = 1 , Ketika sudah pasti dan mau update
		 Kalo gamau Ganti tanggal PostDatenya, @FamilyComplainMarkPostDate di kosongin aja
		 Pas tampil Hasil Select Yang tampil itu berarti yang dari Tabel [ExternalDB].[Mark_DB].[dbo].[FamilyComplainMark] yang ga keupdate, 
			jadi pastiin outputnya kosong (Tapi bisa aja kasus ga diprocess sama subdev, nanti di check aja case by casenya).
		 Mau Lihat Hasil Yang diupdate lihat dari tabel [DeepSeaKingdom].[WE].[FamilyMarkComplain] kolom [TransferStatus], 
			Kalau Y Berarti Udah diupdate, Kalau N Berarti Perlu dibuatin Form Perubahan data (misalnya temen kelompoknya yang ga pilih Complain Mark di LovelySite, atau lain-nya)
	 * @NewRow = 1, Kalau data yang diinginkan yang dalam durasi 1 bulan terakhir aja, dipakenya buat pisahin dalam 1 QuarterSession yang Mark di akhir QuarterSession dan Mark di tengah QuarterSession
	 * @NewRow = 0, kalau data yang diinginkan semua dalam QuarterSession itu
	 * Kalo buat form perubahan data jangan lupa update di [ExternalDB].[Mark_DB].[dbo].[PS_Family_Mark_DTL_Shop]
	 **********************************************************************//*
	EXECUTE [WE].[SP_TransferFamilyMarkComplain] @Term = @Term
		,@Update = 0
		,@NewRow = 1
--		,@FamilyComplainMarkPostDate = ''
	SELECT * FROM DeepSeaKingdom.WE.FamilyMarkComplain ssp WHERE ssp.TransferStatus = 'N'
	*/