USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_AssesmentIngredientVerticalDetail] (
	@QuarterSession NVARCHAR(MAX) = N''
)  
RETURNS @AssesmentIngredientTable TABLE
(  
	[Id] NVARCHAR(MAX),
	[QuarterSessionId] NVARCHAR(MAX),
	[ContentOutlineId] NVARCHAR(MAX),
	[Type] NVARCHAR(MAX),
	[Count] NVARCHAR(MAX),
	[Percentage] NVARCHAR(MAX),
	[UpdatedBy] NVARCHAR(MAX),
	[UpdatedOn] NVARCHAR(MAX),
	[DetailNumber] NVARCHAR(MAX),
	[DetailPercentage] NVARCHAR(MAX),
	[DetailEntryByIntern] NVARCHAR(MAX),
	[DetailPercentage10000] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN  
DECLARE @AssesmentIngredientId NVARCHAR(MAX)
DECLARE @QuarterSessionId NVARCHAR(MAX)
DECLARE @ContentOutlineId NVARCHAR(MAX)
DECLARE @Type NVARCHAR(MAX)
DECLARE @Count NVARCHAR(MAX)
DECLARE @Percentage NVARCHAR(MAX)
DECLARE @Detail NVARCHAR(MAX)
DECLARE @UpdatedBy NVARCHAR(MAX)
DECLARE @UpdatedOn NVARCHAR(MAX)
DECLARE @TemporaryAssesmentIngredientTable TABLE ([Id] NVARCHAR(MAX), [QuarterSessionId] NVARCHAR(MAX), [ContentOutlineId] NVARCHAR(MAX), [Type] NVARCHAR(MAX), [Count] NVARCHAR(MAX), [Percentage] NVARCHAR(MAX), [UpdatedBy] NVARCHAR(MAX), [UpdatedOn] NVARCHAR(MAX), [DetailNumber] NVARCHAR(MAX), [DetailPercentage] NVARCHAR(MAX), [DetailEntryByIntern] NVARCHAR(MAX))

DECLARE AssesmentIngredient_Cursor CURSOR FOR
SELECT DISTINCT ec.Id
	,LEFT(ec.FileName, CHARINDEX('|', ec.FileName)-1) AS QuarterSessionId
	,JSON_VALUE(ec.FileObject,'$.ContentOutlineId') AS ContentOutlineId
	,JSON_VALUE(ec.FileObject,'$.Type') AS Type
	,JSON_VALUE(ec.FileObject,'$.Count') AS Count
	,JSON_VALUE(ec.FileObject,'$.Percentage') AS Percentage
	,JSON_QUERY(ec.FileObject,'$.Detail') AS Detail
	,JSON_VALUE(ec.FileObject,'$.UpdatedBy') AS UpdatedBy
	,JSON_VALUE(ec.FileObject,'$.UpdatedOn') AS UpdatedOn
FROM [LocalDB].Items.dbo.[Galaxy.Model.AssesmentIngredient] ec
WHERE ISJSON(ec.FileObject)>0
	AND ec.FileName LIKE '%'+@QuarterSession+'%|%|%'
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.AssesmentIngredient] ec2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = ec2.Id) AND ec2.FileName = ec.FileName Batch BY ec2.FileName HAVING MAX(ec2.SavedDate) = ec.SavedDate) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = ec.Id)
OPEN AssesmentIngredient_Cursor
	FETCH NEXT FROM AssesmentIngredient_Cursor INTO @AssesmentIngredientId, @QuarterSessionId, @ContentOutlineId, @Type, @Count, @Percentage, @Detail, @UpdatedBy, @UpdatedOn
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		INSERT INTO @TemporaryAssesmentIngredientTable
		SELECT @AssesmentIngredientId, @QuarterSessionId, @ContentOutlineId, @Type, @Count, @Percentage, @UpdatedBy, @UpdatedOn, as_detail.Number, as_detail.Percentage, as_detail.EntryByIntern
		FROM (SELECT DISTINCT * FROM OPENJSON(@Detail) WITH (Number nvarchar(max), Percentage nvarchar(max), EntryByIntern nvarchar(max))) as_detail
		--
	FETCH NEXT FROM AssesmentIngredient_Cursor INTO @AssesmentIngredientId, @QuarterSessionId, @ContentOutlineId, @Type, @Count, @Percentage, @Detail, @UpdatedBy, @UpdatedOn
	END  
CLOSE AssesmentIngredient_Cursor
DEALLOCATE AssesmentIngredient_Cursor
INSERT INTO @AssesmentIngredientTable 
SELECT DISTINCT tect.[Id], tect.[QuarterSessionId], tect.[ContentOutlineId], tect.[Type], tect.[Count], tect.[Percentage], tect.[UpdatedBy], tect.[UpdatedOn], tect.[DetailNumber], (CASE WHEN (SUM(CONVERT(NUMERIC(10,2),tect.[DetailPercentage])) OVER (PARTITION BY tect.[Id], tect.[QuarterSessionId], tect.[ContentOutlineId], tect.[Type])) = 10000 THEN CONVERT(NUMERIC(10,2),CONVERT(NUMERIC(10,2),tect.[DetailPercentage])/100) ELSE tect.[DetailPercentage] END), tect.[DetailEntryByIntern], (CASE WHEN (SUM(CONVERT(NUMERIC(10,2),tect.[DetailPercentage])) OVER (PARTITION BY tect.[Id], tect.[QuarterSessionId], tect.[ContentOutlineId], tect.[Type])) = 10000 THEN 'Y' ELSE 'N' END)
FROM @TemporaryAssesmentIngredientTable tect
RETURN
END