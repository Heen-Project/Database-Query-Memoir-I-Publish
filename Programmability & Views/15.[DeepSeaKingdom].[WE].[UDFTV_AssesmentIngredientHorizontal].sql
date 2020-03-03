USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_AssesmentIngredientHorizontal] (@QuarterSession NVARCHAR(MAX) = N'')  
RETURNS @AssesmentIngredientTable TABLE
(  
	[QuarterSessionId] NVARCHAR(MAX),
	[ContentOutlineId] NVARCHAR(MAX),
	[Responsibility] NVARCHAR(MAX),
	[Venture] NVARCHAR(MAX),
	[MidTerm] NVARCHAR(MAX),
	[FinalTerm] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN
INSERT INTO @AssesmentIngredientTable
SELECT pvt.QuarterSessionId
	,pvt.ContentOutlineId
	,[Responsibility] = ISNULL(pvt.Responsibility,0)
	,[Venture] = ISNULL(pvt.Venture,0)
	,[MidTerm] = ISNULL(pvt.MidTerm,0)
	,[FinalTerm] = ISNULL(pvt.FinalTerm,0)
FROM (
	SELECT DISTINCT LEFT(ec.FileName, CHARINDEX('|', ec.FileName)-1) AS QuarterSessionId
		,JSON_VALUE(ec.FileObject,'$.ContentOutlineId') AS ContentOutlineId
		,JSON_VALUE(ec.FileObject,'$.Type') AS Type
		,JSON_VALUE(ec.FileObject,'$.Percentage') AS Percentage
	FROM [LocalDB].Items.dbo.[Galaxy.Model.AssesmentIngredient] ec
	WHERE ISJSON(ec.FileObject)>0
		AND ec.FileName LIKE '%'+@QuarterSession+'%|%|%'
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.AssesmentIngredient] ec2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = ec2.Id) AND ec2.FileName = ec.FileName Batch BY ec2.FileName HAVING MAX(ec2.SavedDate) = ec.SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = ec.Id)
) sourcetable PIVOT(MAX(sourcetable.Percentage) FOR Type IN ([Responsibility], [Venture], [MidTerm], [FinalTerm] )) AS pvt
RETURN
END