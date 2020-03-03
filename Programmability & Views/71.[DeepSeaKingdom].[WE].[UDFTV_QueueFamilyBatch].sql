USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_QueueFamilyBatch] (@QuarterSession NVARCHAR(MAX) = N'')  
RETURNS @QueueFamilyBatchTable TABLE
(  
	[Id] NVARCHAR(MAX),
	[BrandBusinessId] NVARCHAR(MAX),
	[BatchNumber] NVARCHAR(MAX),
	[foId] NVARCHAR(MAX), 
	[Status] NVARCHAR(MAX),
	[FamilyNumber] NVARCHAR(MAX),
	[FamilyName] NVARCHAR(MAX),
	[FamilyPassword] NVARCHAR(MAX),
	[ContentOutline] NVARCHAR(MAX),
	[QuarterSessionId] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN  
DECLARE @QueueFamilyBatchId NVARCHAR(MAX), @BrandBusinessId NVARCHAR(MAX), @BatchNumber NVARCHAR(MAX), @foId NVARCHAR(MAX), @Status NVARCHAR(MAX), @Familys NVARCHAR(MAX), @ContentOutline NVARCHAR(MAX), @QuarterSessionId NVARCHAR(MAX)
DECLARE @TemporaryQueueFamilyBatchTable TABLE ([Id] NVARCHAR(MAX), [BrandBusinessId] NVARCHAR(MAX), [BatchNumber] NVARCHAR(MAX), [foId] NVARCHAR(MAX), [Status] NVARCHAR(MAX), [FamilyNumber] NVARCHAR(MAX), [FamilyName] NVARCHAR(MAX), [FamilyPassword] NVARCHAR(MAX), [ContentOutline] NVARCHAR(MAX), [QuarterSessionId] NVARCHAR(MAX))
DECLARE QueueFamilyBatch_Cursor CURSOR FOR
SELECT DISTINCT qsg.Id
	,JSON_VALUE(qsg.FileObject,'$.BrandBusinessId') AS BrandBusinessId
	,JSON_VALUE(qsg.FileObject,'$.BatchNumber') AS BatchNumber
	,JSON_VALUE(qsg.FileObject,'$.Id') AS foId
	,JSON_VALUE(qsg.FileObject,'$.Status') AS [Status]
	,JSON_QUERY(qsg.FileObject,'$.Familys') AS Familys
	,[ContentOutline] = co.Name
	,[QuarterSessionId] = ct.QuarterSessionId
FROM [LocalDB].Items.dbo.[Galaxy.Model.QueueFamilyBatch] qsg
	JOIN [LocalDB].Galaxy.dbo.BrandBusinesss ct ON ct.BrandBusinessId = LEFT(qsg.FileName, CHARINDEX('|',qsg.FileName)-1)
		AND ISJSON(qsg.FileObject)>0
		AND ct.QuarterSessionId LIKE '%'+@QuarterSession+'%'
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.QueueFamilyBatch] qsg2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = qsg2.Id) AND qsg2.FileName = qsg.FileName Batch BY qsg2.FileName HAVING MAX(qsg2.SavedDate) = qsg.SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = qsg.Id)
	JOIN [LocalDB].Galaxy.dbo.Topics ON Topics.TopicId =  ct.TopicId 
	JOIN [LocalDB].Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId =  Topics.ContentOutlineId 
OPEN QueueFamilyBatch_Cursor
	FETCH NEXT FROM QueueFamilyBatch_Cursor INTO @QueueFamilyBatchId, @BrandBusinessId, @BatchNumber, @foId, @Status, @Familys, @ContentOutline, @QuarterSessionId
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		INSERT INTO @TemporaryQueueFamilyBatchTable
		SELECT @QueueFamilyBatchId, @BrandBusinessId, @BatchNumber, @foId, @Status, as_Familys.FamilyNumber, as_Familys.Name, as_Familys.[Password], @ContentOutline, @QuarterSessionId
		FROM (SELECT DISTINCT * FROM OPENJSON(@Familys) WITH (FamilyNumber nvarchar(max), Name nvarchar(max),[Password] nvarchar(max))) as_Familys
		--
	FETCH NEXT FROM QueueFamilyBatch_Cursor INTO @QueueFamilyBatchId, @BrandBusinessId, @BatchNumber, @foId, @Status, @Familys, @ContentOutline, @QuarterSessionId
	END  
CLOSE QueueFamilyBatch_Cursor
DEALLOCATE QueueFamilyBatch_Cursor

INSERT INTO @QueueFamilyBatchTable 
SELECT DISTINCT tqsg.[Id], tqsg.[BrandBusinessId], tqsg.[BatchNumber], tqsg.[foId], tqsg.[Status], tqsg.[FamilyNumber], tqsg.[FamilyName], tqsg.[FamilyPassword], tqsg.[ContentOutline], tqsg.QuarterSessionId
FROM @TemporaryQueueFamilyBatchTable tqsg
RETURN
END