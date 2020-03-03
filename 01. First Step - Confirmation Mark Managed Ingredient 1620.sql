/******************************************************************************************
 * 								Check Managed Mark - Before
 ******************************************************************************************//*
SELECT sr.*
FROM DeepSeaKingdom.dbo.SessionRule sr
	JOIN Seaweed.dbo.QuarterSessions ON QuarterSessions.QuarterSessionId = sr.QuarterSessionId
WHERE QuarterSessions.Period = '1620'
	AND sr.ContentCode IN 
		--('M0054','M0086','ISYS6163','ISYS6191','ISYS6209','ISYS6188') --(6/6) Information System
		--('O0704','O0824','COMM6096','COMM6085','COMM6086','DSGN6185') --(6/6) Marketing Communication Broadcast
		--('COMM6130','COMM6118','COMM6109','COMM6123','COMM6125','COMM6121','COMM6111','COMM6151','COMM6117') --(9/9) Marketing Communication Public Relation
		--('J0302','J0312','COMP6177','COMP6203') --(4/4) Management Theory
		--('STAT6079','MGMT6036','J1574','STAT8068') --(4/4) Management Practicum
		--('SCIE6005','CPEN6081','CPEN6083','CPEN6085','CPEN6084','CPEN6066','CPEN6086','SCIE6028') --(8/8) Hardware
		--('CIVL6023','CIVL6027','CIVL6066') --(3/3) Civil Engineering
		--('') --(0/0) Psychology
		--('COMP6064','COMP6114','COMP6120','COMP6132','COMP6175','COMP6176','COMP6178','COMP6183','COMP6225','COMP6233','COMP6268','COMP7066','COMP7084','COMP7094','COMP7110','COMP7116','COMP8108','CPEN6046','CPEN6098','CPEN6101','CPEN6102','CPEN6108','CPEN6109','CPEN8076','H0493','H0515','ISYS6078','ISYS6084','ISYS6123','ISYS6169','ISYS6172','ISYS6197','ISYS6203','ISYS6211','ISYS6279','ISYS6280','M0114','M0564','MOBI6002','MOBI6009','T0044','T0053','T0206','T0233','T0273','T0293','T0593','T1404','T1464') --(49/49) Firmware
*//******************************************************************************************
 *								Check Managed Mark - Before
 ******************************************************************************************//*
--UPDATE sr 
SET sr.MarkManaged = 'Y' 
FROM DeepSeaKingdom.dbo.SessionRule sr
	JOIN Seaweed.dbo.QuarterSessions ON QuarterSessions.QuarterSessionId = sr.QuarterSessionId
WHERE QuarterSessions.Period = '1620'
	--AND sr.Shop = 'Firmware' --(51)
	AND sr.ContentCode IN 
		--('M0054','M0086','ISYS6163','ISYS6191','ISYS6209','ISYS6188') --(6/6) Information System
		--('O0704','O0824','COMM6096','COMM6085','COMM6086','DSGN6185') --(6/6) Marketing Communication Broadcast
		--('COMM6130','COMM6118','COMM6109','COMM6123','COMM6125','COMM6121','COMM6111','COMM6151','COMM6117') --(9/9) Marketing Communication Public Relation
		--('J0302','J0312','COMP6177','COMP6203') --(4/4) Management Theory
		--('STAT6079','MGMT6036','J1574','STAT8068') --(4/4) Management Practicum
		--('SCIE6005','CPEN6081','CPEN6083','CPEN6085','CPEN6084','CPEN6066','CPEN6086','SCIE6028') --(8/8) Hardware
		--('CIVL6023','CIVL6027','CIVL6066') --(3/3) Civil Engineering
		--('') --(0/0) Psychology
		--('COMP6064','COMP6114','COMP6120','COMP6132','COMP6175','COMP6176','COMP6178','COMP6183','COMP6225','COMP6233','COMP6268','COMP7066','COMP7084','COMP7094','COMP7110','COMP7116','COMP8108','CPEN6046','CPEN6098','CPEN6101','CPEN6102','CPEN6108','CPEN6109','CPEN8076','H0493','H0515','ISYS6078','ISYS6084','ISYS6123','ISYS6169','ISYS6172','ISYS6197','ISYS6203','ISYS6211','ISYS6279','ISYS6280','M0114','M0564','MOBI6002','MOBI6009','T0044','T0053','T0206','T0233','T0273','T0293','T0593','T1404','T1464') --(49/49) Firmware
*//******************************************************************************************
 *							Revert Back Confirm Status Back to Zero
 ******************************************************************************************//*
--UPDATE /*sr*/ 
--SET sr.MarkManaged = 'N' 
--FROM DeepSeaKingdom.dbo.SessionRule sr
--	JOIN Seaweed.dbo.QuarterSessions ON QuarterSessions.QuarterSessionId = sr.QuarterSessionId
--WHERE QuarterSessions.Period = '1620' --133 (2017-03-23) :: [Revalidate]
*/


