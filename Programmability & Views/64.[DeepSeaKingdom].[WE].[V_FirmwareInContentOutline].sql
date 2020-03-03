USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_FirmwareInContentOutline]
--WITH ENCRYPTION
AS
SELECT PivotTable.[Id]/*, PivotTable.[Firmware],*/, JSON_VALUE(PivotTable.Firmware,'$.FirmwareId') AS FirmwareId, JSON_VALUE(PivotTable.Firmware,'$.Name') AS FirmwareName, JSON_VALUE(PivotTable.Firmware,'$.Version') AS FirmwareVersion, PivotTable.[ContentOutlineId]
FROM (SELECT [sico].[Id],fo.[key],fo.[value]
	FROM [LocalDB].Items.dbo.[Galaxy.Model.FirmwareInContentOutline] [sico] 
		CROSS APPLY OPENJSON ([sico].FileObject) AS fo
	WHERE ISJSON([sico].FileObject)>0
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.FirmwareInContentOutline] [sico2] WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [sico2].Id) AND [sico2].FileName = [sico].FileName Batch BY [sico2].FileName HAVING MAX([sico2].SavedDate) = [sico].SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [sico].Id)) AS SourceTable
	PIVOT (MAX(SourceTable.[value]) FOR SourceTable.[key] IN ([Firmware],[ContentOutlineId])) AS PivotTable