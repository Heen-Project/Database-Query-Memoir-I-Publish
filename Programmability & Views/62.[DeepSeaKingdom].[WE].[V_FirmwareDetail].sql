USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_FirmwareDetail]
--WITH ENCRYPTION
AS
SELECT PivotTable.[Id]/*, PivotTable.[Firmware],*/, JSON_VALUE(PivotTable.Firmware,'$.FirmwareId') AS FirmwareId, JSON_VALUE(PivotTable.Firmware,'$.Name') AS FirmwareName, JSON_VALUE(PivotTable.Firmware,'$.Version') AS FirmwareVersion, PivotTable.[Batch], PivotTable.[License], PivotTable.[CurrentLicense], PivotTable.[NumberOfLicense], PivotTable.[Link], PivotTable.[Note], PivotTable.[InstallerPath]
FROM (SELECT [sd].[Id],fo.[key],fo.[value]
	FROM [LocalDB].Items.dbo.[Galaxy.Model.FirmwareDetail] [sd] 
		CROSS APPLY OPENJSON ([sd].FileObject) AS fo
	WHERE ISJSON([sd].FileObject)>0
		--AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.FirmwareDetail] [sd2] WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [sd2].Id) Batch BY [sd2].FileName HAVING MAX([sd2].SavedDate) = [sd].SavedDate) 
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.FirmwareDetail] [sd2] WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [sd2].Id) AND (CASE WHEN CHARINDEX('|',[sd2].FileName) > 0 THEN LEFT([sd2].FileName,CHARINDEX('|',[sd2].FileName)-1) ELSE [sd2].FileName END) = (CASE WHEN CHARINDEX('|',[sd].FileName) > 0 THEN LEFT([sd].FileName,CHARINDEX('|',[sd].FileName)-1) ELSE [sd].FileName END) Batch BY (CASE WHEN CHARINDEX('|',[sd2].FileName) > 0 THEN LEFT([sd2].FileName,CHARINDEX('|',[sd2].FileName)-1) ELSE [sd2].FileName END) HAVING MAX([sd2].SavedDate) = [sd].SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [sd].Id)) AS SourceTable
	PIVOT (MAX(SourceTable.[value]) FOR SourceTable.[key] IN ([Firmware],[Batch],[License],[CurrentLicense],[NumberOfLicense],[Link],[Note],[InstallerPath])) AS PivotTable