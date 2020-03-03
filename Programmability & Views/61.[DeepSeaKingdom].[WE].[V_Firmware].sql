USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_Firmware]
--WITH ENCRYPTION
AS
SELECT PivotTable.[Id], PivotTable.[FirmwareId], PivotTable.[Name], PivotTable.[Version]
FROM (SELECT [s].[Id],fo.[key],fo.[value]
	FROM [LocalDB].Items.dbo.[Galaxy.Model.Firmware] [s] 
		CROSS APPLY OPENJSON ([s].FileObject) AS fo
	WHERE ISJSON([s].FileObject)>0
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.Firmware] [s2] WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [s2].Id) AND [s2].FileName = [s].FileName Batch BY [s2].FileName HAVING MAX([s2].SavedDate) = [s].SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [s].Id)) AS SourceTable
	PIVOT (MAX(SourceTable.[value]) FOR SourceTable.[key] IN ([FirmwareId],[Name],[Version])) AS PivotTable