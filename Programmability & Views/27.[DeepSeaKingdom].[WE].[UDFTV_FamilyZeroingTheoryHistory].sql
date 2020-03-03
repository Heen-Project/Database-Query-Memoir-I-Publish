USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_FamilyZeroingTheoryHistory] (@QuarterSession VARCHAR(MAX))  
RETURNS @FamilyZeroingTheoryHistoryTable TABLE
(  
	[Id] NVARCHAR(MAX),
	[QuarterSessionId] NVARCHAR(MAX),
	[WorkshopId] NVARCHAR(MAX),
	[SavedDate] NVARCHAR(MAX),
	[SummaryFamilyNumber] NVARCHAR(MAX),
	[SummaryFamilyName] NVARCHAR(MAX),
	[SummaryTopic] NVARCHAR(MAX),
	[SummaryBrandName] NVARCHAR(MAX),
	[SummaryType] NVARCHAR(MAX),
	[SummaryReason] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN  
DECLARE @FamilyZeroingTheoryHistoryId VARCHAR(MAX)
DECLARE @QuarterSessionId VARCHAR(MAX)
DECLARE @WorkshopId VARCHAR(MAX)
DECLARE @SavedDate VARCHAR(MAX)
DECLARE @Summary VARCHAR(MAX)


DECLARE FamilyZeroingTheoryHistory_Cursor CURSOR FOR
SELECT DISTINCT szth.Id,
	JSON_VALUE(szth.FileObject,'$.QuarterSessionId') AS QuarterSessionId,
	JSON_VALUE(szth.FileObject,'$.WorkshopId') AS WorkshopId,
	JSON_VALUE(szth.FileObject,'$.SavedDate') AS SavedDate,
	JSON_QUERY(szth.FileObject,'$.Summary') AS Summary
FROM [LocalDB].Items.dbo.[Galaxy.Model.FamilyZeroingTheoryHistory] szth
WHERE ISJSON(szth.FileObject)>0
	AND szth.FileName LIKE '%'+@QuarterSession+'%|%'
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.FamilyZeroingTheoryHistory] szth2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = szth2.Id) AND szth2.FileName = szth.FileName Batch BY szth2.FileName HAVING MAX(szth2.SavedDate) = szth.SavedDate) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = szth.Id)
OPEN FamilyZeroingTheoryHistory_Cursor
	FETCH NEXT FROM FamilyZeroingTheoryHistory_Cursor INTO @FamilyZeroingTheoryHistoryId, @QuarterSessionId, @WorkshopId, @SavedDate, @Summary
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		INSERT INTO @FamilyZeroingTheoryHistoryTable
		SELECT @FamilyZeroingTheoryHistoryId, @QuarterSessionId, @WorkshopId, @SavedDate, as_Familys.FamilyNumber, as_Familys.FamilyName, as_Familys.Topic, as_Familys.BrandName, as_Familys.Type, as_Familys.Reason
		FROM (SELECT DISTINCT * FROM OPENJSON(@Summary) WITH (FamilyNumber nvarchar(max), FamilyName nvarchar(max), Topic nvarchar(max), BrandName nvarchar(max), Type nvarchar(max), Reason nvarchar(max))) as_Familys
		--
	FETCH NEXT FROM FamilyZeroingTheoryHistory_Cursor INTO @FamilyZeroingTheoryHistoryId, @QuarterSessionId, @WorkshopId, @SavedDate, @Summary
	END  
CLOSE FamilyZeroingTheoryHistory_Cursor
DEALLOCATE FamilyZeroingTheoryHistory_Cursor
RETURN
END