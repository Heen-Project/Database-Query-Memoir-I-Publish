USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_AssesmentIngredientVertical] (@QuarterSession NVARCHAR(MAX) = N'')  
RETURNS @AssesmentIngredientTable TABLE
(  
	[Id] NVARCHAR(MAX),
	[QuarterSessionId] NVARCHAR(MAX),
	[ContentOutlineId] NVARCHAR(MAX),
	[Type] NVARCHAR(MAX),
	[Count] NVARCHAR(MAX),
	[Percentage] NVARCHAR(MAX),
	[Detail] NVARCHAR(MAX),
	[UpdatedBy] NVARCHAR(MAX),
	[UpdatedOn] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN
INSERT INTO @AssesmentIngredientTable
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
RETURN
END