---------------------------------------------------------------------------------------------------- ===== ===== ----------------------------------------------------------------------------------------------------
--																						Query yang dipake, query yang di bawah
---------------------------------------------------------------------------------------------------- ===== ===== ----------------------------------------------------------------------------------------------------

DECLARE @Term NVARCHAR(MAX), @WorkshopName NVARCHAR(MAX), @QuarterSessionId NVARCHAR(MAX)
SET @Term = '1620'
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term


/******************************************************************************************
 *							Check Managed Mark - After [Fixed]
 ******************************************************************************************//*
SELECT DISTINCT sr.*
FROM DeepSeaKingdom.dbo.SessionRule sr
	JOIN Seaweed.dbo.QuarterSessions ON QuarterSessions.QuarterSessionId = sr.QuarterSessionId
WHERE QuarterSessions.Period = @Term
	AND sr.MarkManaged = 'Y' --91 Rows (2017-03-23)
ORDER BY Sr.Shop, Sr.Ingredient

--SELECT sr.*
--FROM DeepSeaKingdom.dbo.SessionRule sr
--	JOIN Seaweed.dbo.QuarterSessions ON QuarterSessions.QuarterSessionId = sr.QuarterSessionId
--WHERE QuarterSessions.Period = @Term
--	AND sr.ContentCode IN 
--		--('CIVL6023','CIVL6027','CIVL6066') -- (3/3) Civil Engineering :: Dummy []
--		--('SCIE6005','CPEN6066','SCIE6028','CPEN6084','CPEN6081','CPEN6085','CPEN6083','H0593') -- (8/8) Hardware :: Dummy []
--		--('ISYS6163','ISYS6188','ISYS6209','ISYS6191','ISYS6212') -- (5/5) Information System :: Dummy [M0086, A1424, M0126, M1006]
--		--('COMP6203','COMP6177','J0292') -- (3/3) Management - Theory :: Dummy [J0302, J0312, J0682, O0712]
--		--('J1574','STAT6079','MGMT6036','STAT8068','J1186') -- (5/5) Management - Practicum :: Dummy []
--		--('DSGN6185','COMM6085','COMM6096','COMM6086') -- (4/4) Marketing Communication - Broadcast :: Dummy [O0824, O0704] >>COMM6096::Duplicates
--		--('COMM6121','COMM6151','COMM6123','COMM6130','COMM6117','COMM6109','COMM6118','COMM6125','COMM6111','DSGN6279','DSGN6188','COMM6096') -- (12/12) Marketing Communication - Public Relation :: Dummy [] >>COMM6096::Duplicates
--		--('') -- (0/0) Psychology :: Dummy []
--		--('COMP6064','COMP6114','COMP6120','COMP6132','COMP6175','COMP6176','COMP6178','COMP6183','COMP6225','COMP6233','COMP6268','COMP7066','COMP7084','COMP7094','COMP7110','COMP7116','COMP8108','CPEN6046','CPEN6098','CPEN6101','CPEN6102','CPEN6108','CPEN6109','CPEN8076','H0493','H0515','ISYS6078','ISYS6084','ISYS6123','ISYS6169','ISYS6172','ISYS6197','ISYS6203','ISYS6211','ISYS6279','ISYS6280','M0114','M0564','MOBI6002','MOBI6009','T0044','T0053','T0123','T0206','T0233','T0273','T0293','T0316','T0593','T1404','T1464','T2334') -- (52/52) Firmware :: Dummy []
*/

