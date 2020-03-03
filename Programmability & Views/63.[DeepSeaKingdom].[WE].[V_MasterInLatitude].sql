USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_MasterInLatitude]
--WITH ENCRYPTION
AS
SELECT PivotTable.[Id], PivotTable.[LatitudeId]/*, PivotTable.[Master], PivotTable.[Firmware]*/, JSON_VALUE(PivotTable.Master,'$.MasterId') AS MasterId, JSON_VALUE(PivotTable.Master,'$.Name') AS MasterName
FROM (SELECT [mir].[Id],fo.[key],fo.[value]
	FROM [LocalDB].Items.dbo.[Galaxy.Model.MasterInLatitude] [mir] 
		CROSS APPLY OPENJSON ([mir].FileObject) AS fo
	WHERE ISJSON([mir].FileObject)>0
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.MasterInLatitude] [mir2] WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [mir2].Id) AND [mir2].FileName = [mir].FileName Batch BY [mir2].FileName HAVING MAX([mir2].SavedDate) = [mir].SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = [mir].Id)) AS SourceTable
	PIVOT (MAX(SourceTable.[value]) FOR SourceTable.[key] IN ([LatitudeId],[Master])) AS PivotTable