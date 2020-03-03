;------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1620'
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------


	/******************************************************************************************
	 *						Request IT to Generate Header 
	 ******************************************************************************************//*
	-- UTP Information System
	---------- UTP Parent [ISYS6212]
	-- UTP Management
	---------- UTP Parent [STAT8068, J1574, STAT6079, MGMT6036, J1186] :: Dummy [J0682]
	---------- UTS Parent [COMP6203, COMP6177, J0292] :: Dummy []
	-- UTP Marketing Communication - Public Relation
	---------- UTP Parent [COMM6130]
	SELECT DISTINCT [KDMTK] = LEFT(mss.TopicName, CHARINDEX('-',mss.TopicName)-1), [BrandNbr] = mss.BrandNbrTheory, mss.ContentID, [Ingredient] = sr.Ingredient
	FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
		JOIN DeepSeaKingdom.dbo.ManualBranchDescription mmd ON mss.ContentIDParent = mmd.ContentID
			AND mss.Term = mmd.Term
			AND mss.LovelySiteIngredient = mmd.LovelySiteIngredient
			AND mss.Term = @Term
		JOIN DeepSeaKingdom.dbo.SessionRule sr ON sr.ContentCode = LEFT(mss.ContentName, CHARINDEX('-',mss.ContentName)-1)
			AND sr.QuarterSessionId = mss.QuarterSessionId
	WHERE mmd.GalaxyIngredient = 'MidTerm'
	ORDER BY 4,3,2
	*/



/******************************************************************************************
 *						Update and Check Generated Lam Brand Actv Lab
 ******************************************************************************************//*
	/**********************************************************************
	 * @GalaxyIngredient : Di-isi dengan komponen Galaxy yang ingin dilihat selisih data dari Tabel ManualMarkSummary dengan Tabel LamBrand LovelySite, jika tidak diisi maka yang di check adalah komponen peMarkan LovelySite yang telah digenerate oleh biro Mark yang belum di generate ke table temporary untuk HYU (oleh IT DIV)
		Misal :: @GalaxyIngredient = '''FinalTerm'',''Responsibility'',''Venture''', Untuk Semua Komponen Selain Midterm
			 @GalaxyIngredient = '''MidTerm''', Untuk Komponen Midterm
		Note :: Kalo Misalnya Ada Branch One-to-Many, Atau Many-to-One, Jumlahnya jangan dijadiin patokan (Kalo Ada Kasus Seperti itu Checknya dari Jumlah di Table [DeepSeaKingdom].[dbo].[ManualMarkSummary])
	 * @UpdateRepeat = 1, Kalau mau diupdate ulang semua sequence-nya
	 * @UpdateRepeat = 0, kalau mau diupdate yang belum ada sequence-nya aja
	 * [WE].[SP_UpdateAndCheckLamBrandActv] : SELECT selisih data dari Tabel ManualMarkSummary dengan Tabel LamBrand LovelySite, pastiin selisih datanya sudah tidak (0 Row)
	 **********************************************************************/
	EXECUTE [WE].[SP_UpdateAndCheckLamBrandActv] @Term = @Term
		,@GalaxyIngredient = ''
		,@UpdateRepeat = 0
		-- Mid :: 2422 

	/**********************************************************************
	 * @ExcludeMemberYY : Diisi untuk Mengexclude Mahasiswa Menggunakan MemberYY, Karena DropOut atau Mengundurkan Diri atau lain sebagainya
		Misal :: @ExcludeMemberYY = '''1501155001'', ''YY000215996'', ''YY001054903'', ''YY001057230'', ''YY001081324'', ''YY001134886'', ''YY001135434'', ''YY001161602'', ''YY001161874'''
	 * @ExcludeMemberNumber : Diisi untuk Mengexclude Mahasiswa Menggunakan MemberXXX, Karena DropOut atau Mengundurkan Diri atau lain sebagainya
		Misal :: @ExcludeMemberNumber = ''1501155001'', ''1901483074'', ''2001581646'', ''2001583216'', ''2001590133'', ''2001602032'', ''2001602631'', ''2001618485'', ''2001618724''
	 ** Pilih salah satu aja, mau excludenya pake XXX ato YY
	 **********************************************************************/
	EXECUTE [WE].[SP_CheckFamilyMarkDtl] @Term = @Term
		,@ExcludeMemberYY = ''
--		,@ExcludeMemberNumber = ''
		-- Mid :: 2422