/******************************************************************************************
 *							Check Managed Mark - After [Fixed] 
 ******************************************************************************************//*
--UPDATE sr 
SET sr.MarkManaged = 'Y' 
FROM DeepSeaKingdom.dbo.SessionRule sr
	JOIN Seaweed.dbo.QuarterSessions ON QuarterSessions.QuarterSessionId = sr.QuarterSessionId
WHERE QuarterSessions.Period = @Term
	AND sr.ContentCode IN 
		--('CIVL6023','CIVL6027','CIVL6066') -- (3/3) Civil Engineering :: Dummy []
		--('SCIE6005','CPEN6066','SCIE6028','CPEN6084','CPEN6081','CPEN6085','CPEN6083','H0593') -- (8/8) Hardware :: Dummy []
		--('ISYS6163','ISYS6188','ISYS6209','ISYS6191','ISYS6212') -- (5/5) Information System :: Dummy [M0086, A1424, M0126, M1006]
		--('COMP6203','COMP6177','J0292') -- (3/3) Management - Theory :: Dummy [J0302, J0312, J0682, O0712]
		--('J1574','STAT6079','MGMT6036','STAT8068','J1186') -- (5/5) Management - Practicum :: Dummy []
		--('DSGN6185','COMM6085','COMM6096','COMM6086') -- (4/4) Marketing Communication - Broadcast :: Dummy [O0824, O0704] >>COMM6096::Duplicates
		--('COMM6121','COMM6151','COMM6123','COMM6130','COMM6117','COMM6109','COMM6118','COMM6125','COMM6111','DSGN6279','DSGN6188','COMM6096') -- (12/12) Marketing Communication - Public Relation :: Dummy [] >>COMM6096::Duplicates
		--('') -- (0/0) Psychology :: Dummy []
		--('COMP6064','COMP6114','COMP6120','COMP6132','COMP6175','COMP6176','COMP6178','COMP6183','COMP6225','COMP6233','COMP6268','COMP7066','COMP7084','COMP7094','COMP7110','COMP7116','COMP8108','CPEN6046','CPEN6098','CPEN6101','CPEN6102','CPEN6108','CPEN6109','CPEN8076','H0493','H0515','ISYS6078','ISYS6084','ISYS6123','ISYS6169','ISYS6172','ISYS6197','ISYS6203','ISYS6211','ISYS6279','ISYS6280','M0114','M0564','MOBI6002','MOBI6009','T0044','T0053','T0123','T0206','T0233','T0273','T0293','T0316','T0593','T1404','T1464','T2334') -- (52/52) Firmware :: Dummy []
*/






/******************************************************************************************
 *									Lab Civil Engineering
 ******************************************************************************************/
SET @WorkshopName = 'Civil Engineering'
---------- UTP Tidak ada
----- Civil Engineering :: Parent [CIVL6066, CIVL6027, CIVL6023] (3)
----- Civil Engineering :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *									Lab Hardware
 ******************************************************************************************/
SET @WorkshopName = 'Hardware'
---------- UTP Tidak ada
----- Hardware :: Parent [SCIE6005, CPEN6066, SCIE6028, CPEN6084, CPEN6081, CPEN6085, CPEN6083, H0593] (8)
----- Hardware :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *									Lab Information System
 ******************************************************************************************/
SET @WorkshopName = 'Information System'
---------- UTP Parent [ISYS6212]
----- Information System :: Parent [ISYS6163, ISYS6188, ISYS6209, ISYS6191, ISYS6212] (5)
----- Information System :: Dummy [M0086, A1424, M0126, M1006] (4)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *									Lab Management
 ******************************************************************************************/
