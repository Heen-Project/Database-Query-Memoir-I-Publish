

/******************************************************************************************
 *							Check Material Control Branch
 ******************************************************************************************/
	/**********************************************************************
	 * @Term, ceknya dari Seaweed kalau sebelum 1610 ga ada. Kalau mau cek semua QuarterSession Isi aja dengan Term yang ga ada di Seaweed.
	 **********************************************************************/
	EXECUTE [WE].[SP_CheckMaterialControlBranch] @Term = 'ALL'