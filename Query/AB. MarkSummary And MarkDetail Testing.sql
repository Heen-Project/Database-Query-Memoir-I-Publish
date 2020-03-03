/******************************************************************************************
 * Get All Lab Family Mark and Assesment Ingredient Term 1610 
 ******************************************************************************************/
GO
SELECT * 
INTO #AssesmentIngredient 
FROM DeepSeaKingdom.WE.UDFTV_AssesmentIngredient('1AF0')
GO
SELECT * 
INTO #FamilyMark 
FROM DeepSeaKingdom.WE.V_FamilyMark ss WHERE ss.QuarterSessionId LIKE '1AF0%'

SELECT * INTO WE.FamilyMarkDetail FROM #FamilyMarkDetail
SELECT * INTO WE.FamilyMarkSummary FROM #FamilyMarkSummary

exec sp_columns FamilyMarkDetail
exec sp_columns FamilyMarkSummary



/******************************************************************************************
 * Get All Lab Family Mark Generate Final Mark - Galaxy
 ******************************************************************************************//*
GO
;WITH FamilyMark_CTE AS (
	SELECT DISTINCT pvt_FamilyMark.BrandBusinessId, pvt_FamilyMark.MemberId, pvt_FamilyMark.QuarterSessionId, pvt_FamilyMark.ContentOutlineId, pvt_FamilyMark.BrandName, [Responsibility] = MAX(pvt_FamilyMark.Responsibility), [Venture] = MAX(pvt_FamilyMark.Venture), [MidTerm] = MAX(pvt_FamilyMark.MidTerm), [FinalTerm] = MAX(pvt_FamilyMark.FinalTerm), [OldResponsibility] = MAX(pvt_FamilyMark.OldResponsibility), [OldVenture] = MAX(pvt_FamilyMark.OldVenture), [OldMidTerm] = MAX(pvt_FamilyMark.OldMidTerm), [OldFinalTerm] = MAX(pvt_FamilyMark.OldFinalTerm)
	FROM (
	SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, ss.Type, [Summary] = (CASE WHEN COUNT(ss.Mark) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type) = ec.Count THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2),CEILING(SUM((CONVERT(NUMERIC(10,2),ISNULL(ss.Mark,0.00)) * CONVERT(NUMERIC(10,2), ec.DetailPercentage))/100.00) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type)))) ELSE 'N/A' END),[OldSummary] = (CASE WHEN COUNT(ss.Mark) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type) = ec.Count THEN CONVERT(VARCHAR, CONVERT(NUMERIC(10,2),SUM((CONVERT(NUMERIC(10,2),ISNULL(ss.Mark,0.00)) * CONVERT(NUMERIC(10,2), ec.DetailPercentage))/100.00) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type))) ELSE 'N/A' END), [OldType] = 'Old'+ss.Type
		FROM #AssesmentIngredient ec
			JOIN #FamilyMark ss ON ec.ContentOutlineId = ss.ContentOutlineId
				AND ec.Type = ss.Type
				AND ec.DetailNumber = ss.Number
				AND ec.QuarterSessionId = ss.QuarterSessionId
		) AS SourceTable PIVOT (MAX(SourceTable.[Summary]) FOR [Type] IN ([Responsibility],[Venture],[MidTerm],[FinalTerm])) AS pvt PIVOT (MAX(pvt.[OldSummary]) FOR [OldType] IN ([OldResponsibility],[OldVenture],[OldMidTerm],[OldFinalTerm])) AS pvt_FamilyMark
	Batch BY pvt_FamilyMark.BrandBusinessId, pvt_FamilyMark.MemberId, pvt_FamilyMark.QuarterSessionId, pvt_FamilyMark.ContentOutlineId, pvt_FamilyMark.BrandName
), AssesmentIngredient_CTE AS (
	SELECT DISTINCT pvt_AssesmentIngredient.QuarterSessionId, pvt_AssesmentIngredient.ContentOutlineId, [Responsibility] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.Responsibility,0.00)), [Venture] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.Venture,0.00)), [MidTerm] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.MidTerm,0.00)), [FinalTerm] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.FinalTerm,0.00)), pvt_AssesmentIngredient.[IngredientDetailPercentage10000]
	FROM (SELECT DISTINCT ec.QuarterSessionId, ec.ContentOutlineId, ec.[Type], ec.Percentage, [IngredientDetailPercentage10000] = (CASE WHEN ec.[DetailPercentage10000] = 'Y' THEN ec.[Type] ELSE NULL END) FROM #AssesmentIngredient ec) SourceTable PIVOT (MAX(Percentage) FOR Type IN ([Responsibility],[Venture],[MidTerm],[FinalTerm])) AS pvt_AssesmentIngredient
)
SELECT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, [Responsibility] = IIF(ss.Responsibility='N/A', ss.Responsibility, ISNULL(ss.Responsibility, '-')), [Venture] = IIF(ss.Venture='N/A', ss.Venture, ISNULL(ss.Venture,'-')), [MidTerm] = IIF(ss.MidTerm='N/A', ss.MidTerm, ISNULL(ss.MidTerm,'-')), [FinalTerm] = IIF(ss.FinalTerm='N/A', ss.FinalTerm, ISNULL(ss.FinalTerm,'-')), [TotalMark] = IIF(ss.Responsibility='N/A' OR ss.Venture='N/A' OR ss.MidTerm='N/A' OR ss.FinalTerm='N/A','N/A',CONVERT(VARCHAR,CEILING(((CASE WHEN ec.[IngredientDetailPercentage10000] = 'Responsibility' 
	THEN (CEILING(ISNULL(CONVERT(NUMERIC(10,2),ss.OldResponsibility),0.00))*ec.Responsibility) ELSE (ISNULL(CONVERT(NUMERIC(10,2),ss.OldResponsibility),0.00)*ec.Responsibility) END)
+(CASE WHEN ec.IngredientDetailPercentage10000 = 'Venture' 
	THEN (CEILING(ISNULL(CONVERT(NUMERIC(10,2),ss.OldVenture),0.00))*ec.Venture) ELSE (ISNULL(CONVERT(NUMERIC(10,2),ss.OldVenture),0.00)*ec.Venture) END)
+(CASE WHEN ec.IngredientDetailPercentage10000 = 'MidTerm' 
	THEN (CEILING(ISNULL(CONVERT(NUMERIC(10,2),ss.OldMidTerm),0.00))*ec.MidTerm) ELSE (ISNULL(CONVERT(NUMERIC(10,2),ss.OldMidTerm),0.00)*ec.MidTerm) END)
+(CASE WHEN ec.IngredientDetailPercentage10000 = 'FinalTerm' 
	THEN (CEILING(ISNULL(CONVERT(NUMERIC(10,2),ss.OldFinalTerm),0.00))*ec.FinalTerm) ELSE (ISNULL(CONVERT(NUMERIC(10,2),ss.OldFinalTerm),0.00)*ec.FinalTerm) END))/100.00)))
INTO #MarkSummary
FROM FamilyMark_CTE ss
	JOIN AssesmentIngredient_CTE ec ON ec.QuarterSessionId = ss.QuarterSessionId
		AND ec.ContentOutlineId = ss.ContentOutlineId*/


