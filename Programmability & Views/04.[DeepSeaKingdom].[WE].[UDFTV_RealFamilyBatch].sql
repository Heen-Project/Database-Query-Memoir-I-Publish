USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_RealFamilyBatch] (@QuarterSession NVARCHAR(MAX) = N'')  
RETURNS @RealFamilyBatchTable TABLE
(  
	[Id] NVARCHAR(MAX),
	[fContentOutlineId] NVARCHAR(MAX),
	[fBrandName] NVARCHAR(MAX),
	[fBatchNumber] NVARCHAR(MAX),
	[ContentOutline] NVARCHAR(MAX),
	[BatchNumber] NVARCHAR(MAX),
	[AllocatedDate] NVARCHAR(MAX), 
	[BrandName] NVARCHAR(MAX),
	[FamilyNumber] NVARCHAR(MAX),
	[FamilyName] NVARCHAR(MAX),
	[FamilyPassword] NVARCHAR(MAX),
	[BrandBusinessId] NVARCHAR(MAX),
	[QuarterSessionId] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN  
DECLARE @RealFamilyBatchId NVARCHAR(MAX), @fContentOutlineId NVARCHAR(MAX), @fBrandName NVARCHAR(MAX), @fBatchNumber NVARCHAR(MAX), @BatchNumber NVARCHAR(MAX), @AllocatedDate NVARCHAR(MAX), @BrandName NVARCHAR(MAX), @Familys NVARCHAR(MAX), @BrandBusinessId NVARCHAR(MAX), @QuarterSessionId NVARCHAR(MAX)
DECLARE @TemporaryRealFamilyBatchTable TABLE ([Id] NVARCHAR(MAX), [fContentOutlineId] NVARCHAR(MAX), [fBrandName] NVARCHAR(MAX), [fBatchNumber] NVARCHAR(MAX), [BatchNumber] NVARCHAR(MAX), [AllocatedDate] NVARCHAR(MAX),  [BrandName] NVARCHAR(MAX), [FamilyNumber] NVARCHAR(MAX), [FamilyName] NVARCHAR(MAX), [FamilyPassword] NVARCHAR(MAX), [BrandBusinessId] NVARCHAR(MAX), [QuarterSessionId] NVARCHAR(MAX))

DECLARE RealFamilyBatch_Cursor CURSOR FOR
SELECT DISTINCT rsg.Id
	,[ContentOutlineId] = SUBSTRING(rsg.FileName, CHARINDEX('|', rsg.FileName)+1, CHARINDEX('|', SUBSTRING(rsg.FileName, CHARINDEX('|', rsg.FileName)+1, LEN(rsg.FileName)))-1)
	,[BrandName] = RTRIM(SUBSTRING(SUBSTRING(rsg.FileName, CHARINDEX('|', rsg.FileName)+1, LEN(rsg.FileName)), CHARINDEX('|', SUBSTRING(rsg.FileName, CHARINDEX('|', rsg.FileName)+1, LEN(rsg.FileName)))+1, CHARINDEX('|', SUBSTRING(SUBSTRING(rsg.FileName, CHARINDEX('|', rsg.FileName)+1, LEN(rsg.FileName)), CHARINDEX('|', SUBSTRING(rsg.FileName, CHARINDEX('|', rsg.FileName)+1, LEN(rsg.FileName)))+1, LEN(SUBSTRING(rsg.FileName, CHARINDEX('|', rsg.FileName)+1, LEN(rsg.FileName)))))-1))
	,[BatchNumber] = RIGHT(rsg.FileName, CHARINDEX('|', REVERSE(rsg.FileName))-1)
	,JSON_VALUE(rsg.FileObject,'$.BatchNumber') AS BatchNumber
	,JSON_VALUE(rsg.FileObject,'$.AllocatedDate') AS AllocatedDate
	,JSON_VALUE(rsg.FileObject,'$.BrandName') AS BrandName
	,JSON_QUERY(rsg.FileObject,'$.Familys') AS Familys
	,JSON_VALUE(rsg.FileObject,'$.BrandBusinessId') AS BrandBusinessId
	,[QuarterSessionId] = LEFT(rsg.FileName, CHARINDEX('|',rsg.FileName)-1)
FROM [LocalDB].Items.dbo.[Galaxy.Model.RealFamilyBatch] rsg
WHERE ISJSON(rsg.FileObject)>0
	AND LEFT(rsg.FileName, CHARINDEX('|',rsg.FileName)-1) LIKE '%'+@QuarterSession+'%'
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.RealFamilyBatch] rsg2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = rsg2.Id) AND rsg2.FileName = rsg.FileName Batch BY rsg2.FileName HAVING MAX(rsg2.SavedDate) = rsg.SavedDate) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = rsg.Id)
OPEN RealFamilyBatch_Cursor
	FETCH NEXT FROM RealFamilyBatch_Cursor INTO @RealFamilyBatchId, @fContentOutlineId, @fBrandName, @fBatchNumber, @BatchNumber, @AllocatedDate, @BrandName, @Familys, @BrandBusinessId, @QuarterSessionId
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		INSERT INTO @TemporaryRealFamilyBatchTable
		SELECT @RealFamilyBatchId, @fContentOutlineId, @fBrandName, @fBatchNumber, @BatchNumber, @AllocatedDate, @BrandName, as_Familys.FamilyNumber, as_Familys.Name, as_Familys.[Password], @BrandBusinessId, @QuarterSessionId
		FROM (SELECT DISTINCT * FROM OPENJSON(@Familys) WITH (FamilyNumber nvarchar(max), Name nvarchar(max),[Password] nvarchar(max))) as_Familys
		--
	FETCH NEXT FROM RealFamilyBatch_Cursor INTO @RealFamilyBatchId, @fContentOutlineId, @fBrandName, @fBatchNumber, @BatchNumber, @AllocatedDate, @BrandName, @Familys, @BrandBusinessId, @QuarterSessionId
	END  
CLOSE RealFamilyBatch_Cursor
DEALLOCATE RealFamilyBatch_Cursor

INSERT INTO @RealFamilyBatchTable 
SELECT DISTINCT trsg.[Id], trsg.[fContentOutlineId], trsg.[fBrandName], trsg.[fBatchNumber], co.Name, trsg.[BatchNumber], trsg.[AllocatedDate],  trsg.[BrandName], trsg.[FamilyNumber], trsg.[FamilyName], trsg.[FamilyPassword], trsg.BrandBusinessId, trsg.QuarterSessionId
FROM @TemporaryRealFamilyBatchTable trsg
	JOIN [LocalDB].Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId =  trsg.[fContentOutlineId] 
RETURN
END