--GO
--EXECUTE WE.SP_GenerateFamilyPresenceSummary '1610'
--GO
--EXECUTE WE.SP_GenerateFamilyMarkDetailGalaxy '1610'
--GO
--EXECUTE WE.SP_GenerateFamilyMarkSummaryGalaxy '1610'

/******************************************************************************************
 *				Generate AssistantFamilyMark and AssistantFamilyPassingPercentage
 ******************************************************************************************//*
	GO
	/**********************************************************************
	 * @ExcludeMemberXXX : Exclude Mahasiswa di semua Matakuliahnya (Agar tidak masuk kedalam perhitungan),
			Misalnya Piutang yang XXXN-nya kemarin kena Loan Zeroing tapi sudah ga terdaftar di  View SYSADM.PS_N_SF_OUTSTAND
	 * @ExcludeMemberXXXTopicCodeBrandName : Exclude Mahasiswa di matakuliah tertentu (Agar tidak masuk kedalam perhitungan),
			Misalnya Teguran yang tidak ada status entry 'C', 'NF', 'A' karena tidak membawa KMK atau sejenisnya
	 **********************************************************************/
	--SELECT STUFF((SELECT DISTINCT ','''''+Loan.EXTERNAL_SYSTEM_ID+'''''' FROM DeepSeaKingdom.WE.FamilyInLoan_1610 Loan WHERE NOT EXISTS(SELECT NULL FROM OPENQUERY([OPRO],'SELECT DISTINCT * FROM SYSADM.PS_N_SF_OUTSTAND WHERE ITEM_TERM = ''1610''') o WHERE o.EXTERNAL_SYSTEM_ID = RTRIM(Loan.EXTERNAL_SYSTEM_ID)) FOR XML PATH('')),1,1,'')

	EXECUTE WE.SP_GenerateAssistantFamilyPassingPercentage @Term = '1610'
		,@ExcludeMemberXXX = '''1601276893'',''1701357084'',''1701363130'',''1801393696'',''1801409416'',''1801410784'',''1801414504'',''1801424814'',''1801427053'',''1801434001'',''1801448695'',''1901520523'',''1901530801'',''1901534636'',''2001545602'',''2001547425'',''2001548056'',''2001549916'',''2001551063'',''2001560250'',''2001564785'',''2001564936'',''2001567370'',''2001575504'',''2001578393'',''2001583733'',''2001584231'',''2001589466'',''2001593154'',''2001596282'',''2001597631'',''2001597700'',''2001598174'',''2001599832'',''2001600342'',''2001601484'',''2001601686'',''2001601976'',''2001602562'',''2001604095'',''2001608420'',''2001608805'',''2001609524'',''2001609921'',''2001611661'',''2001611825'',''2001612891'',''2001613332'',''2001613875'',''2001614133'',''2001616473'',''2001617154'',''2001618472'',''2001619720'',''2001620703'',''2001621201'',''2001623200'',''2001623365'',''2001625074'''
		,@ExcludeMemberXXXTopicCodeBrandName = '''1801378796,BY01,COMP6153'',''1801397366,BY01,COMP6153'',''1901528122,BP01,6169'''
*/

/******************************************************************************************
 *							Data Assistant Terkait Mark Mahasiswa
 ******************************************************************************************//*
	GO
	SELECT * 
	FROM DeepSeaKingdom.WE.AssistantFamilyMark
	ORDER BY Personname, ContentName, BrandName, TopicName, MemberNumber
	GO
	SELECT * 
	FROM DeepSeaKingdom.WE.AssistantFamilyPassingPercentage
	ORDER BY Personname
*/
-- Note : Kalau mau sampling, sampling mahasiswa yang Marknya 0. Biasa di cekin sama Ci ND yang Marknya 0