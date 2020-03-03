USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_CheckMarkComplainSummaryFamily] (@QuarterSession VARCHAR(MAX))  
RETURNS @CheckMarkComplainTable TABLE
(  
	[Id] NVARCHAR(MAX),
	[QuarterSessionId] NVARCHAR(MAX),
	[WorkshopId] NVARCHAR(MAX), 
	[FormNumber] NVARCHAR(MAX), 
	[ComplainNumber] NVARCHAR(MAX), 
	[CheckerId] NVARCHAR(MAX), 
	[CheckerBy] NVARCHAR(MAX), 
	[Description] NVARCHAR(MAX), 
	[SavedBy] NVARCHAR(MAX), 
	[SavedDate] NVARCHAR(MAX),
	[Type] NVARCHAR(MAX),
	[MemberId] NVARCHAR(MAX),
	[OldMark] NVARCHAR(MAX),
	[NewMark] NVARCHAR(MAX),
	[TopicId] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN  
DECLARE @CheckMarkComplainId VARCHAR(MAX)
DECLARE @QuarterSessionId VARCHAR(MAX)
DECLARE @WorkshopId VARCHAR(MAX)
DECLARE @FormNumber VARCHAR(MAX)
DECLARE @ComplainNumber VARCHAR(MAX)
DECLARE @CheckerId VARCHAR(MAX)
DECLARE @CheckerBy VARCHAR(MAX)
DECLARE @Description VARCHAR(MAX)
DECLARE @SavedBy VARCHAR(MAX)
DECLARE @SavedDate VARCHAR(MAX)
--DECLARE @Familys VARCHAR(MAX)
DECLARE @SummaryFamilys VARCHAR(MAX)


DECLARE CheckMarkComplain_Cursor CURSOR FOR
SELECT DISTINCT csp.Id,-- lab.Name,csp.Note, csp.PersonId,
	JSON_VALUE(csp.FileObject,'$.QuarterSessionId') AS QuarterSessionId,
	JSON_VALUE(csp.FileObject,'$.WorkshopId') AS WorkshopId,
	JSON_VALUE(csp.FileObject,'$.FormNumber') AS FormNumber,
	JSON_VALUE(csp.FileObject,'$.ComplainNumber') AS ComplainNumber,
	JSON_VALUE(csp.FileObject,'$.CheckerId') AS CheckerId,
	JSON_VALUE(csp.FileObject,'$.CheckerBy') AS CheckerBy,
	JSON_VALUE(csp.FileObject,'$.Description') AS Description,
	JSON_VALUE(csp.FileObject,'$.SavedBy') AS SavedBy,
	JSON_VALUE(csp.FileObject,'$.SavedDate') AS SavedDate,
	--JSON_QUERY(csp.FileObject,'$.Familys') AS Familys
	JSON_QUERY(csp.FileObject,'$.SummaryFamilys') AS SummaryFamilys
FROM [LocalDB].Items.dbo.[Galaxy.Model.CheckMarkComplain] csp
WHERE ISJSON(csp.FileObject)>0
	AND JSON_VALUE(csp.FileObject,'$.QuarterSessionId') LIKE '%'+@QuarterSession+'%'
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.CheckMarkComplain] csp2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = csp2.Id) AND csp2.FileName = csp.FileName Batch BY csp2.FileName HAVING MAX(csp2.SavedDate) = csp.SavedDate) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = csp.Id)
OPEN CheckMarkComplain_Cursor
	FETCH NEXT FROM CheckMarkComplain_Cursor INTO @CheckMarkComplainId, @QuarterSessionId, @WorkshopId, @FormNumber, @ComplainNumber, @CheckerId, @CheckerBy, @Description, @SavedBy, @SavedDate, /*@Familys,*/ @SummaryFamilys
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		INSERT INTO @CheckMarkComplainTable
		SELECT @CheckMarkComplainId, @QuarterSessionId, @WorkshopId, @FormNumber, @ComplainNumber, @CheckerId, @CheckerBy, @Description, @SavedBy, @SavedDate, as_Familys.Type, as_Familys.MemberId, as_Familys.OldMark, as_Familys.NewMark, as_Familys.TopicId
		FROM (SELECT DISTINCT * FROM OPENJSON(@SummaryFamilys) WITH (Type nvarchar(max),MemberId nvarchar(max),OldMark int, NewMark int, NewStatus nvarchar(max), TopicId nvarchar(max))) as_Familys
		--
	FETCH NEXT FROM CheckMarkComplain_Cursor INTO @CheckMarkComplainId, @QuarterSessionId, @WorkshopId, @FormNumber, @ComplainNumber, @CheckerId, @CheckerBy, @Description, @SavedBy, @SavedDate, /*@Familys,*/ @SummaryFamilys
	END  
CLOSE CheckMarkComplain_Cursor
DEALLOCATE CheckMarkComplain_Cursor
RETURN
END