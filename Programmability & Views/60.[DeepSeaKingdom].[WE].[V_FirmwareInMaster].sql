USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_FirmwareInMaster]
--WITH ENCRYPTION
AS
SELECT PivotTable.[Id]/*, PivotTable.[Master], PivotTable.[Firmware]*/, JSON_VALUE(PivotTable.Master,'$.MasterId') AS MasterId, JSON_VALUE(PivotTable.Master,'$.Name') AS MasterName, JSON_VALUE(PivotTable.Firmware,'$.FirmwareId') AS FirmwareId, JSON_VALUE(PivotTable.Firmware,'$.Name') AS FirmwareName, JSON_VALUE(PivotTable.Firmware,'$.Version') AS FirmwareVersion
FROM (SELECT [sin].[Id],fo.[key],fo.[value]
	FROM [LocalDB].Items.dbo.[Galaxy.Model.FirmwareInMaster] [sin] 
		CROSS APPLY OPENJSON ([sin].FileObject) AS fo
	WHERE ISJSON([sin].FileObject)>0
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.FirmwareInMaster] [sin2] WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [sin2].Id) AND [sin2].FileName = [sin].FileName Batch BY [sin2].FileName HAVING MAX([sin2].SavedDate) = [sin].SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [sin].Id)) AS SourceTable
	PIVOT (MAX(SourceTable.[value]) FOR SourceTable.[key] IN ([Master],[Firmware])) AS PivotTable