SET @WorkshopName = 'Management'
---------- UTP Parent [STAT8068, J1574, STAT6079, MGMT6036, J1186] :: Dummy [J0682]
---------- UTS Parent [COMP6203, COMP6177, J0292] :: Dummy []
----- Management - Theory :: Parent [COMP6203, COMP6177, J0292] (3)
----- Management - Theory :: Dummy [J0302, J0312, J0682, O0712] (4)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='' --[COMP6203, COMP6177, J0292]
----- Management - Practicum :: Parent [J1574, STAT6079, MGMT6036, STAT8068, J1186] (5)
----- Management - Practicum :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB' --[J1574, STAT6079, MGMT6036, STAT8068, J1186]


/******************************************************************************************
 *							Lab Marketing Communication - Broadcast
 ******************************************************************************************/
SET @WorkshopName = 'Marketing Communication'
---------- UTP Tidak ada
----- Marketing Communication - Broadcast :: Parent [DSGN6185, COMM6085, COMM6096, COMM6086] (4) --[COMM6096 - Duplicates sama Lab Public Relation] 
----- Marketing Communication - Broadcast :: Dummy [O0824, O0704] (2)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *						Lab Marketing Communication - Public Relation
 ******************************************************************************************/
SET @WorkshopName = 'Marketing Communication'
---------- UTP Parent [COMM6130]
----- Marketing Communication - Public Relation :: Parent [COMM6121, COMM6151, COMM6123, COMM6130, COMM6117, COMM6109, COMM6118, COMM6125, COMM6111, DSGN6279, DSGN6188, COMM6096] (12) --[COMM6096 - Duplicates sama Lab Broadcast] 
----- Marketing Communication - Public Relation :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *										Lab Psychology
 ******************************************************************************************/
SET @WorkshopName = 'Psychology'
---------- UTP Tidak ada
----- Psychology :: Parent [] (0)
----- Psychology :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *										Lab Firmware
 ******************************************************************************************/