/******************************************************************************************
 * Get All Lab Family Mark Generate Final Mark Term 1610 
 ******************************************************************************************/
GO
;WITH FamilyMark_CTE AS (
	SELECT DISTINCT pvt_FamilyMark.BrandBusinessId, pvt_FamilyMark.MemberId, pvt_FamilyMark.QuarterSessionId, pvt_FamilyMark.ContentOutlineId, pvt_FamilyMark.BrandName, [Responsibility] = MAX(pvt_FamilyMark.Responsibility), [Venture] = MAX(pvt_FamilyMark.Venture), [MidTerm] = MAX(pvt_FamilyMark.MidTerm), [FinalTerm] = MAX(pvt_FamilyMark.FinalTerm), [OldResponsibility] = MAX(pvt_FamilyMark.OldResponsibility), [OldVenture] = MAX(pvt_FamilyMark.OldVenture), [OldMidTerm] = MAX(pvt_FamilyMark.OldMidTerm), [OldFinalTerm] = MAX(pvt_FamilyMark.OldFinalTerm)
	FROM (
	SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, ss.Type, [Summary] = CONVERT(NUMERIC(10,2),CEILING(SUM((CONVERT(NUMERIC(10,2),ISNULL(ss.Mark,0.00)) * CONVERT(NUMERIC(10,2), ec.DetailPercentage))/100.00) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type))),[OldSummary] = CONVERT(NUMERIC(10,2),SUM((CONVERT(NUMERIC(10,2),ISNULL(ss.Mark,0.00)) * CONVERT(NUMERIC(10,2), ec.DetailPercentage))/100.00) OVER (PARTITION BY ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.Type)), [OldType] = 'Old'+ss.Type
		FROM #AssesmentIngredient ec
			JOIN #FamilyMark ss ON ec.ContentOutlineId = ss.ContentOutlineId
				AND ec.Type = ss.Type
				AND ec.DetailNumber = ss.Number
				AND ec.QuarterSessionId = ss.QuarterSessionId
		) AS SourceTable PIVOT (MAX(SourceTable.[Summary]) FOR [Type] IN ([Responsibility],[Venture],[MidTerm],[FinalTerm])) AS pvt PIVOT (MAX(pvt.[OldSummary]) FOR [OldType] IN ([OldResponsibility],[OldVenture],[OldMidTerm],[OldFinalTerm])) AS pvt_FamilyMark
	Batch BY pvt_FamilyMark.BrandBusinessId, pvt_FamilyMark.MemberId, pvt_FamilyMark.QuarterSessionId, pvt_FamilyMark.ContentOutlineId, pvt_FamilyMark.BrandName
), AssesmentIngredient_CTE AS (
	SELECT DISTINCT pvt_AssesmentIngredient.QuarterSessionId, pvt_AssesmentIngredient.ContentOutlineId, [Responsibility] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.Responsibility,0.00)), [Venture] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.Venture,0.00)), [MidTerm] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.MidTerm,0.00)), [FinalTerm] = CONVERT(NUMERIC(10,2),ISNULL(pvt_AssesmentIngredient.FinalTerm,0.00)), pvt_AssesmentIngredient.[IngredientDetailPercentage10000]
	FROM (SELECT DISTINCT ec.QuarterSessionId, ec.ContentOutlineId, ec.Type, ec.Percentage, [IngredientDetailPercentage10000] = (CASE WHEN ec.[DetailPercentage10000] = 'Y' THEN ec.Type ELSE NULL END) FROM #AssesmentIngredient ec) SourceTable PIVOT (MAX(Percentage) FOR Type IN ([Responsibility],[Venture],[MidTerm],[FinalTerm])) AS pvt_AssesmentIngredient
)
SELECT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, [Responsibility] = ISNULL(CONVERT(VARCHAR,CONVERT(INT,ss.Responsibility)), '-'), [Venture] = ISNULL(CONVERT(VARCHAR,CONVERT(INT,ss.Venture)),'-'), [MidTerm] = ISNULL(CONVERT(VARCHAR,CONVERT(INT,ss.MidTerm)),'-'), [FinalTerm] = ISNULL(CONVERT(VARCHAR,CONVERT(INT,ss.FinalTerm)),'-'), [TotalMark] = CEILING(((CASE WHEN ec.IngredientDetailPercentage10000 = 'Responsibility' 
	THEN CEILING(ISNULL(ss.OldResponsibility,0.00)*ec.Responsibility) ELSE (ISNULL(ss.OldResponsibility,0.00)*ec.Responsibility) END)
+(CASE WHEN ec.IngredientDetailPercentage10000 = 'Venture' 
	THEN CEILING(ISNULL(ss.OldVenture,0.00)*ec.Venture) ELSE (ISNULL(ss.OldVenture,0.00)*ec.Venture) END)
+(CASE WHEN ec.IngredientDetailPercentage10000 = 'MidTerm' 
	THEN CEILING(ISNULL(ss.OldMidTerm,0.00)*ec.MidTerm) ELSE (ISNULL(ss.OldMidTerm,0.00)*ec.MidTerm) END)
+(CASE WHEN ec.IngredientDetailPercentage10000 = 'FinalTerm' 
	THEN CEILING(ISNULL(ss.OldFinalTerm,0.00)*ec.FinalTerm) ELSE (ISNULL(ss.OldFinalTerm,0.00)*ec.FinalTerm) END))/100.00)
