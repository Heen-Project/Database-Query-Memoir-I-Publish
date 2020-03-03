USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_FamilyMarkEntry] (@QuarterSession NVARCHAR(MAX))  
RETURNS @FamilyMarkEntryTable TABLE
(  
	[Id] NVARCHAR(MAX),
	[ContentOutlineId] NVARCHAR(MAX),
	[QuarterSessionId] NVARCHAR(MAX),
	[ContentName] NVARCHAR(MAX),
	[BrandName] NVARCHAR(MAX),
	[CorrectorType] NVARCHAR(MAX),
	[Type] NVARCHAR(MAX),
	[Number] NVARCHAR(MAX),
	[PersonId] NVARCHAR(MAX),
	[PersonName] NVARCHAR(MAX),
	[HasOffense] NVARCHAR(MAX),
	[Family MemberId] NVARCHAR(MAX),
	[Family BatchNumber] NVARCHAR(MAX),
	[Family MemberNumber] NVARCHAR(MAX),
	[Family Name] NVARCHAR(MAX),
	[Family MarkBeforeOffense] NVARCHAR(MAX),
	[Family Offenses] NVARCHAR(MAX),
	[Family Mark] NVARCHAR(MAX),
	[Family Status] NVARCHAR(MAX),
	[Family UpdateReason] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN  
DECLARE @FamilyMarkEntryId NVARCHAR(MAX)
DECLARE @ContentOutlineId NVARCHAR(MAX)
DECLARE @QuarterSessionId NVARCHAR(MAX)
DECLARE @ContentName NVARCHAR(MAX)
DECLARE @BrandName NVARCHAR(MAX)
DECLARE @CorrectorType NVARCHAR(MAX)
DECLARE @Type NVARCHAR(MAX)
DECLARE @Number NVARCHAR(MAX)
DECLARE @PersonId NVARCHAR(MAX)
DECLARE @Familys NVARCHAR(MAX)
DECLARE @HasOffense NVARCHAR(MAX)

DECLARE FamilyMarkEntry_Cursor CURSOR FOR
SELECT DISTINCT sse.Id
	,JSON_VALUE(sse.FileObject,'$.ContentOutlineId') AS ContentOutlineId
	,JSON_VALUE(sse.FileObject,'$.QuarterSessionId') AS QuarterSessionId
	,JSON_VALUE(sse.FileObject,'$.ContentName') AS ContentName
	,JSON_VALUE(sse.FileObject,'$.BrandName') AS BrandName
	,JSON_VALUE(sse.FileObject,'$.CorrectorType') AS CorrectorType
	,JSON_VALUE(sse.FileObject,'$.Type') AS Type
	,JSON_VALUE(sse.FileObject,'$.Number') AS Number
	,JSON_VALUE(sse.FileObject,'$.PersonId') AS PersonId
	,JSON_QUERY(sse.FileObject,'$.Familys') AS Familys
	,JSON_VALUE(sse.FileObject,'$.HasOffense') AS HasOffense
FROM [LocalDB].Items.dbo.[Galaxy.Model.FamilyMarkEntry] sse
WHERE ISJSON(sse.FileObject)>0
	AND RIGHT(sse.FileName, CHARINDEX('|', REVERSE(sse.FileName))-1) LIKE '%'+@QuarterSession+'%'
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.FamilyMarkEntry] sse2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = sse2.Id) AND sse2.FileName = sse.FileName Batch BY sse2.FileName HAVING MAX(sse2.SavedDate) = sse.SavedDate) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = sse.Id)
OPEN FamilyMarkEntry_Cursor
	FETCH NEXT FROM FamilyMarkEntry_Cursor INTO @FamilyMarkEntryId, @ContentOutlineId, @QuarterSessionId, @ContentName, @BrandName, @CorrectorType, @Type, @Number, @PersonId, @Familys, @HasOffense
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		INSERT INTO @FamilyMarkEntryTable
		SELECT @FamilyMarkEntryId, @ContentOutlineId, @QuarterSessionId, @ContentName, @BrandName, @CorrectorType, @Type, @Number, @PersonId, [Personname] = (SELECT nm.Personname FROM [LocalDB].Galaxy.dbo.NameBranchs nm WHERE nm.PersonId = @PersonId), @HasOffense, as_Familys.MemberId, as_Familys.BatchNumber, as_Familys.MemberNumber, as_Familys.Name, as_Familys.MarkBeforeOffense, as_Familys.Offenses, as_Familys.Mark, as_Familys.Status, as_Familys.UpdateReason
		FROM (SELECT DISTINCT * FROM OPENJSON(@Familys) WITH (MemberId nvarchar(max), BatchNumber nvarchar(max), MemberNumber nvarchar(max), Name nvarchar(max), MarkBeforeOffense nvarchar(max), Offenses nvarchar(max) '$.Offenses' AS JSON, Mark nvarchar(max), Status nvarchar(max), UpdateReason nvarchar(max))) as_Familys
		--
	FETCH NEXT FROM FamilyMarkEntry_Cursor INTO @FamilyMarkEntryId, @ContentOutlineId, @QuarterSessionId, @ContentName, @BrandName, @CorrectorType, @Type, @Number, @PersonId, @Familys, @HasOffense
	END  
CLOSE FamilyMarkEntry_Cursor
DEALLOCATE FamilyMarkEntry_Cursor
RETURN
END