SET @WorkshopName = 'Firmware'
---------- UTP Tidak ada
----- Firmware :: Parent [COMP6064, COMP6114, COMP6120, COMP6132, COMP6175, COMP6176, COMP6178, COMP6183, COMP6225, COMP6233, COMP6268, COMP7066, COMP7084, COMP7094, COMP7110, COMP7116, COMP8108, CPEN6046, CPEN6098, CPEN6101, CPEN6102, CPEN6108, CPEN6109, CPEN8076, H0493, H0515, ISYS6078, ISYS6084, ISYS6123, ISYS6169, ISYS6172, ISYS6197, ISYS6203, ISYS6211, ISYS6279, ISYS6280, M0114, M0564, MOBI6002, MOBI6009, T0044, T0053, T0123, T0206, T0233, T0273, T0293, T0316, T0593, T1404, T1464, T2334] (52)
----- Firmware :: Dummy [COMP6064, COMP6114, COMP6120, COMP6132, COMP6175, COMP6176, COMP6178, COMP6233, COMP7066, COMP7084, COMP7094, COMP7110, COMP7116, CPEN8076, ISYS6123, ISYS6169, ISYS6172, ISYS6197, M0564, MOBI6002, T0233, T1464] (22)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *				Check Content or Ingredient (Especially Lab Firmware for Update Session Rule)
 ******************************************************************************************//*
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @Query NVARCHAR(MAX), @QueryCheckParent NVARCHAR(MAX), @QueryCheckDummy NVARCHAR(MAX)
SET @LinkedServer = '[LocalDB]'
SET @OpenQuery = N'SELECT DISTINCT ct.BrandBusinessId, ct.BrandName, ct.QuarterSessionId, ct.Note, ct.AssociateCode, ct.AssociateName, Topics.TopicId, Topics.Name [TopicName], Topics.DepartmentId, co.ContentOutlineId, co.Name [ContentName], co.SessionRuleId, lab.WorkshopId, lab.Name [WorkshopName]
FROM Galaxy.dbo.BrandBusinesss ct
	JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
		AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
		AND ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
	JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
	JOIN Galaxy.dbo.Workshops lab ON Topics.WorkshopId = lab.WorkshopId
		AND lab.Name LIKE ''%'+@WorkshopName+'%'''
SET @Query = N'SELECT DISTINCT as_query.[TopicName], as_query.[ContentName]
	FROM OPENQUERY ('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') as_query
	JOIN DeepSeaKingdom.WE.UDFTV_AssesmentIngredientHorizontal('''+@QuarterSessionId+''') ec ON as_query.QuarterSessionId = ec.QuarterSessionId
		AND as_query.ContentOutlineId = ec.ContentOutlineId
		AND (ec.Responsibility > 0 OR ec.Venture > 0 OR ec.MidTerm > 0 OR ec.FinalTerm > 0)'
SET @QueryCheckParent = N'SELECT DISTINCT as_query.[ContentName]
	FROM OPENQUERY ('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') as_query
	JOIN DeepSeaKingdom.WE.UDFTV_AssesmentIngredientHorizontal('''+@QuarterSessionId+''') ec ON as_query.QuarterSessionId = ec.QuarterSessionId
		AND as_query.ContentOutlineId = ec.ContentOutlineId
		AND (ec.Responsibility > 0 OR ec.Venture > 0 OR ec.MidTerm > 0 OR ec.FinalTerm > 0)'
SET @QueryCheckDummy = N'SELECT DISTINCT as_query.[ContentName]
	FROM OPENQUERY ('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') as_query
	JOIN DeepSeaKingdom.WE.UDFTV_AssesmentIngredientHorizontal('''+@QuarterSessionId+''') ec ON as_query.QuarterSessionId = ec.QuarterSessionId
		AND as_query.ContentOutlineId = ec.ContentOutlineId
		AND (ec.Responsibility > 0 OR ec.Venture > 0 OR ec.MidTerm > 0 OR ec.FinalTerm > 0)
		AND as_query.[TopicName] <> as_query.[ContentName]'
EXECUTE (@Query)
*/


/******************************************************************************************
 *				Check Branch Mark Ingredient Galaxy and LovelySite
 ******************************************************************************************//*
------------------------------ Check Typo[MissSpelled] AND Check Missed Percentage[Weight]:: intinya ke Branch atau engga
DECLARE @OpenQuery1 NVARCHAR(MAX), @OpenQuery2 NVARCHAR(MAX), @LinkedServer1 NVARCHAR(MAX), @LinkedServer2 NVARCHAR(MAX), @Query NVARCHAR(MAX), @ImportedMarkIngredientBranchTable NVARCHAR(MAX)
SET @ImportedMarkIngredientBranchTable = '[DeepSeaKingdom].[WE].[MarkIngredient_Branch_1620]'
SET @LinkedServer1 = N'[LocalDB]'
SET @LinkedServer2 = N'[OPRO]'
SET @OpenQuery1 = N'SELECT DISTINCT ct.BrandBusinessId, ct.BrandName, ct.QuarterSessionId, ct.Note, ct.AssociateCode, ct.AssociateName, Topics.TopicId, Topics.Name [TopicName], Topics.DepartmentId, co.ContentOutlineId, co.Name [ContentName], co.SessionRuleId, lab.WorkshopId, lab.Name [WorkshopName]
FROM Galaxy.dbo.BrandBusinesss ct
	JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
		AND ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
		AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
	JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
	JOIN Galaxy.dbo.Workshops lab ON Topics.WorkshopId = lab.WorkshopId'
SET @OpenQuery2 = N'SELECT ca.* FROM PS_N_Content_ASSIGN ca WHERE ca.Department = ''YYS01'' AND ca.Position = ''RS1'' AND ca.Term = '''+@Term+''''
SET @Query = N'SELECT DISTINCT mess.[WorkshopName], mess.[TopicName], mess.[ContentName], ecv.Type, [Percentage] = IIF(cm.GalaxyNumber IS NULL, ecv.Percentage, CONVERT(FLOAT,ecv.DetailPercentage)), cm.GalaxyIngredient, cm.LovelySiteIngredient, ca.Content_CODE, ca.DESCR, ca.LAM_WEIGHT
	FROM OPENQUERY('+@LinkedServer1+','''+REPLACE(@OpenQuery1,'''','''''')+''') mess
		JOIN DeepSeaKingdom.WE.UDFTV_AssesmentIngredientVerticalDetail('''+@QuarterSessionId+''') ecv ON ecv.QuarterSessionId = mess.QuarterSessionId
			AND ecv.ContentOutlineId = mess.ContentOutlineId
		FULL OUTER JOIN '+@ImportedMarkIngredientBranchTable+' cm ON cm.ContentCode = LEFT(mess.[ContentName],CHARINDEX(''-'',mess.[ContentName])-1)
			AND cm.GalaxyIngredient = ecv.Type
			AND ISNULL(cm.GalaxyNumber,''-'') = IIF(cm.GalaxyNumber IS NULL, ''-'', ecv.DetailNumber)
		JOIN OPENQUERY ('+@LinkedServer2+','''+REPLACE(@OpenQuery2,'''','''''')+''') ca ON ca.Content_CODE = LEFT(mess.[ContentName],CHARINDEX(''-'',mess.[ContentName])-1)
			AND ca.TYPE = ''LAB'' -- Diganti kalo Theory pinjam nama dosen Lab Management
			AND ca.DESCR = cm.LovelySiteIngredient
	ORDER BY mess.[WorkshopName], mess.[ContentName]'