INTO #MarkSummary
FROM FamilyMark_CTE ss
	JOIN AssesmentIngredient_CTE ec ON ec.QuarterSessionId = ss.QuarterSessionId
		AND ec.ContentOutlineId = ss.ContentOutlineId


/******************************************************************************************
 * Get All Lab Family Mark Summary Additional Information Term 1610 
 ******************************************************************************************/
GO
SELECT [House] = es.House
	,[LaboratorName] = lab.Name 
	,[ContentOutline] = co.Name
	,[TopicName] = Topics.Name
	,[AssociateCode] = ct.AssociateCode
	,[AssociateName] = ct.AssociateName
	,[MemberNumber] = bFamilyXXX.Number
	,[MemberName] = bFamilyXXX.Name
	,[BrandName] = RTRIM(LEFT(ct.BrandName, 5))
	,[Responsibility] = ss.Responsibility
	,[Venture] = ss.Venture
	,[MidTerm] = ss.MidTerm
	,[FinalTerm] = ss.FinalTerm
	,[TotalMark] = ss.TotalMark
INTO #FamilyMarkSummary
FROM [LocalDB].Galaxy.dbo.VBrandBusinesss ct
	JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
		AND ct.QuarterSessionId LIKE '1AF0%'
	JOIN [LocalDB].Galaxy.dbo.BrandBusinessFamilys cts ON cts.BrandBusinessId = ct.BrandBusinessId
		AND NOT EXISTS (SELECT NULL FROM Galaxy..DeletedBrandBusinessFamilys dcts WHERE dcts.BrandBusinessFamilyId = cts.BrandBusinessFamilyId AND NOT EXISTS(SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = dcts.DeletedBrandBusinessFamilyId))
	LEFT JOIN #MarkSummary ss ON ss.QuarterSessionId = ct.QuarterSessionId -- JANGAN JOIN PAKE BrandBusinessId (Reason OnsiteTestple BrandBusinessId '16770E0D-586F-E611-903A-D8D385FCE79E', '18770E0D-586F-E611-903A-D8D385FCE79E')
		AND ss.ContentOutlineId = Topics.ContentOutlineId
		AND ss.MemberId = cts.MemberId
	JOIN [LocalDB].Galaxy.dbo.Workshops lab ON lab.WorkshopId = Topics.WorkshopId
	JOIN [LocalDB].Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
	JOIN [LocalDB].Galaxy.dbo.Members bFamilyXXX ON bFamilyXXX.MemberId = cts.MemberId
	LEFT JOIN DeepSeaKingdom.dbo.EnrollmentStatus es ON es.[Family ID] = bFamilyXXX.Number
		AND RTRIM(es.Topic)+RIGHT('0000'+CAST(LTRIM(es.[Catalog Number]) AS VARCHAR),4) = LEFT(Topics.Name, CHARINDEX('-',Topics.Name)-1)
		AND es.[Brand Section] = RTRIM(LEFT(ct.BrandName, 5))
		AND es.[Academic Career] = 'RS1'
		AND es.Term = (SELECT DISTINCT QuarterSessions.Period FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessionId LIKE '1AF0%')