*/


	/******************************************************************************************
	 *					Check Blocked Mark In LAM_Brand_ACTV (MID 1620 :: 120 rows)
	 ******************************************************************************************//*
	--Check Based on Family from ManualMarkSummary
	SELECT DISTINCT lca.Term, lca.Brand_NBR, lca.Orderline, lca.DESCR, lca.Content_ID, lca.ASCID, lca.N_MarkR
	FROM [ExternalDB].[Mark_DB].[dbo].[LAM_Brand_ACTV] lca
		JOIN DeepSeaKingdom.dbo.ManualMarkSummary mss ON lca.Brand_NBR = mss.BrandNbrTheory
			AND lca.Orderline = mss.Orderline
			AND lca.Term = mss.Term
			AND lca.Term = @Term
	WHERE (lca.ASCID <> '' AND lca.ASCID <> 'A0001') -- Belum di Block
	UNION
	SELECT DISTINCT lca.Term, lca.Brand_NBR, lca.Orderline, lca.DESCR, lca.Content_ID, lca.ASCID, lca.N_MarkR
	FROM [ExternalDB].[Mark_DB].[dbo].[LAM_Brand_ACTV] lca
		JOIN DeepSeaKingdom.dbo.ManualMarkSummary mss ON lca.Brand_NBR = mss.BrandNbrTheory
			AND lca.Orderline = mss.Orderline
			AND lca.Term = mss.Term
			AND lca.Term = @Term
	WHERE lca.N_MarkR <> 'ASTL' AND (lca.ASCID <> '' AND lca.ASCID <> 'A0001') -- Sudah Ke Block (Sejak di turunkan dari BCS), tapi belum ganti N_MarkR-nya

	SELECT DISTINCT lca.Term, lca.Brand_NBR, lca.Orderline, lca.DESCR, lca.Content_ID, lca.ASCID, lca.N_MarkR
	FROM [ExternalDB].[Mark_DB].[dbo].[LAM_Brand_ACTV] lca
		JOIN DeepSeaKingdom.dbo.ManualMarkSummary mss ON lca.Brand_NBR = mss.BrandNbrTheory
			AND lca.Orderline = mss.Orderline
			AND lca.Term = mss.Term
			AND lca.Term = @Term
	WHERE lca.N_MarkR = 'ASTL' AND (lca.ASCID <> '' AND lca.ASCID <> 'A0001') -- Kalau Sudah Di Block Dengan Baik

	--Check Based on Generated LamBrand from LAM_Brand_ACTV_Shop
	SELECT DISTINCT lca.Term, lca.Brand_NBR, lca.Orderline, lca.DESCR, lca.Content_ID, lca.ASCID, lca.N_MarkR
	FROM [ExternalDB].[Mark_DB].[dbo].[LAM_Brand_ACTV] lca
		JOIN [ExternalDB].[Mark_DB].[dbo].[LAM_Brand_ACTV_Shop] lcal ON lca.Brand_NBR = lcal.Brand_NBR
			AND lca.Orderline = lcal.Orderline
			AND lca.Term = lcal.Term
			AND lca.Content_ID = lcal.Content_ID
			AND lca.Term = @Term
	WHERE (lca.ASCID <> '' AND lca.ASCID <> 'A0001') -- Belum di Block
	--WHERE lca.N_MarkR <> 'ASTL' AND lca.ASCID = '' -- Sudah Ke Block (Sejak di turunkan dari BCS), tapi belum ganti N_MarkR-nya
	--WHERE lca.N_MarkR = 'ASTL' AND lca.ASCID = ''  -- Kalau Sudah Di Block Dengan Baik
*/


	/******************************************************************************************
	 *								Generate Required Data 
	 ******************************************************************************************//*
		EXECUTE WE.SP_GenerateFamilyMarkSummaryGalaxy @Term
		EXECUTE WE.SP_GenerateFamilyMarkDetailGalaxy @Term
	*/


	/******************************************************************************************
	 *							Check Input Mark to Galaxy 
	 ******************************************************************************************//*
	-- UTP Information System
	---------- UTP Parent [ISYS6212]
	-- UTP Management
	---------- UTP Parent [STAT8068, J1574, STAT6079, MGMT6036, J1186] :: Dummy [J0682]
	---------- UTS Parent [COMP6203, COMP6177, J0292] :: Dummy []
	-- UTP Marketing Communication - Public Relation
	---------- UTP Parent [COMM6130]
	SELECT DISTINCT sss.ContentOutline, sss.AssociateCode, sss.AssociateName, sss.BrandName
	FROM DeepSeaKingdom.WE.FamilyMarkSummary sss 
	WHERE ISNUMERIC(sss.MidTerm) <> 1 
		AND LEFT(sss.ContentOutline, CHARINDEX('-',sss.ContentOutline)-1) IN (SELECT DISTINCT mmd.ContentCode FROM ManualBranchDescription mmd WHERE mmd.Term = @Term AND (mmd.GalaxyIngredient = 'MidTerm' OR mmd.LovelySiteIngredient LIKE '%MID%')) --26 rows
		--AND LEFT(sss.ContentOutline, CHARINDEX('-',sss.ContentOutline)-1) IN ('ISYS6212')
		--AND LEFT(sss.ContentOutline, CHARINDEX('-',sss.ContentOutline)-1) IN ('STAT8068', 'J1574', 'STAT6079', 'MGMT6036', 'J1186','COMP6203', 'COMP6177', 'J0292') --15 rows
		--AND LEFT(sss.ContentOutline, CHARINDEX('-',sss.ContentOutline)-1) IN ('COMM6130') --11 rows
	*/