USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_ExportMarkEpitomeAppendix](
	@Term NVARCHAR(MAX) = N''
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX), @LovelySiteIngredient NVARCHAR(MAX), @QueryInner NVARCHAR(MAX), @Query NVARCHAR(MAX), @FileName VARCHAR(MAX), @bcpCommand VARCHAR(8000)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
SELECT @WorkshopId = Workshops.WorkshopId FROM [LocalDB].Galaxy.dbo.Workshops WHERE Workshops.Name LIKE '%'+@WorkshopName+'%'
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
IF @WorkshopId IS NULL SET @WorkshopName = NULL
;----------------------------------------------------------------------
DECLARE LovelySiteIngredient_Cursor CURSOR FOR
SELECT DISTINCT mmd.LovelySiteIngredient FROM DeepSeaKingdom.dbo.ManualBranchDescription mmd WHERE mmd.WorkshopName = @WorkshopName AND mmd.Term = @Term
OPEN LovelySiteIngredient_Cursor
	FETCH NEXT FROM LovelySiteIngredient_Cursor INTO @LovelySiteIngredient
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		SET @FileName = REPLACE('D:\'+REPLACE(@LovelySiteIngredient, ':','')+' ['+@Term+'] Epitome '+CONVERT(VARCHAR,GETDATE(),105)+'.csv','/','-')
		SET @QueryInner = 'SELECT [Gugus Mata Kuliah] = ''Gugus Mata Kuliah'',[Mata Kuliah] = ''Mata Kuliah'',[Kelas] = ''Kelas'',[Dosen] = ''Dosen'',[Jumlah Mahasiswa] = ''Jumlah Mahasiswa'',[Jumlah Mark] = ''Jumlah Mark'',[Jumlah Kehadiran] = ''Jumlah Kehadiran'', [OrderKey] = 1 UNION ALL SELECT DISTINCT [Gugus Mata Kuliah] = IIF(d.DESCR100_2 = d.DESCR100_3, d.DESCR100_2, ISNULL(d.DESCR100_2+''-''+d.DESCR100_3,d.DESCR100_2)),[Mata Kuliah] = mss.TopicName,[Kelas] = mss.BrandName+''-''+mss.BrandNameTheory,[Dosen] = UPPER(mss.AssociateCode+''-''+mss.AssociateName),[Jumlah Mahasiswa] = CONVERT(VARCHAR,COUNT(mss.MemberNumber) OVER (PARTITION BY mss.BrandNbr)),[Jumlah Mark] = CONVERT(VARCHAR,SUM(CAST(mss.Mark AS int)) OVER (PARTITION BY mss.BrandNbr))/*,[Jumlah Kehadiran] = CONVERT(VARCHAR,SUM(CAST(sas.TotalPresent AS int)) OVER (PARTITION BY sas.TopicName, sas.BrandName))*/,[Jumlah Kehadiran] = CONVERT(VARCHAR,SUM(CAST(sas.MeetingCount-sas.TotalAbsent AS int)) OVER (PARTITION BY sas.TopicName, sas.BrandName)), [OrderKey] = 2 FROM DeepSeaKingdom.dbo.ManualMarkSummary mss JOIN DeepSeaKingdom.WE.FamilyPresenceSummary sas ON sas.TopicName = mss.TopicName AND sas.BrandName = mss.BrandName AND sas.MemberNumber = mss.MemberNumber AND mss.LovelySiteIngredient = '''+@LovelySiteIngredient+''' AND mss.WorkshopName = '''+@WorkshopName+''' AND mss.Term = '''+@Term+''' JOIN DeepSeaKingdom.dbo.Departments d ON d.Content_ID = mss.ContentID ORDER BY [OrderKey],1,2,3'
		SET @bcpCommand = 'bcp "'+@QueryInner+'" queryout "'
		SET @bcpCommand = @bcpCommand + @FileName + '" -T -t , -c'
		EXEC master.dbo.xp_cmdshell @bcpCommand
		--
	FETCH NEXT FROM LovelySiteIngredient_Cursor INTO @LovelySiteIngredient
	END  
CLOSE LovelySiteIngredient_Cursor
DEALLOCATE LovelySiteIngredient_Cursor
;----------------------------------------------------------------------
END