/******************************************************************************************
 * Detail Ingredient - Version 1 Galaxy
 ******************************************************************************************/
GO
DECLARE @ColumnMark AS NVARCHAR(MAX), @ColumnStatus AS NVARCHAR(MAX),@SelectColumnMark AS NVARCHAR(MAX), @SelectColumnStatus AS NVARCHAR(MAX), @Query AS NVARCHAR(MAX)
SELECT @ColumnMark = STUFF((SELECT DISTINCT ',[Mark' + ec.Type+ec.Number+']' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH('')),1,1,'')
SELECT @ColumnStatus = STUFF((SELECT DISTINCT ',[Status' + ec.Type+ec.Number+']' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH('')),1,1,'')
SELECT @SelectColumnMark = (SELECT DISTINCT ',[Mark' + ec.Type+ec.Number+'] = MAX([Mark' + ec.Type+ec.Number+'])' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH(''))
SELECT @SelectColumnStatus = (SELECT DISTINCT ',[Status' + ec.Type+ec.Number+'] = MAX([Status' + ec.Type+ec.Number+'])' FROM (SELECT DISTINCT Assesment.Type, Assesment.DetailNumber [Number] FROM #AssesmentIngredient Assesment) ec FOR XML PATH(''))
SELECT @ColumnMark, @ColumnStatus, @SelectColumnMark, @SelectColumnStatus
SET @Query = 'SELECT DISTINCT pvt2.BrandBusinessId, pvt2.MemberId, pvt2.QuarterSessionId, pvt2.ContentOutlineId, pvt2.BrandName'+@SelectColumnMark+@SelectColumnStatus+'
INTO ##MarkDetail
FROM (
	SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, [Mark] = ISNULL(ss.Mark,0), ss.Status, [PivotMark] = ''Mark''+ss.Type+ss.Number, [PivotStatus] = ''Status''+ss.Type+ss.Number
	FROM #FamilyMark ss
	) AS SourceTable 
		PIVOT (MAX(SourceTable.Mark) FOR [PivotMark] IN ('+@ColumnMark+')) AS pvt1 
		PIVOT (MAX(pvt1.Status) FOR [PivotStatus] IN ('+@ColumnStatus+')) AS pvt2
Batch BY pvt2.BrandBusinessId, pvt2.MemberId, pvt2.QuarterSessionId, pvt2.ContentOutlineId, pvt2.BrandName'
EXECUTE(@Query)
GO
SELECT * INTO #MarkDetail FROM ##MarkDetail
GO 
DROP TABLE ##MarkDetail

SELECT DISTINCT pvt2.BrandBusinessId, pvt2.MemberId, pvt2.QuarterSessionId, pvt2.ContentOutlineId, pvt2.BrandName,[MarkResponsibility1] = MAX([MarkResponsibility1]),[MarkResponsibility2] = MAX([MarkResponsibility2]),[MarkResponsibility3] = MAX([MarkResponsibility3]),[MarkResponsibility4] = MAX([MarkResponsibility4]),[StatusResponsibility1] = MAX([StatusResponsibility1]),[StatusResponsibility2] = MAX([StatusResponsibility2]),[StatusResponsibility3] = MAX([StatusResponsibility3]),[StatusResponsibility4] = MAX([StatusResponsibility4])
--INTO ##MarkDetail
FROM (
	SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, [Mark] = CASE WHEN ec.DetailPercentage IS NOT NULL AND ss.Mark IS NULL AND ss.MemberId IS NOT NULL THEN '0' WHEN ec.DetailPercentage IS NOT NULL AND ss.MemberId IS NULL THEN 'N/A' ELSE ISNULL(ss.Mark,'0') END , ss.Status, [PivotMark] = 'Mark'+ss.Type+ec.DetailNumber, [PivotStatus] = 'Status'+ss.Type+ec.DetailNumber
		FROM #FamilyMark ss
			RIGHT JOIN #AssesmentIngredient ec ON ec.ContentOutlineId = ss.ContentOutlineId
				AND ec.Type = ss.Type
				AND ec.DetailNumber = ss.Number
				AND ec.QuarterSessionId = ss.QuarterSessionId
	) AS SourceTable 
		PIVOT (MAX(SourceTable.Mark) FOR [PivotMark] IN ([MarkResponsibility1],[MarkResponsibility2],[MarkResponsibility3],[MarkResponsibility4])) AS pvt1 
		PIVOT (MAX(pvt1.Status) FOR [PivotStatus] IN ([StatusResponsibility1],[StatusResponsibility2],[StatusResponsibility3],[StatusResponsibility4])) AS pvt2
Batch BY pvt2.BrandBusinessId, pvt2.MemberId, pvt2.QuarterSessionId, pvt2.ContentOutlineId, pvt2.BrandName


/******************************************************************************************
 * Detail Ingredient - Version 2 ReOrdered
 ******************************************************************************************/
GO
DECLARE @ColumnMark AS NVARCHAR(MAX), @ColumnStatus AS NVARCHAR(MAX),@SelectColumnMark AS NVARCHAR(MAX), @SelectColumnStatus AS NVARCHAR(MAX), @Query AS NVARCHAR(MAX)
SELECT @ColumnMark = STUFF((SELECT DISTINCT ',[Mark' + ss.Type+RIGHT('00'+ss.Number,2)+']' FROM (SELECT DISTINCT Mark.Type, Mark.Number [Number] FROM #FamilyMark Mark) ss FOR XML PATH('')),1,1,'')
SELECT @ColumnStatus = STUFF((SELECT DISTINCT ',[Status' + ss.Type+RIGHT('00'+ss.Number,2)+']' FROM (SELECT DISTINCT Mark.Type, Mark.Number [Number] FROM #FamilyMark Mark) ss FOR XML PATH('')),1,1,'')
SELECT @SelectColumnMark = (SELECT DISTINCT ',[Mark' + ss.Type+RIGHT('00'+ss.Number,2)+'] = MAX([Mark' + ss.Type+RIGHT('00'+ss.Number,2)+'])' FROM (SELECT DISTINCT Mark.Type, Mark.Number [Number] FROM #FamilyMark Mark) ss FOR XML PATH(''))
SELECT @SelectColumnStatus = (SELECT DISTINCT ',[Status' + ss.Type+RIGHT('00'+ss.Number,2)+'] = MAX([Status' + ss.Type+RIGHT('00'+ss.Number,2)+'])' FROM (SELECT DISTINCT Mark.Type, Mark.Number [Number] FROM #FamilyMark Mark) ss FOR XML PATH(''))
SET @Query = 'SELECT DISTINCT pvt2.BrandBusinessId, pvt2.MemberId, pvt2.QuarterSessionId, pvt2.ContentOutlineId, pvt2.BrandName'+@SelectColumnMark+@SelectColumnStatus+'
INTO ##MarkDetail
FROM (
	SELECT DISTINCT ss.BrandBusinessId, ss.MemberId, ss.QuarterSessionId, ss.ContentOutlineId, ss.BrandName, [Mark] = ISNULL(ss.Mark,0) , ss.Status, [PivotMark] = ''Mark''+ss.Type+RIGHT(''00''+ss.Number,2), [PivotStatus] = ''Status''+ss.Type+RIGHT(''00''+ss.Number,2)
	FROM #FamilyMark ss
	) AS SourceTable 
		PIVOT (MAX(SourceTable.Mark) FOR [PivotMark] IN ('+@ColumnMark+')) AS pvt1 
		PIVOT (MAX(pvt1.Status) FOR [PivotStatus] IN ('+@ColumnStatus+')) AS pvt2
Batch BY pvt2.BrandBusinessId, pvt2.MemberId, pvt2.QuarterSessionId, pvt2.ContentOutlineId, pvt2.BrandName'
EXECUTE(@Query)
--EXEC sp_serveroption 'ATLANTIS', 'data access', 'true'
--EXEC sp_helpserver
GO
SELECT * INTO #MarkDetail FROM ##MarkDetail
GO 
DROP TABLE ##MarkDetail


/******************************************************************************************
 * Get All Lab Family Mark Detail Additional Information Term 1610 -- from Version 2
 ******************************************************************************************/
GO
DECLARE @SelectColumnMark AS NVARCHAR(MAX), @SelectColumnStatus AS NVARCHAR(MAX), @Query AS NVARCHAR(MAX)
SELECT @SelectColumnMark = (SELECT DISTINCT ',[Mark' + ss.Type+RIGHT('00'+ss.Number,2)+']' FROM (SELECT DISTINCT Mark.Type, Mark.Number [Number] FROM #FamilyMark Mark) ss FOR XML PATH(''))
SELECT @SelectColumnStatus = (SELECT DISTINCT ',[Status' + ss.Type+RIGHT('00'+ss.Number,2)+']' FROM (SELECT DISTINCT Mark.Type, Mark.Number [Number] FROM #FamilyMark Mark) ss FOR XML PATH(''))
SET @Query = 'SELECT [LaboratorName] = lab.Name 
	,[ContentOutline] = co.Name
	,[TopicName] = Topics.Name
	,[AssociateCode] = ct.AssociateCode
	,[AssociateName] = ct.AssociateName
	,[MemberNumber] = bFamilyXXX.Number
	,[MemberName] = bFamilyXXX.Name
	,[BrandName] = RTRIM(LEFT(ct.BrandName, 5))'+@SelectColumnMark+@SelectColumnStatus+'
INTO ##FamilyMarkDetail
FROM [LocalDB].Galaxy.dbo.VBrandBusinesss ct
	JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
		AND ct.QuarterSessionId LIKE ''1AF0%''
	JOIN [LocalDB].Galaxy.dbo.BrandBusinessFamilys cts ON cts.BrandBusinessId = ct.BrandBusinessId
		AND NOT EXISTS (SELECT NULL FROM Galaxy..DeletedBrandBusinessFamilys dcts WHERE dcts.BrandBusinessFamilyId = cts.BrandBusinessFamilyId AND NOT EXISTS(SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = dcts.DeletedBrandBusinessFamilyId))
	LEFT JOIN #MarkDetail sd ON sd.QuarterSessionId = ct.QuarterSessionId -- JANGAN JOIN PAKE BrandBusinessId (Reason OnsiteTestple BrandBusinessId ''16770E0D-586F-E611-903A-D8D385FCE79E'', ''18770E0D-586F-E611-903A-D8D385FCE79E'')
		AND sd.ContentOutlineId = Topics.ContentOutlineId
		AND sd.MemberId = cts.MemberId
	JOIN [LocalDB].Galaxy.dbo.Workshops lab ON lab.WorkshopId = Topics.WorkshopId
	JOIN [LocalDB].Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
	JOIN [LocalDB].Galaxy.dbo.Members bFamilyXXX ON bFamilyXXX.MemberId = cts.MemberId'
EXECUTE(@Query)
GO
SELECT * INTO #FamilyMarkDetail FROM ##FamilyMarkDetail
GO 
DROP TABLE ##FamilyMarkDetail
