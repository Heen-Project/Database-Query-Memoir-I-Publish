USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_UpdateManualMarkSummary](
	@Term NVARCHAR(MAX) = N''
	,@MidTermOnly BIT = 0
	,@Update BIT = 0
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
;----------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.##MappedMark', 'U') IS NOT NULL DROP TABLE ##MappedMark;
;----------------------------------------------------------------------
DECLARE @QueryInner NVARCHAR(MAX), @Query NVARCHAR(MAX), @ColumnType NVARCHAR(MAX), @ColumnSelectDetail NVARCHAR(MAX), @ColumnSelectSummary NVARCHAR(MAX)
;------------------------------
SELECT @ColumnType = STUFF((SELECT DISTINCT ',[' + mmd.GalaxyIngredient+RIGHT('00'+CONVERT(VARCHAR,ISNULL(mmd.GalaxyNumber,0)),2)+']' FROM [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd WHERE mmd.Term = @Term FOR XML PATH('')),1,1,'')
;------------------------------
SELECT @ColumnSelectDetail = (SELECT DISTINCT ',[' + mmd.GalaxyIngredient+RIGHT('00'+CONVERT(VARCHAR,ISNULL(mmd.GalaxyNumber,0)),2)+']=CONVERT(VARCHAR,[Mark' + mmd.GalaxyIngredient+RIGHT('00'+CONVERT(VARCHAR,ISNULL(mmd.GalaxyNumber,0)),2)+'])' FROM [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd WHERE mmd.Term = @Term AND mmd.GalaxyNumber IS NOT NULL FOR XML PATH(''))
;------------------------------
SELECT @ColumnSelectSummary = (SELECT DISTINCT ',[' + mmd.GalaxyIngredient+RIGHT('00'+CONVERT(VARCHAR,ISNULL(mmd.GalaxyNumber,0)),2)+']=CONVERT(VARCHAR,['+mmd.GalaxyIngredient+'])' FROM [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd WHERE mmd.Term = @Term AND mmd.GalaxyNumber IS NULL FOR XML PATH(''))
;----------------------------------------------------------------------
SET @QueryInner = 'SELECT DISTINCT unpvt.ContentOutline, unpvt.TopicName, unpvt.MemberNumber, unpvt.MemberName, unpvt.BrandName, unpvt.Mark, mmd.LovelySiteIngredient, mmd.GalaxyIngredient, mmd.GalaxyNumber, mmd.LovelySitePercentage, mmd.GalaxyPercentage
	,[LovelySiteIngredientCount] = COUNT (mmd.LovelySiteIngredient) OVER (PARTITION BY unpvt.ContentOutline, unpvt.TopicName, unpvt.MemberNumber, unpvt.BrandName, mmd.LovelySiteIngredient)
	,[GalaxyIngredientCount] = COUNT (mmd.GalaxyIngredient) OVER (PARTITION BY unpvt.ContentOutline, unpvt.TopicName, unpvt.MemberNumber, unpvt.BrandName, mmd.GalaxyIngredient, mmd.GalaxyNumber)
	,[SumGalaxyPercentage] = SUM(CONVERT(FLOAT,mmd.GalaxyPercentage)) OVER (PARTITION BY unpvt.ContentOutline, unpvt.TopicName, unpvt.MemberNumber, mmd.LovelySiteIngredient)
	,[SumLovelySitePercentage] = SUM(CONVERT(FLOAT,mmd.LovelySitePercentage)) OVER (PARTITION BY unpvt.ContentOutline, unpvt.TopicName, unpvt.MemberNumber, unpvt.BrandName, mmd.GalaxyIngredient, mmd.GalaxyNumber)
	FROM (SELECT sse.House, sse.WorkshopName, sse.ContentOutline, sse.TopicName, sse.AssociateCode, sse.AssociateName, sse.MemberNumber, sse.MemberName, sse.BrandName'+@ColumnSelectSummary+@ColumnSelectDetail+' FROM [DeepSeaKingdom].[WE].[FamilyMarkSummary] sse
		JOIN [DeepSeaKingdom].[WE].[FamilyMarkDetail] ssd ON ssd.MemberNumber = sse.MemberNumber
			AND ssd.BrandName = sse.BrandName
			AND ssd.TopicName = sse.TopicName
			AND ssd.ContentOutline = sse.ContentOutline
			AND ssd.Term = sse.Term
			AND sse.Term = '''+@Term+''') p
		UNPIVOT([Mark] FOR [Type] IN ('+@ColumnType+')) AS unpvt
		JOIN [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd ON mmd.ContentCode = LEFT(unpvt.ContentOutline,CHARINDEX(''-'',unpvt.ContentOutline)-1)
			AND mmd.GalaxyIngredient+RIGHT(''00''+CONVERT(VARCHAR,ISNULL(mmd.GalaxyNumber,0)),2) = unpvt.Type
			AND mmd.Term = '''+@Term+''''+CASE WHEN @MidTermOnly = 1 THEN '
			AND mmd.GalaxyIngredient = ''MidTerm''' ELSE '' END+'
		WHERE unpvt.Mark <> ''-'' 
			AND ISNUMERIC(unpvt.Mark) = 1'
SET @Query = 'WITH MappedMark_CTE AS('+@QueryInner+')
		SELECT DISTINCT ms.ContentOutline, ms.TopicName, ms.MemberNumber, ms.MemberName, ms.BrandName, [Mark] = CEILING(SUM(CONVERT(FLOAT, ms.Mark)*IIF(CONVERT(FLOAT,ms.GalaxyPercentage)=100,1,CONVERT(FLOAT,ms.GalaxyPercentage)/IIF(ms.GalaxyIngredientCount=1,CONVERT(FLOAT,ms.LovelySitePercentage),CONVERT(FLOAT,ms.SumLovelySitePercentage)))) OVER (PARTITION BY ms.ContentOutline, ms.TopicName, ms.MemberNumber, ms.BrandName, ms.LovelySiteIngredient)), ms.LovelySiteIngredient /*, ms.GalaxyIngredientCount, ms.LovelySiteIngredientCount, ms.GalaxyPercentage, ms.LovelySitePercentage, ms.SumGalaxyPercentage, ms.SumLovelySitePercentage*/
		INTO ##MappedMark
		FROM MappedMark_CTE ms'
;------------------------------
EXECUTE (@Query)
;------------------------------
IF @Update = 1 SET @QueryInner = 'UPDATE mss SET mss.Mark = ms.Mark'
ELSE SET @QueryInner = 'SELECT DISTINCT mss.Mark [Mark Before], ms.Mark [Mark After], ms.*, mss.*'
;------------------------------
SET @Query = @QueryInner +' '+ 'FROM ##MappedMark ms
	JOIN [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss ON mss.ContentName = ms.ContentOutline
		AND mss.TopicName = ms.TopicName
		AND mss.MemberNumber = ms.MemberNumber
		AND mss.BrandName = ms.BrandName
		AND mss.LovelySiteIngredient = ms.[LovelySiteIngredient]
		AND mss.Term = '+@Term+'
		AND (mss.Mark <> ms.Mark OR mss.Mark IS NULL)'
;------------------------------
EXECUTE (@Query)
;------------------------------
DECLARE @ROWCOUNT INT
SET @ROWCOUNT = @@ROWCOUNT
;------------------------------
IF @Update = 1 SELECT 'Update :: ' +CONVERT(VARCHAR, @ROWCOUNT)+ ' Row(s) '+CONVERT(VARCHAR,GETDATE(),105)
;----------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.##MappedMark', 'U') IS NOT NULL DROP TABLE ##MappedMark;
;----------------------------------------------------------------------
END