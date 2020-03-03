
DECLARE @Term NVARCHAR(MAX), @WorkshopName NVARCHAR(MAX), @QuarterSessionId NVARCHAR(MAX)
SET @Term = '1630'
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
*/		


/******************************************************************************************
 *							Check Managed Mark - After [Fixed] 
 ******************************************************************************************//*
--UPDATE sr SET sr.MarkManaged = 'Y' 
SELECT * 
FROM DeepSeaKingdom.dbo.SessionRule sr
	JOIN Seaweed.dbo.QuarterSessions ON QuarterSessions.QuarterSessionId = sr.QuarterSessionId
WHERE QuarterSessions.Period = @Term
	AND sr.ContentCode IN 
		--('') -- (0/0) Civil Engineering :: Dummy []
		--('SCIE6005') -- (1/1) Hardware :: Dummy []
		--('ISYS6188','ISYS6209','M0086') -- (3/3) Information System :: Dummy [M0086, A1424, M0126, M1006]
		--('COMP6151','COMP6152','COMP6177','COMP6203','J0302') -- (5/5) Management - Theory :: Dummy []
		--('J1574') -- (1/1) Management - Practicum :: Dummy []
		--('') -- (0/0) Marketing Communication - Broadcast :: Dummy []
		--('') -- (0/0) Marketing Communication - Public Relation & Digital Journalism :: Dummy []
		--('L0174','STAT6109') -- (2/2) Psychology :: Dummy []
		--('COMP6047','COMP6048','COMP6120','COMP6175','COMP6178','CPEN6098','ISYS6123','ISYS6169','ISYS6197','M0564','MOBI6002','T0026','T0053','T0123','T0144','T0206','T0293','T0316','T0413','T0553','T1464','T2334','T2363') -- (23/23) Firmware :: Dummy []
*/




/******************************************************************************************
 *									Lab Civil Engineering
 ******************************************************************************************/
SET @WorkshopName = 'Civil Engineering'
---------- UTP Tidak ada
----- Civil Engineering :: Parent [] (0)
----- Civil Engineering :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *									Lab Hardware
 ******************************************************************************************/
SET @WorkshopName = 'Hardware'
---------- UTP Tidak ada
----- Hardware :: Parent [SCIE6005] (1)
----- Hardware :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *									Lab Information System
 ******************************************************************************************/
SET @WorkshopName = 'Information System'
---------- UTP Parent [ISYS6212]
----- Information System :: Parent [ISYS6188, ISYS6209, M0086] (3)
----- Information System :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *									Lab Management
 ******************************************************************************************/
SET @WorkshopName = 'Management'
---------- UTP Parent [] :: Dummy []
---------- UTS Parent [] :: Dummy []
----- Management - Theory :: Parent [COMP6151, COMP6152, COMP6177, COMP6203, J0302] (5)
----- Management - Theory :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='' --[COMP6151, COMP6152, COMP6177, COMP6203, J0302]
----- Management - Practicum :: Parent [J1574] (1)
----- Management - Practicum :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB' --[J1574]


/******************************************************************************************
 *							Lab Marketing Communication - Broadcast
 ******************************************************************************************/
SET @WorkshopName = 'Marketing Communication'
---------- UTP Tidak ada
----- Marketing Communication - Broadcast :: Parent [] (0)
----- Marketing Communication - Broadcast :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *						Lab Marketing Communication - Public Relation
 ******************************************************************************************/
SET @WorkshopName = 'Marketing Communication'
---------- UTP Tidak ada
----- Marketing Communication - Public Relation :: Parent [] (0)
----- Marketing Communication - Public Relation :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *										Lab Psychology
 ******************************************************************************************/
SET @WorkshopName = 'Psychology'
---------- UTP Tidak ada
----- Psychology :: Parent [L0174, STAT6109] (2)
----- Psychology :: Dummy [] (0)
--EXECUTE [WE].[SP_CheckContentAssignMarkManage] @WorkshopName = @WorkshopName, @Term=@Term, @LamType='LAB'


/******************************************************************************************
 *										Lab Firmware
 ******************************************************************************************/
SET @WorkshopName = 'Firmware'
---------- UTP Tidak ada
----- Firmware :: Parent [COMP6047, COMP6048, COMP6120, COMP6175, COMP6178, CPEN6098, ISYS6123, ISYS6169, ISYS6197, M0564, MOBI6002, T0026, T0053, T0123, T0144, T0206, T0293, T0316, T0413, T0553, T1464, T2334, T2363] (23)
----- Firmware :: Dummy [] (0)
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
 ******************************************************************************************/
------------------------------ Check Typo[MissSpelled] AND Check Missed Percentage[Weight]:: intinya ke Branch atau engga
DECLARE @OpenQuery1 NVARCHAR(MAX), @OpenQuery2 NVARCHAR(MAX), @LinkedServer1 NVARCHAR(MAX), @LinkedServer2 NVARCHAR(MAX), @Query NVARCHAR(MAX), @ImportedMarkIngredientBranchTable NVARCHAR(MAX)
SET @ImportedMarkIngredientBranchTable = '[DeepSeaKingdom].[WE].[MarkIngredient_Branch_'+@Term+']'
SET @LinkedServer1 = N'[LocalDB]'
SET @LinkedServer2 = N'[OPRO]'
SET @OpenQuery1 = N'SELECT DISTINCT ct.BrandBusinessId, ct.BrandName, ct.QuarterSessionId, ct.Note, ct.AssociateCode, ct.AssociateName, Topics.TopicId, Topics.Name [TopicName], Topics.DepartmentId, co.ContentOutlineId, co.Name [ContentName], co.SessionRuleId, lab.WorkshopId, lab.Name [WorkshopName]
FROM Galaxy.dbo.BrandBusinesss ct
	JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
		AND ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%''
		AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
	JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
	JOIN Galaxy.dbo.Workshops lab ON Topics.WorkshopId = lab.WorkshopId'
SET @OpenQuery2 = N'SELECT ca.* FROM PS_N_Content_ASSIGN ca WHERE ca.Department = ''YYS01'' AND ca.Position = ''RS1'' AND ca.Term = '''+@Term+''''/*
SET @Query = N'SELECT DISTINCT mess.[WorkshopName], mess.[TopicName], mess.[ContentName], ecv.Type, [Percentage] = IIF(cm.GalaxyNumber IS NULL, ecv.Percentage, CONVERT(FLOAT,ecv.DetailPercentage)), [GalaxyIngredient] = cm.GalaxyIngredient+COALESCE('' ''+cm.GalaxyNumber,''''), cm.LovelySiteIngredient, ca.Content_CODE, ca.DESCR, ca.LAM_WEIGHT
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
EXECUTE (@Query)*/

------------------------------ Check Weight and Send Email Confirmation
SET @WorkshopName = 'Firmware'/*
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