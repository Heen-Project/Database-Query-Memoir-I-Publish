USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_FamilyResponsibilityBatch] (@QuarterSession NVARCHAR(MAX))  
RETURNS @FamilyResponsibilityBatchTable TABLE
(  
	[Id] NVARCHAR(MAX),
	[fQuarterSessionId] NVARCHAR(MAX),
	[fContentOutlineId] NVARCHAR(MAX),
	[fBrandBusinessId] NVARCHAR(MAX),
	[fResponsibilityNumber] NVARCHAR(MAX),
	[fBatchNumber] NVARCHAR(MAX),
	[ContentOutline] NVARCHAR(MAX),
	[BatchNumber] NVARCHAR(MAX),
	[AllocatedDate] NVARCHAR(MAX),
	[BrandName] NVARCHAR(MAX),
	[Session] NVARCHAR(MAX),
	[Number] NVARCHAR(MAX),
	[BrandBusinessId] NVARCHAR(MAX),
	[BrandBusinessDetailId] NVARCHAR(MAX),
	[FamilyId] NVARCHAR(MAX),
	[FamilyNumber] NVARCHAR(MAX),
	[FamilyName] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN  
DECLARE @FamilyResponsibilityBatchId NVARCHAR(MAX)
DECLARE @fQuarterSessionId NVARCHAR(MAX)
DECLARE @fContentOutlineId NVARCHAR(MAX)
DECLARE @fBrandBusinessId NVARCHAR(MAX)
DECLARE @fResponsibilityNumber NVARCHAR(MAX)
DECLARE @fBatchNumber NVARCHAR(MAX)
DECLARE @BatchNumber NVARCHAR(MAX)
DECLARE @AllocatedDate NVARCHAR(MAX)
DECLARE @BrandName NVARCHAR(MAX)
DECLARE @Session NVARCHAR(MAX)
DECLARE @Number NVARCHAR(MAX)
DECLARE @Familys NVARCHAR(MAX)
DECLARE @BrandBusinessId NVARCHAR(MAX)
DECLARE @BrandBusinessDetailId NVARCHAR(MAX)
DECLARE @TemporaryFamilyResponsibilityBatchTable TABLE ([Id] NVARCHAR(MAX), [fQuarterSessionId] NVARCHAR(MAX), [fContentOutlineId] NVARCHAR(MAX), [fBrandBusinessId] NVARCHAR(MAX), [fResponsibilityNumber] NVARCHAR(MAX), [fBatchNumber] NVARCHAR(MAX), [BatchNumber] NVARCHAR(MAX), [AllocatedDate] NVARCHAR(MAX), [BrandName] NVARCHAR(MAX), [Session] NVARCHAR(MAX), [Number] NVARCHAR(MAX), [BrandBusinessId] NVARCHAR(MAX), [BrandBusinessDetailId] NVARCHAR(MAX), [FamilyId] NVARCHAR(MAX), [FamilyNumber] NVARCHAR(MAX), [FamilyName] NVARCHAR(MAX) )

DECLARE FamilyResponsibilityBatch_Cursor CURSOR FOR
SELECT DISTINCT sag.Id
	,[fQuarterSessionId] = DeepSeaKingdom.dbo.UDF_Split(sag.FileName,'|',1)
	,[fContentOutlineId] = DeepSeaKingdom.dbo.UDF_Split(sag.FileName,'|',2)
	,[fBrandBusinessId] = DeepSeaKingdom.dbo.UDF_Split(sag.FileName,'|',3)
	,[fResponsibilityNumber] = DeepSeaKingdom.dbo.UDF_Split(sag.FileName,'|',4)
	,[fBatchNumber] = DeepSeaKingdom.dbo.UDF_Split(sag.FileName,'|',5)
	,JSON_VALUE(sag.FileObject,'$.BatchNumber') AS BatchNumber
	,JSON_VALUE(sag.FileObject,'$.AllocatedDate') AS AllocatedDate
	,JSON_VALUE(sag.FileObject,'$.BrandName') AS BrandName
	,JSON_VALUE(sag.FileObject,'$.Session') AS Session
	,JSON_VALUE(sag.FileObject,'$.Number') AS Number
	,JSON_QUERY(sag.FileObject,'$.Familys') AS Familys
	,JSON_VALUE(sag.FileObject,'$.BrandBusinessId') AS BrandBusinessId
	,JSON_VALUE(sag.FileObject,'$.BrandBusinessDetailId') AS BrandBusinessDetailId
FROM [LocalDB].Items.dbo.[Galaxy.Model.FamilyResponsibilityBatch] sag
WHERE ISJSON(sag.FileObject)>0
	AND DeepSeaKingdom.dbo.UDF_Split(sag.FileName,'|',1) LIKE '%'+@QuarterSession+'%'
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.FamilyResponsibilityBatch] sag2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = sag2.Id) AND sag2.FileName = sag.FileName Batch BY sag2.FileName HAVING MAX(sag2.SavedDate) = sag.SavedDate) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = sag.Id)
OPEN FamilyResponsibilityBatch_Cursor
	FETCH NEXT FROM FamilyResponsibilityBatch_Cursor INTO @FamilyResponsibilityBatchId, @fQuarterSessionId, @fContentOutlineId, @fBrandBusinessId, @fResponsibilityNumber, @fBatchNumber, @BatchNumber, @AllocatedDate, @BrandName, @Session, @Number, @Familys, @BrandBusinessId, @BrandBusinessDetailId
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		INSERT INTO @TemporaryFamilyResponsibilityBatchTable
		SELECT @FamilyResponsibilityBatchId, @fQuarterSessionId, @fContentOutlineId, @fBrandBusinessId, @fResponsibilityNumber, @fBatchNumber, @BatchNumber, @AllocatedDate, @BrandName, @Session, @Number, @BrandBusinessId, @BrandBusinessDetailId, as_Familys.FamilyId, as_Familys.FamilyNumber, as_Familys.Name
		FROM (SELECT DISTINCT * FROM OPENJSON(@Familys) WITH (FamilyId nvarchar(max),FamilyNumber nvarchar(max), Name nvarchar(max))) as_Familys
		--
	FETCH NEXT FROM FamilyResponsibilityBatch_Cursor INTO @FamilyResponsibilityBatchId, @fQuarterSessionId, @fContentOutlineId, @fBrandBusinessId, @fResponsibilityNumber, @fBatchNumber, @BatchNumber, @AllocatedDate, @BrandName, @Session, @Number, @Familys, @BrandBusinessId, @BrandBusinessDetailId
	END  
CLOSE FamilyResponsibilityBatch_Cursor
DEALLOCATE FamilyResponsibilityBatch_Cursor

INSERT INTO @FamilyResponsibilityBatchTable 
SELECT DISTINCT tsag.[Id], tsag.[fQuarterSessionId], tsag.[fContentOutlineId], tsag.[fBrandBusinessId], tsag.[fResponsibilityNumber], tsag.[fBatchNumber], co.Name, tsag.[BatchNumber], tsag.[AllocatedDate], tsag.[BrandName], tsag.[Session], tsag.[Number], tsag.[BrandBusinessId], tsag.[BrandBusinessDetailId], tsag.[FamilyId], tsag.[FamilyNumber], tsag.[FamilyName]
FROM @TemporaryFamilyResponsibilityBatchTable tsag
	JOIN [LocalDB].Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId =  tsag.[fContentOutlineId] 
RETURN
END