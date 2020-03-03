USE [Seaweed]
GO
CREATE PROCEDURE [dbo].[SP_ManualMarkSummaryForReport] 
    @QuarterSessionId nvarchar(50),
	@WorkshopId nvarchar(50),
	@ContentOutlineId nvarchar(50) = '',
	@DepartmentId nvarchar(50) = '',
	@BrandName nvarchar(5) = '',
    @PageNumber nvarchar(5) = '1'
WITH RECOMPILE--, ENCRYPTION
AS   
	SET NOCOUNT ON;
	IF (@ContentOutlineId = '')  SET @ContentOutlineId = NULL
	IF (@DepartmentId = '')  SET @DepartmentId = NULL
	IF (@BrandName = '')  SET @BrandName = NULL
	DECLARE @RowspPage AS INT, @PageNumberInt INT, @EmptyGuid uniqueidentifier = CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000')
	SET @RowspPage = 1000
	IF (ISNUMERIC(@PageNumber) = 1) SET @PageNumberInt = CONVERT(INT,@PageNumber)
	ELSE SET @PageNumberInt = 1
	IF (ISNUMERIC(@PageNumber) = 1)	BEGIN
		SELECT DISTINCT messInner.* INTO #Department FROM OPENQUERY([LocalDB], 'SELECT DISTINCT co.ContentOutlineId, co.Name [ContentName], co.SessionRuleId, s.TopicId, s.Name [TopicName], s.WorkshopId, s.DepartmentId FROM [Galaxy].[dbo].[Topics] s JOIN [Galaxy].[dbo].[ContentOutlines] co ON s.ContentOutlineId = co.ContentOutlineId AND s.Name = co.Name') messInner
		SELECT DISTINCT mss.* INTO #ManualMarkSummary
		FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
			JOIN OPENQUERY([LocalDB], 'SELECT DISTINCT s.* FROM [Galaxy].[dbo].[Topics] s') Topics ON Topics.TopicId = mss.TopicId
				AND mss.QuarterSessionId = @QuarterSessionId
				AND mss.ContentName IN (SELECT DISTINCT mess.ContentName FROM #Department mess WHERE mess.WorkshopId = @WorkshopId)
				AND IIF(@BrandName IS NOT NULL, mss.BrandName, '') = ISNULL(@BrandName, '')
				AND IIF(@ContentOutlineId IS NOT NULL, Topics.ContentOutlineId, @EmptyGuid) = ISNULL(@ContentOutlineId, @EmptyGuid)
			JOIN (SELECT DISTINCT messInner.ContentOutlineId, messInner.DepartmentId FROM #Department messInner) mess ON mess.ContentOutlineId = Topics.ContentOutlineId
				AND IIF(@DepartmentId IS NOT NULL , mess.DepartmentId, @EmptyGuid) = ISNULL(@DepartmentId, @EmptyGuid)
		SELECT DISTINCT * FROM #ManualMarkSummary mss ORDER BY mss.Id
		OFFSET ((@PageNumberInt - 1) * @RowspPage) ROWS
		FETCH NEXT @RowspPage ROWS ONLY;
	END
GO
CREATE PROCEDURE [dbo].[SP_ManualMarkSummaryForReportInformation] 
    @QuarterSessionId nvarchar(50),
	@WorkshopId nvarchar(50),
	@ContentOutlineId nvarchar(50) = '',
	@DepartmentId nvarchar(50) = '',
	@BrandName nvarchar(5) = ''
WITH RECOMPILE--, ENCRYPTION
AS   
	SET NOCOUNT ON;
	IF (@ContentOutlineId = '')  SET @ContentOutlineId = NULL
	IF (@DepartmentId = '')  SET @DepartmentId = NULL
	IF (@BrandName = '')  SET @BrandName = NULL
	DECLARE @RowspPage AS INT, @EmptyGuid uniqueidentifier = CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000')
	SET @RowspPage = 1000
	BEGIN
		SELECT DISTINCT messInner.* INTO #Department FROM OPENQUERY([LocalDB], 'SELECT DISTINCT co.ContentOutlineId, co.Name [ContentName], co.SessionRuleId, s.TopicId, s.Name [TopicName], s.WorkshopId, s.DepartmentId FROM [Galaxy].[dbo].[Topics] s JOIN [Galaxy].[dbo].[ContentOutlines] co ON s.ContentOutlineId = co.ContentOutlineId AND s.Name = co.Name') messInner
		SELECT DISTINCT mss.* INTO #ManualMarkSummary
		FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
			JOIN OPENQUERY([LocalDB], 'SELECT DISTINCT s.* FROM [Galaxy].[dbo].[Topics] s') Topics ON Topics.TopicId = mss.TopicId
				AND mss.QuarterSessionId = @QuarterSessionId
				AND mss.ContentName IN (SELECT DISTINCT mess.ContentName FROM #Department mess WHERE mess.WorkshopId = @WorkshopId)
				AND IIF(@BrandName IS NOT NULL, mss.BrandName, '') = ISNULL(@BrandName, '')
				AND IIF(@ContentOutlineId IS NOT NULL, Topics.ContentOutlineId, @EmptyGuid) = ISNULL(@ContentOutlineId, @EmptyGuid)
			JOIN (SELECT DISTINCT messInner.ContentOutlineId, messInner.DepartmentId FROM #Department messInner) mess ON mess.ContentOutlineId = Topics.ContentOutlineId
				AND IIF(@DepartmentId IS NOT NULL , mess.DepartmentId, @EmptyGuid) = ISNULL(@DepartmentId, @EmptyGuid)
		SELECT CONVERT(INT, @@ROWCOUNT) [TotalData], CONVERT(INT, CEILING((CONVERT(FLOAT,@@ROWCOUNT)/CONVERT(FLOAT, @RowspPage)))) [TotalPage]
	END
GO
CREATE PROCEDURE [dbo].[SP_ManualBranchDescriptionForReport]
    @QuarterSessionId nvarchar(50),
	@WorkshopId nvarchar(50)
WITH RECOMPILE--, ENCRYPTION
AS   
    SET NOCOUNT ON;  
	SELECT DISTINCT mmd.* 
	FROM [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd
	WHERE mmd.QuarterSessionId = @QuarterSessionId
		AND mmd.WorkshopId = @WorkshopId
	ORDER BY mmd.ContentCode, mmd.GalaxyIngredient, mmd.GalaxyPercentage, mmd.LovelySiteIngredient, LovelySitePercentage, mmd.GalaxyNumber
GO
CREATE PROCEDURE [dbo].[SP_ManualMarkSummaryForMarkComplain] 
    @BrandNbrTheory nvarchar(25),
	@MemberYY nvarchar(25),
	@Orderline nvarchar(5),
	@Term nvarchar(5)
WITH RECOMPILE--, ENCRYPTION
AS   
    SET NOCOUNT ON;
	SELECT DISTINCT *
	FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
	WHERE mss.BrandNbrTheory = @BrandNbrTheory
		AND mss.MemberYY = @MemberYY
		AND mss.Orderline = @Orderline
		AND mss.Term = @Term
	ORDER BY mss.Id
GO
CREATE PROCEDURE [dbo].[SP_ManualBranchDescriptionForMarkComplain] 
    @BrandNbrTheory nvarchar(25),
	@MemberYY nvarchar(25),
	@Term nvarchar(5)
WITH RECOMPILE--, ENCRYPTION
AS   
    SET NOCOUNT ON;
	SELECT DISTINCT mmd.*
	FROM [DeepSeaKingdom].[dbo].[ManualBranchDescription] mmd
		JOIN (SELECT DISTINCT mss.ContentIDParent, mss.Term
	FROM [DeepSeaKingdom].[dbo].[ManualMarkSummary] mss
	WHERE mss.BrandNbrTheory = @BrandNbrTheory
		AND mss.MemberYY = @MemberYY
		AND mss.Term = @Term) x ON x.Term = mmd.Term
			AND x.ContentIDParent = mmd.ContentID
GO
EXEC [SP_ManualMarkSummaryForReport] '1AF011CC-376F-E611-903A-D8D385FCE79E', 'F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C', '', '', '', '14'
EXEC [SP_ManualMarkSummaryForReport] '1AF011CC-376F-E611-903A-D8D385FCE79E', 'F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C', '98BBB7FD-6060-E611-903A-D8D385FCE79E', 'E58D1D55-FCEA-DF11-81F2-D8D385FCE79C', 'B201', '1'
EXEC [SP_ManualMarkSummaryForReportInformation] '1AF011CC-376F-E611-903A-D8D385FCE79E', 'F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C', '', '', ''
EXEC [SP_ManualBranchDescriptionForReport] '1AF011CC-376F-E611-903A-D8D385FCE79E', 'F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C'
EXEC [SP_ManualMarkSummaryForMarkComplain] '6571', 'YY000202091', '6', '1610'
EXEC [SP_ManualBranchDescriptionForMarkComplain] '6571', 'YY000202091', '1610'

--http://DeepSeaKingdom.HYU/Utility/getManualMarkSummaryForReport?QuarterSessionId=1AF011CC-376F-E611-903A-D8D385FCE79E&WorkshopId=F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C&PageNumber=1
--http://DeepSeaKingdom.HYU/Utility/getManualMarkSummaryForReport?QuarterSessionId=1AF011CC-376F-E611-903A-D8D385FCE79E&WorkshopId=F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C&ContentOutlineId=98BBB7FD-6060-E611-903A-D8D385FCE79E&DepartmentId=E58D1D55-FCEA-DF11-81F2-D8D385FCE79C&BrandName=B201&PageNumber=1
--http://DeepSeaKingdom.HYU/Utility/getManualMarkSummaryForReportInformation?QuarterSessionId=1AF011CC-376F-E611-903A-D8D385FCE79E&WorkshopId=F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C&ContentOutlineId=98BBB7FD-6060-E611-903A-D8D385FCE79E&DepartmentId=E58D1D55-FCEA-DF11-81F2-D8D385FCE79C&BrandName=B201
--http://DeepSeaKingdom.HYU/Utility/getManualBranchDescriptionForReport?QuarterSessionId=1AF011CC-376F-E611-903A-D8D385FCE79E&WorkshopId=F5BBCBF8-7FAA-DF11-BCA3-D8D385FCE79C
--http://DeepSeaKingdom.HYU/Utility/getManualMarkSummaryForMarkComplain?BrandNbrTheory=6571&MemberYY=YY000202091&Orderline=6&Term=1610
--http://DeepSeaKingdom.HYU/Utility/getManualBranchDescriptionForMarkComplain?BrandNbrTheory=6571&MemberYY=YY000202091&Term=1610
