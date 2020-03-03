USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateFamilyPresenceSummary] (
	@Term NVARCHAR(MAX) = N''
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
IF OBJECT_ID('tempdb.dbo.##FamilyPresenceSummary', 'U') IS NOT NULL DROP TABLE ##FamilyPresenceSummary;
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
;----------------------------------------------------------------------
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @Query NVARCHAR(MAX), @QuarterSessionIdLike NVARCHAR(MAX), @LinkedQuery NVARCHAR(MAX), @LinkedQueryExec NVARCHAR(MAX)
;----------------------------------------------------------------------
SET @LinkedServer = N'[LocalDB]'
;------------------------------
SET @QuarterSessionIdLike = '%'+@QuarterSessionId+'%'
;------------------------------
SET @LinkedQuery = 'IF OBJECT_ID(''tempdb.dbo.#TempBusinessPresences'', ''U'') IS NOT NULL DROP TABLE #TempBusinessPresences;
	IF OBJECT_ID(''Temporary.WE.TempBusinessPresences'', ''U'') IS NOT NULL DROP TABLE Temporary.WE.TempBusinessPresences;
	SELECT as_ta.BusinessPresenceId, as_ta.BrandBusinessDetailId, as_ta.MemberId, as_ta.AttendDate, as_ta.AttendPlace, as_ta.Status, as_ta.InsertedDate
	INTO #TempBusinessPresences 
	FROM (SELECT ta.BusinessPresenceId, ta.BrandBusinessDetailId, ta.MemberId, ta.AttendDate, ta.AttendPlace, ta.Status, ta.InsertedDate, [Orderline] = ROW_NUMBER() OVER (PARTITION BY ta.BrandBusinessDetailId, ta.MemberId ORDER BY ta.InsertedDate DESC) FROM Galaxy.dbo.BusinessPresences ta) AS as_ta
	WHERE as_ta.Orderline = 1;
	SELECT DISTINCT [WorkshopName] = lab.Name
		,[ContentOutline] = co.Name
		,[TopicName] = Topics.Name
		,[AssociateCode] = ct.AssociateCode
		,[AssociateName] = ct.AssociateName
		,[MemberNumber] = bFamilyXXX.Number
		,[MemberName] = bFamilyXXX.Name
		,[BrandName] = RTRIM(LEFT(ct.BrandName, 5))
		,[MemberId] = bFamilyXXX.MemberId
		,[QuarterSessionId] = ct.QuarterSessionId
		,[ContentOutlineId] = Topics.ContentOutlineId
		,[TotalPresent] = ISNULL(SUM(CASE WHEN ta.Status LIKE ''Present##%'' OR ta.Status LIKE ''Dispensation##%'' THEN 1 ELSE NULL END) OVER (PARTITION BY ct.BrandBusinessId, ta.MemberId),0)
		,[TotalAbsent] = ISNULL(SUM(CASE WHEN ta.Status LIKE ''Late##%'' OR ta.Status LIKE ''Absent##%'' THEN 1 ELSE NULL END) OVER (PARTITION BY ct.BrandBusinessId, ta.MemberId),0)
		,[MeetingCount] = COUNT(ctd.BrandBusinessDetailId) OVER (PARTITION BY ct.BrandBusinessId,bFamilyXXX.MemberId)
	INTO Temporary.WE.TempBusinessPresences
	FROM Galaxy.dbo.BrandBusinesss ct 
		JOIN Galaxy.dbo.Topics ON Topics.TopicId = ct.TopicId
			AND ct.QuarterSessionId LIKE ?
			AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)
		JOIN Galaxy.dbo.BrandBusinessFamilys cts ON cts.BrandBusinessId = ct.BrandBusinessId
			AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedBrandBusinessFamilys dcts WHERE dcts.BrandBusinessFamilyId = cts.BrandBusinessFamilyId AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = dcts.DeletedBrandBusinessFamilyId))
		JOIN Galaxy.dbo.Workshops lab ON lab.WorkshopId = Topics.WorkshopId
		JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId
		JOIN Galaxy.dbo.Members bFamilyXXX ON bFamilyXXX.MemberId = cts.MemberId
		JOIN Galaxy.dbo.BrandBusinessDetails ctd ON ctd.BrandBusinessId = ct.BrandBusinessId
			AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ctd.BrandBusinessDetailId)
		LEFT JOIN #TempBusinessPresences ta ON ta.BrandBusinessDetailId = ctd.BrandBusinessDetailId
			AND ta.MemberId = bFamilyXXX.MemberId'
SET @LinkedQueryExec = 'EXECUTE ('''+replace(@LinkedQuery,'''','''''')+''', '''+@QuarterSessionIdLike+''') AT '+@LinkedServer
;------------------------------
EXECUTE (@LinkedQueryExec)
;----------------------------------------------------------------------
SET @OpenQuery = N'SELECT * FROM Temporary.WE.TempBusinessPresences'
;------------------------------
SET @Query = N'SELECT mess.WorkshopName, mess.ContentOutline, mess.TopicName, mess.AssociateCode, mess.AssociateName, mess.MemberNumber, mess.MemberName, mess.BrandName, mess.MemberId, mess.QuarterSessionId, mess.ContentOutlineId, mess.TotalPresent, mess.TotalAbsent, mess.MeetingCount
	INTO ##FamilyPresenceSummary
	FROM OPENQUERY('+@LinkedServer+','''+replace(@OpenQuery,'''','''''')+''') mess'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @LinkedQuery = 'IF OBJECT_ID(''tempdb.dbo.#TempBusinessPresences'', ''U'') IS NOT NULL DROP TABLE #TempBusinessPresences;
	IF OBJECT_ID(''Temporary.WE.TempBusinessPresences'', ''U'') IS NOT NULL DROP TABLE Temporary.WE.TempBusinessPresences;'
SET @LinkedQueryExec = 'EXECUTE ('''+replace(@LinkedQuery,'''','''''')+''', '''+@QuarterSessionIdLike+''') AT '+@LinkedServer
;------------------------------
EXECUTE (@LinkedQueryExec)
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.FamilyPresenceSummary', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.FamilyPresenceSummary;
;------------------------------
SELECT  [Term] = @Term, WorkshopName, ContentOutline, TopicName, AssociateCode, AssociateName, MemberNumber, MemberName, BrandName, MemberId, QuarterSessionId, ContentOutlineId, MAX(TotalPresent) TotalPresent, MAX(TotalAbsent) TotalAbsent, MAX(MeetingCount) MeetingCount
INTO DeepSeaKingdom.WE.FamilyPresenceSummary
FROM ##FamilyPresenceSummary
Batch BY WorkshopName, ContentOutline, TopicName, AssociateCode, AssociateName, MemberNumber, MemberName, BrandName, MemberId, QuarterSessionId, ContentOutlineId
;------------------------------
IF OBJECT_ID('tempdb.dbo.##FamilyPresenceSummary', 'U') IS NOT NULL DROP TABLE ##FamilyPresenceSummary;
;----------------------------------------------------------------------
/*
Instead, for a permanent table you can use
IF OBJECT_ID('dbo.Marks', 'U') IS NOT NULL 
  DROP TABLE dbo.Marks;

Or, for a temporary table you can use
IF OBJECT_ID('tempdb.dbo.#T', 'U') IS NOT NULL
  DROP TABLE #T;
*/
END