EXECUTE (@Query)

------------------------------ Check Weight and Send Email Confirmation
SET @WorkshopName = 'Hardware'
SET @Query = N'SELECT DISTINCT mess.[WorkshopName], mess.[ContentName] [Content], cm.GalaxyIngredient+ISNULL(cm.GalaxyNumber,'''') [GalaxyIngredient], IIF(cm.GalaxyNumber IS NULL, ecv.Percentage, CONVERT(FLOAT,ecv.DetailPercentage)) [Galaxy Percentage], cm.LovelySiteIngredient, ca.LAM_WEIGHT [LovelySite Percentage], [Status] = CASE WHEN (ecv.Percentage = ca.LAM_WEIGHT) OR (DENSE_RANK() OVER (PARTITION BY mess.[ContentName] ORDER BY ecv.Percentage ASC) = 1 AND ecv.Percentage = 100) THEN NULL ELSE ''Diffrent'' END
	FROM OPENQUERY('+@LinkedServer1+','''+REPLACE(@OpenQuery1,'''','''''')+''') mess
		JOIN DeepSeaKingdom.WE.UDFTV_AssesmentIngredientVerticalDetail('''+@QuarterSessionId+''') ecv ON ecv.QuarterSessionId = mess.QuarterSessionId
			AND ecv.ContentOutlineId = mess.ContentOutlineId
		FULL OUTER JOIN '+@ImportedMarkIngredientBranchTable+' cm ON cm.ContentCode = LEFT(mess.[ContentName],CHARINDEX(''-'',mess.[ContentName])-1)
			AND cm.GalaxyIngredient = ecv.Type
			AND ISNULL(cm.GalaxyNumber,''-'') = IIF(cm.GalaxyNumber IS NULL, ''-'', ecv.DetailNumber)
		JOIN OPENQUERY ('+@LinkedServer2+','''+REPLACE(@OpenQuery2,'''','''''')+''') ca ON ca.Content_CODE = LEFT(mess.[ContentName],CHARINDEX(''-'',mess.[ContentName])-1)
			--AND ca.TYPE = ''LAB'' -- Diganti kalo Theory pinjam nama dosen Lab Management
			AND ca.DESCR = cm.LovelySiteIngredient
	WHERE mess.[WorkshopName] LIKE ''%'+@WorkshopName+'%''
	ORDER BY mess.[WorkshopName], mess.[ContentName]'
EXECUTE (@Query)
*/