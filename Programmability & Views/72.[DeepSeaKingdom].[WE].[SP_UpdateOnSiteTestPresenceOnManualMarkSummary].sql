USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_UpdateOnsiteTestPresencePresenceOnManualMarkSummary] (
	@Term NVARCHAR(MAX) = N''
	,@WorkshopName NVARCHAR(MAX) = N'Every Single Workshops'
	,@Update BIT = 0
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
SELECT @WorkshopId = Workshops.WorkshopId FROM [LocalDB].Galaxy.dbo.Workshops WHERE Workshops.Name LIKE '%'+@WorkshopName+'%'
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
IF @WorkshopId IS NULL SET @WorkshopName = NULL
;----------------------------------------------------------------------
DECLARE @LinkedServer NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @Query NVARCHAR(MAX)
;----------------------------------------------------------------------
SET @LinkedServer = N'[LocalDB]'
SET @OpenQuery = N'SELECT * FROM [Galaxy].[dbo].[OnsiteTestBusinesss] et WHERE et.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%'' AND NOT EXISTS (SELECT NULL FROM [Galaxy].[dbo].[DeletedItems] di WHERE di.DataId = et.OnsiteTestBusinessId)'
;------------------------------
SET @Query = N''+ CASE WHEN @Update = 1 THEN 'UPDATE mss SET mss.Status = eav.FamilyStatus'
	WHEN @Update = 0 THEN 'SELECT DISTINCT eav.FamilyStatus,mss.Status,mss.*' END + '
	FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
		JOIN (SELECT * FROM DeepSeaKingdom.dbo.ManualBranchDescription mmd WHERE mmd.GalaxyIngredient IN (''FinalTerm'',''MidTerm'')) as_mmd --(jangan lupa cek numbernya kalo ada yang beda, seharusnya gamungkin beda karena utp/uap gamungkin lebih dari 1)
		ON as_mmd.ContentID = mss.ContentIDParent
			AND as_mmd.LovelySiteIngredient = mss.LovelySiteIngredient
			AND as_mmd.Term = mss.Term
			AND as_mmd.Term = '''+@Term+''''+CASE WHEN @WorkshopId IS NULL THEN '' ELSE '
			AND as_mmd.WorkshopId = '''+@WorkshopId+''' AND as_mmd.WorkshopName = mss.WorkshopName' END+'
		JOIN (SELECT DISTINCT ueav.QuarterSessionId, ueav.Topic, ueav.OnsiteTestType, ueav.BrandName, ueav.FamilyMemberNumber, ueav.FamilyMemberName, ueav.FamilyStatus FROM (SELECT DISTINCT [OnsiteTestType] = CASE WHEN LEFT(mess.Description,CHARINDEX('' '', mess.Description)-1) = ''UAP'' THEN ''FinalTerm'' WHEN LEFT(mess.Description,CHARINDEX('' '', mess.Description)-1) = ''UTP'' THEN ''MidTerm'' ELSE NULL END, ea.QuarterSessionId, ea.Topic, ea.BrandName, ea.FamilyMemberNumber, ea.FamilyMemberName, ea.FamilyStatus, [SavedDate] = CONVERT(DATETIME,ea.SavedDate), [MaxSavedDate] = MAX(CONVERT(DATETIME,ea.SavedDate)) OVER (PARTITION BY Topic, FamilyMemberNumber, FamilyMemberName) FROM DeepSeaKingdom.WE.UDFTV_OnsiteTestPresenceVerification('''+@QuarterSessionId+''') ea JOIN OPENQUERY('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') mess ON mess.OnsiteTestBusinessId = ea.OnsiteTestBusinessId) ueav 
	WHERE ueav.MaxSavedDate = ueav.SavedDate) eav ON eav.Topic = mss.ContentName
			AND eav.OnsiteTestType = as_mmd.GalaxyIngredient
			AND eav.FamilyMemberNumber = mss.MemberNumber
			AND eav.QuarterSessionId = mss.QuarterSessionId
	WHERE (mss.Status <> eav.FamilyStatus OR mss.Status IS NULL)
		AND NOT EXISTS (SELECT NULL FROM [DeepSeaKingdom].[dbo].[AppendixSchedule] apx WHERE apx.QuarterSessionId = mss.QuarterSessionId
			AND apx.FamilyId = mss.MemberNumber
			AND apx.TopicCode = LEFT(mss.TopicName,CHARINDEX(''-'',mss.TopicName)-1)
			AND apx.DispendedIngredient IN (''FinalTerm'',''MidTerm'')
			AND apx.DispendedIngredient = as_mmd.GalaxyIngredient
			AND apx.IngredientNumber = 1)'
;------------------------------
EXECUTE(@Query)
;----------------------------------------------------------------------
SET @Query = N''+ CASE WHEN @Update = 1 THEN 'UPDATE mss SET mss.Status = (CASE WHEN apx.isPresent = ''Y'' THEN ''Present'' WHEN apx.isPresent = ''N'' THEN ''Absent'' END)'
	WHEN @Update = 0 THEN 'SELECT DISTINCT [FamilyStatus] =(CASE WHEN apx.isPresent = ''Y'' THEN ''Present'' WHEN apx.isPresent = ''N'' THEN ''Absent'' END), mss.*' END + '
	FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
		JOIN (SELECT * FROM DeepSeaKingdom.dbo.ManualBranchDescription mmd WHERE mmd.GalaxyIngredient IN (''FinalTerm'',''MidTerm'')) as_mmd
		ON as_mmd.ContentID = mss.ContentIDParent
			AND as_mmd.LovelySiteIngredient = mss.LovelySiteIngredient
			AND as_mmd.Term = mss.Term
			AND as_mmd.Term = '''+@Term+''''+CASE WHEN @WorkshopId IS NULL THEN '' ELSE '
			AND as_mmd.WorkshopId = '''+@WorkshopId+''' AND as_mmd.WorkshopName = mss.WorkshopName' END+'
		JOIN [DeepSeaKingdom].[dbo].[AppendixSchedule] apx ON apx.QuarterSessionId = mss.QuarterSessionId
			AND apx.FamilyId = mss.MemberNumber
			AND apx.TopicCode = LEFT(mss.TopicName,CHARINDEX(''-'',mss.TopicName)-1)
			AND apx.DispendedIngredient IN (''FinalTerm'',''MidTerm'')
			AND apx.DispendedIngredient = as_mmd.GalaxyIngredient
			AND apx.IngredientNumber = 1
	WHERE mss.Status <> (CASE WHEN apx.isPresent = ''Y'' THEN ''Present'' WHEN apx.isPresent = ''N'' THEN ''Absent'' END) OR mss.Status IS NULL'
;------------------------------
EXECUTE(@Query)
;----------------------------------------------------------------------
END