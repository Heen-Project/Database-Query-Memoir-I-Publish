USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_FamilyZeroingPracticumHistory] (@QuarterSession VARCHAR(MAX))  
RETURNS @FamilyZeroingPracticumHistoryTable TABLE
(  
	[Id] NVARCHAR(MAX),
	[QuarterSessionId] NVARCHAR(MAX),
	[WorkshopId] NVARCHAR(MAX),
	[SavedDate] NVARCHAR(MAX),
	[SummaryFamilyNumber] NVARCHAR(MAX),
	[SummaryFamilyName] NVARCHAR(MAX),
	[SummaryBrandName] NVARCHAR(MAX),
	[SummaryType] NVARCHAR(MAX),
	[SummaryAbsentCount] NVARCHAR(MAX),
	[SummaryQuarterSession] NVARCHAR(MAX),
	[SummaryTopic] NVARCHAR(MAX),
	[SummaryContentOutline] NVARCHAR(MAX),
	[SummaryWorkshop] NVARCHAR(MAX),
	[SummaryStatus] NVARCHAR(MAX),
	[SummaryNumber] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN  
DECLARE @FamilyZeroingPracticumHistoryId VARCHAR(MAX)
DECLARE @QuarterSessionId VARCHAR(MAX)
DECLARE @WorkshopId VARCHAR(MAX)
DECLARE @SavedDate VARCHAR(MAX)
DECLARE @Summary VARCHAR(MAX)


DECLARE FamilyZeroingPracticumHistory_Cursor CURSOR FOR
SELECT DISTINCT szph.Id,
	JSON_VALUE(szph.FileObject,'$.QuarterSessionId') AS QuarterSessionId,
	JSON_VALUE(szph.FileObject,'$.WorkshopId') AS WorkshopId,
	JSON_VALUE(szph.FileObject,'$.SavedDate') AS SavedDate,
	JSON_QUERY(szph.FileObject,'$.Summary') AS Summary
FROM [LocalDB].Items.dbo.[Galaxy.Model.FamilyZeroingPracticumHistory] szph
WHERE ISJSON(szph.FileObject)>0
	AND szph.FileName LIKE '%'+@QuarterSession+'%|%'
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.FamilyZeroingPracticumHistory] szph2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = szph2.Id) AND szph2.FileName = szph.FileName Batch BY szph2.FileName HAVING MAX(szph2.SavedDate) = szph.SavedDate) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = szph.Id)
OPEN FamilyZeroingPracticumHistory_Cursor
	FETCH NEXT FROM FamilyZeroingPracticumHistory_Cursor INTO @FamilyZeroingPracticumHistoryId, @QuarterSessionId, @WorkshopId, @SavedDate, @Summary
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		INSERT INTO @FamilyZeroingPracticumHistoryTable
		SELECT @FamilyZeroingPracticumHistoryId, @QuarterSessionId, @WorkshopId, @SavedDate, as_Familys.FamilyNumber, as_Familys.FamilyName, as_Familys.BrandName, as_Familys.Type, as_Familys.AbsentCount, as_Familys.QuarterSession, as_Familys.Topic, as_Familys.ContentOutline, as_Familys.Workshop, as_Familys.Status, as_Familys.Number
		FROM (SELECT DISTINCT * FROM OPENJSON(@Summary) WITH (FamilyNumber nvarchar(max), FamilyName nvarchar(max), BrandName nvarchar(max), Type nvarchar(max), AbsentCount nvarchar(max), QuarterSession nvarchar(max), Topic nvarchar(max), ContentOutline nvarchar(max), Workshop nvarchar(max), Status nvarchar(max), Number nvarchar(max))) as_Familys
		--
	FETCH NEXT FROM FamilyZeroingPracticumHistory_Cursor INTO @FamilyZeroingPracticumHistoryId, @QuarterSessionId, @WorkshopId, @SavedDate, @Summary
	END  
CLOSE FamilyZeroingPracticumHistory_Cursor
DEALLOCATE FamilyZeroingPracticumHistory_Cursor
RETURN
END