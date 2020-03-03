USE [Seaweed]
GO
CREATE PROCEDURE [dbo].[SP_ManualMarkSummaryForPrint] 
    @QuarterSessionId nvarchar(50),
	@WorkshopId nvarchar(50),
    @LovelySiteIngredient nvarchar(50),
    @PageNumber nvarchar(5) = '1'
WITH RECOMPILE--, ENCRYPTION
AS   
    SET NOCOUNT ON;  
	--SELECT DISTINCT * 
	--FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
	--WHERE mss.QuarterSessionId = @QuarterSessionId
	--	AND mss.WorkshopId = @WorkshopId
	--	AND mss.LovelySiteIngredient = @LovelySiteIngredient
	DECLARE @RowspPage AS INT, @PageNumberInt INT
	SET @RowspPage = 1000
	IF (ISNUMERIC(@PageNumber) = 1) SET @PageNumberInt = CONVERT(INT,@PageNumber)
	ELSE SET @PageNumberInt = 1
	IF (ISNUMERIC(@PageNumber) = 1) BEGIN
	SELECT DISTINCT * INTO #ManualMarkSummary
	FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
	WHERE mss.QuarterSessionId = @QuarterSessionId
		AND mss.WorkshopId = @WorkshopId
		AND mss.LovelySiteIngredient = @LovelySiteIngredient
	SELECT DISTINCT * FROM #ManualMarkSummary mss ORDER BY mss.Id
	OFFSET ((@PageNumberInt - 1) * @RowspPage) ROWS
	FETCH NEXT @RowspPage ROWS ONLY;
	END
GO
CREATE PROCEDURE [dbo].[SP_ManualMarkSummaryForPrintInformation] 
    @QuarterSessionId nvarchar(50),
	@WorkshopId nvarchar(50),
    @LovelySiteIngredient nvarchar(50)
WITH RECOMPILE--, ENCRYPTION
AS   
    SET NOCOUNT ON;  
	--SELECT DISTINCT * 
	--FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
	--WHERE mss.QuarterSessionId = @QuarterSessionId
	--	AND mss.WorkshopId = @WorkshopId
	--	AND mss.LovelySiteIngredient = @LovelySiteIngredient
	DECLARE @RowspPage AS INT
	SET @RowspPage = 1000
	BEGIN
		SELECT DISTINCT * INTO #ManualMarkSummary
		FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
		WHERE mss.QuarterSessionId = @QuarterSessionId
			AND mss.WorkshopId = @WorkshopId
			AND mss.LovelySiteIngredient = @LovelySiteIngredient
		SELECT CONVERT(INT, @@ROWCOUNT) [TotalData], CONVERT(INT, CEILING((CONVERT(FLOAT,@@ROWCOUNT)/CONVERT(FLOAT, @RowspPage)))) [TotalPage]
	END
GO
CREATE PROCEDURE [dbo].[SP_ManualBranchDescriptionForPrint] 
    @QuarterSessionId nvarchar(50),
	@WorkshopId nvarchar(50),
	@DepartmentId nvarchar(50) = ''
