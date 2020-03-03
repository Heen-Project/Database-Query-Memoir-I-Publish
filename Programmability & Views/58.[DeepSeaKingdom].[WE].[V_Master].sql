USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_Master]
--WITH ENCRYPTION
AS
SELECT PivotTable.[Id], PivotTable.[MasterId], PivotTable.[Name]
FROM (SELECT m.[Id],fo.[key],fo.[value]
	FROM [LocalDB].Items.dbo.[Galaxy.Model.Master] m 
		CROSS APPLY OPENJSON (m.FileObject) AS fo
	WHERE ISJSON(m.FileObject)>0
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.Master] m2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = m2.Id) AND m2.FileName = m.FileName Batch BY m2.FileName HAVING MAX(m2.SavedDate) = m.SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = m.Id)) AS SourceTable
	PIVOT (MAX(SourceTable.[value]) FOR SourceTable.[key] IN ([MasterId],[Name])) AS PivotTable