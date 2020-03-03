USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_TransferFamilyMarkComplain] (
	@Term NVARCHAR(MAX) = N''
	,@Update BIT = 0
	,@NewRow BIT = 0
	,@FamilyComplainMarkPostDate NVARCHAR(MAX) = N''
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
DECLARE @Query NVARCHAR(MAX), @QueryHeader NVARCHAR(MAX), @QueryInner NVARCHAR(MAX)
;----------------------------------------------------------------------
SET @QueryHeader = 'UPDATE ssp SET ssp.TransferStatus = ''Y'''
;------------------------------
SET @QueryInner = '
FROM [ExternalDB].Mark_DB.dbo.FamilyComplainMark spn
	JOIN DeepSeaKingdom.WE.FamilyMarkComplain ssp ON ssp.MemberNumber = spn.EXTERNAL_SYSTEM_ID
		AND LEFT(ssp.TopicName, CHARINDEX(''-'',ssp.TopicName)-1) = spn.Topic + RIGHT(''0000''+LTRIM(spn.CATALOG_NBR),4)
		AND ssp.LovelySiteIngredient = spn.TYPE_DESCR
		AND ssp.Term = spn.Term'
;------------------------------
SET @Query = @QueryHeader + @QueryInner + '
WHERE (spn.ASCID_Associate = '''' OR spn.ASCID_Associate = ''A0001'')
	AND spn.Department = ''YYS01''
	AND spn.Position = ''RS1''
	AND spn.Term <> ''D''
	AND spn.Term = '''+@Term+''''
;------------------------------
IF @Update = 1 EXECUTE (@Query)
;----------------------------------------------------------------------
IF @Update = 0 SET @QueryHeader = 'SELECT spn.Family_Mark_OLD, ssp.OldMark, spn.Family_Mark_NEW, spn.FINAL_Mark, ssp.NewMark, spn.Explanation, [Description] = RTRIM(REPLACE(REPLACE(ssp.[Description],''(false)'','''') ,''(true)'','''')), spn.Term, spn.DateIn, spn.DateUp, spn.PersonIn, spn.PersonUp, spn.ASCID, spn.EXTERNAL_SYSTEM_ID, spn.NAMA, spn.Term, spn.Topic, spn.CATALOG_NBR, spn.Brand_NBR, spn.Brand_SECTION, spn.Content_ID, spn.Content_ATTR_VALUE, spn.DESCR, spn.Orderline, spn.TYPE, spn.TYPE_DESCR, spn.TYPE_WEIGHT, spn.Term_DESCR, spn.Family_Mark_OLD, spn.Family_Mark_NEW, spn.ComplainDate, spn.Status, spn.id, [ExplanationFamily]=REPLACE(REPLACE(REPLACE(CAST(spn.ExplanationFamily as nvarchar(max)), CHAR(13), NCHAR(0x21B5)), CHAR(10), NCHAR(0x21B5)), '', '', ''.''), spn.Explanation, spn.Submit_Dt_ByLect, spn.POST_DT, spn.Approve_Dt_ByLect, spn.FINAL_Mark, spn.IsLab, spn.Department, spn.Position, spn.House, spn.ASCID_Associate, spn.DocumentID, spn.SchoolApprovalDate, spn.DESCRSHORT'
ELSE IF @Update = 1 SET @QueryHeader = 'UPDATE spn SET spn.Family_Mark_NEW = (CASE WHEN (CAST(spn.Family_Mark_OLD AS INT)-ssp.NewMark)=20 OR (CAST(spn.Family_Mark_OLD AS INT)<=20 AND ssp.NewMark=0) THEN spn.Family_Mark_OLD ELSE ssp.NewMark END), spn.Status = ''3'', spn.Explanation = RTRIM(REPLACE(REPLACE(ssp.[Description],''(false)'','''') ,''(true)'','''')), spn.Submit_Dt_ByLect = IIF(spn.Submit_Dt_ByLect IS NULL OR spn.Submit_Dt_ByLect = '''',GETDATE(),spn.Submit_Dt_ByLect)'+CASE WHEN @FamilyComplainMarkPostDate IS NULL OR @FamilyComplainMarkPostDate = '' THEN '' ELSE ', spn.POST_DT = '''+@FamilyComplainMarkPostDate+'''' END+', spn.Approve_Dt_ByLect = IIF(spn.Approve_Dt_ByLect IS NULL OR spn.Approve_Dt_ByLect = '''',GETDATE(),spn.Approve_Dt_ByLect), spn.FINAL_Mark = ssp.NewMark, spn.SchoolApprovalDate = IIF(spn.SchoolApprovalDate IS NULL OR spn.SchoolApprovalDate = '''',GETDATE(),spn.SchoolApprovalDate)'
;------------------------------
SET @QueryInner = '
FROM [ExternalDB].Mark_DB.dbo.FamilyComplainMark spn
	JOIN DeepSeaKingdom.WE.FamilyMarkComplain ssp ON ssp.MemberNumber = spn.EXTERNAL_SYSTEM_ID
		AND LEFT(ssp.TopicName, CHARINDEX(''-'',ssp.TopicName)-1) = spn.Topic + RIGHT(''0000''+LTRIM(spn.CATALOG_NBR),4)
		AND ssp.LovelySiteIngredient = spn.TYPE_DESCR
		AND ssp.Term = spn.Term'
;------------------------------
SET @Query = @QueryHeader + @QueryInner + '
WHERE (spn.ASCID_Associate = '''' OR spn.ASCID_Associate = ''A0001'')
	AND spn.Department = ''YYS01''
	AND spn.Position = ''RS1''
	--AND spn.Status = ''2''
	AND spn.Term <> ''D''
	'+CASE WHEN @NewRow = 1 THEN 'AND DATEDIFF(DAY,spn.ComplainDate,GETDATE()) < 32' ELSE '' END+'
	AND spn.Term = '''+@Term+'''
	AND (spn.FINAL_Mark = ssp.NewMark OR spn.FINAL_Mark IS NULL)'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @QueryHeader = 'SELECT spn.Term,spn.DateIn,spn.DateUp,spn.PersonIn,spn.PersonUp,spn.ASCID,spn.EXTERNAL_SYSTEM_ID,spn.NAMA,spn.Term,spn.Topic,spn.CATALOG_NBR,spn.Brand_NBR,spn.Brand_SECTION,spn.Content_ID,spn.Content_ATTR_VALUE,spn.DESCR,spn.Orderline,spn.TYPE,spn.TYPE_DESCR,spn.TYPE_WEIGHT,spn.Term_DESCR,spn.Family_Mark_OLD,spn.Family_Mark_NEW,spn.ComplainDate,spn.Status,spn.id,[ExplanationFamily] = REPLACE(REPLACE(REPLACE(CAST(spn.ExplanationFamily as nvarchar(max)),CHAR(13),NCHAR(0x21B5)),CHAR(10),NCHAR(0x21B5)),'','',''.''),spn.Explanation,spn.Submit_Dt_ByLect,spn.POST_DT,spn.Approve_Dt_ByLect,spn.FINAL_Mark,spn.IsLab,spn.Department,spn.Position,spn.House,spn.ASCID_Associate,spn.DocumentID,spn.SchoolApprovalDate,spn.DESCRSHORT'
;------------------------------
SET @QueryInner = '
FROM [ExternalDB].Mark_DB.dbo.FamilyComplainMark spn
	LEFT JOIN DeepSeaKingdom.WE.FamilyMarkComplain ssp ON ssp.MemberNumber = spn.EXTERNAL_SYSTEM_ID
		AND LEFT(ssp.TopicName, CHARINDEX(''-'',ssp.TopicName)-1) = spn.Topic + RIGHT(''0000''+LTRIM(spn.CATALOG_NBR),4)
		AND ssp.LovelySiteIngredient = spn.TYPE_DESCR
		AND ssp.Term = spn.Term'
;------------------------------
SET @Query = @QueryHeader + @QueryInner + '
WHERE (spn.ASCID_Associate = '''' OR spn.ASCID_Associate = ''A0001'')
	AND spn.Department = ''YYS01''
	AND spn.Position = ''RS1''
	--AND spn.Status = ''2''
	AND spn.Term <> ''D''
	'+CASE WHEN @NewRow = 1 THEN 'AND DATEDIFF(DAY,spn.ComplainDate,GETDATE()) < 32' ELSE '' END+'
	AND spn.Term = '''+@Term+'''
	AND ssp.Term IS NULL'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
IF @Update = 0 SET @QueryHeader = 'SELECT DISTINCT ssp.Term, ssp.WorkshopName, ssp.ContentOutline, ssp.TopicName, ssp.MemberNumber, ssp.MemberName, ssp.NewMark, ssp.OldMark, [Description] = ssp.[Description], ssp.LovelySiteIngredient, ssp.TransferStatus'
ELSE IF @Update = 1 SET @QueryHeader = 'UPDATE ssp SET ssp.TransferStatus = ''N'''
;------------------------------
SET @QueryInner = '
FROM [ExternalDB].Mark_DB.dbo.FamilyComplainMark spn
	RIGHT JOIN DeepSeaKingdom.WE.FamilyMarkComplain ssp ON ssp.MemberNumber = spn.EXTERNAL_SYSTEM_ID
		AND LEFT(ssp.TopicName, CHARINDEX(''-'',ssp.TopicName)-1) = spn.Topic + RIGHT(''0000''+LTRIM(spn.CATALOG_NBR),4)
		AND ssp.LovelySiteIngredient = spn.TYPE_DESCR
		AND ssp.Term = spn.Term'
;------------------------------
SET @Query = @QueryHeader + @QueryInner + '
WHERE spn.Term IS NULL
	AND ssp.Term = '''+@Term+''''
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END