WITH RECOMPILE--, ENCRYPTION
AS   
    SET NOCOUNT ON;  
	IF (@DepartmentId = '') SET @DepartmentId = NULL
	DECLARE @EmptyGuid uniqueidentifier = CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000')
	SELECT DISTINCT messInner.* INTO #Department FROM OPENQUERY([LocalDB], 'SELECT DISTINCT co.ContentOutlineId, co.Name [ContentName], co.SessionRuleId, s.TopicId, s.Name [TopicName], s.WorkshopId, s.DepartmentId FROM [Galaxy].[dbo].[Topics] s JOIN [Galaxy].[dbo].[ContentOutlines] co ON s.ContentOutlineId = co.ContentOutlineId AND s.Name = co.Name') messInner
	SELECT DISTINCT mmd.LovelySiteIngredient 
	FROM [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd
		JOIN (SELECT DISTINCT messInner.ContentName, messInner.DepartmentId FROM #Department messInner WHERE IIF(@DepartmentId IS NOT NULL , messInner.DepartmentId, @EmptyGuid) = ISNULL(@DepartmentId, @EmptyGuid)) mess ON LEFT(mess.ContentName, CHARINDEX('-', mess.ContentName)-1) = mmd.ContentCode
			AND mmd.QuarterSessionId = @QuarterSessionId
			AND mmd.WorkshopId = @WorkshopId
GO
CREATE PROCEDURE [dbo].[SP_ManualMarkSummaryForBusinessDetail]
    @QuarterSessionId nvarchar(50),
    @MemberIdXXX nvarchar(50)
WITH RECOMPILE--, ENCRYPTION
AS   
    SET NOCOUNT ON;  
	SELECT DISTINCT mss.* 
	FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
	WHERE mss.QuarterSessionId = @QuarterSessionId
		AND mss.MemberIdXXX = @MemberIdXXX
	ORDER BY mss.ContentName, mss.BrandName, mss.LovelySiteIngredient

GO
CREATE PROCEDURE [dbo].[SP_ManualBranchDescriptionForBusinessDetail]
    @QuarterSessionId nvarchar(50),
    @ContentCode nvarchar(50)
WITH RECOMPILE--, ENCRYPTION
AS   
    SET NOCOUNT ON;  
	SELECT DISTINCT mmd.* 
	FROM [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd
	WHERE mmd.QuarterSessionId = @QuarterSessionId
		AND mmd.ContentCode = @ContentCode
	ORDER BY mmd.ContentCode, mmd.GalaxyIngredient, mmd.GalaxyPercentage, mmd.LovelySiteIngredient, LovelySitePercentage, mmd.GalaxyNumber

GO
--EXEC [SP_ManualMarkSummaryForPrint] '1AF011CC-376F-E611-903A-D8D385FCE79E', 'F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C', 'LAB: WORKSHEET'
EXEC [SP_ManualMarkSummaryForPrint] '1AF011CC-376F-E611-903A-D8D385FCE79E', 'F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C', 'LAB: FINAL OnsiteTest', '2'
EXEC [SP_ManualMarkSummaryForPrintInformation] '1AF011CC-376F-E611-903A-D8D385FCE79E', 'F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C', 'LAB: FINAL OnsiteTest'
EXEC [SP_ManualBranchDescriptionForPrint] '1AF011CC-376F-E611-903A-D8D385FCE79E', 'F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C', ''
EXEC [SP_ManualMarkSummaryForBusinessDetail] '1AF011CC-376F-E611-903A-D8D385FCE79E', '781B52B6-10A1-DF11-8A5A-D8D385FCE79C'
EXEC [SP_ManualBranchDescriptionForBusinessDetail] '1AF011CC-376F-E611-903A-D8D385FCE79E', 'CPEN6073'


--http://DeepSeaKingdom.HYU/Utility/getManualMarkSummaryForPrint?QuarterSessionId=1AF011CC-376F-E611-903A-D8D385FCE79E&WorkshopId=F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C&LovelySiteIngredient=LAB:%20WORKSHEET
--http://DeepSeaKingdom.HYU/Utility/getManualMarkSummaryForPrint?QuarterSessionId=1AF011CC-376F-E611-903A-D8D385FCE79E&WorkshopId=F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C&LovelySiteIngredient=LAB:%20WORKSHEET&PageNumber=2
--http://DeepSeaKingdom.HYU/Utility/getManualMarkSummaryForPrintInformation?QuarterSessionId=1AF011CC-376F-E611-903A-D8D385FCE79E&WorkshopId=F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C&LovelySiteIngredient=LAB:%20WORKSHEET
--http://DeepSeaKingdom.HYU/Utility/getManualBranchDescriptionForPrint?QuarterSessionId=1AF011CC-376F-E611-903A-D8D385FCE79E&WorkshopId=F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C&DepartmentId=
--http://DeepSeaKingdom.HYU/Utility/ManualMarkSummaryForBusinessDetail?QuarterSessionId=1AF011CC-376F-E611-903A-D8D385FCE79E&MemberIdXXX=781B52B6-10A1-DF11-8A5A-D8D385FCE79C
--http://DeepSeaKingdom.HYU/Utility/getManualBranchDescriptionForBusinessDetail?QuarterSessionId=1AF011CC-376F-E611-903A-D8D385FCE79E&ContentCode=CPEN6073