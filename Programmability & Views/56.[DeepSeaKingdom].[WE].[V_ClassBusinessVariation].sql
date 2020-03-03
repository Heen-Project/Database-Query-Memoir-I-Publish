USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_BrandBusinessVariation]
--WITH ENCRYPTION
AS
SELECT PivotTable.id, PivotTable.QuarterSessionId, [ContentOutlineId] = PivotTable.[ContentOutlineId], [BrandName] = PivotTable.[BrandName], [Type] = PivotTable.[Type], [Variation] = PivotTable.[Variation]
FROM( SELECT ctv.id
		,[QuarterSessionId] = (SELECT split.value FROM STRING_SPLIT(ctv.[FileName], '|') split WHERE EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.QuarterSessions WHERE CONVERT(varchar(255),QuarterSessions.QuarterSessionId) = split.value))
		,fo.[key]
		,fo.[value]
	FROM [LocalDB].Items.dbo.[Galaxy.Model.BrandBusinessVariation] ctv 
		CROSS APPLY OPENJSON (ctv.FileObject) AS fo
	WHERE ISJSON(ctv.FileObject)>0
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.BrandBusinessVariation] ctv2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = ctv2.Id) AND ctv2.FileName = ctv.FileName Batch BY ctv2.FileName HAVING MAX(ctv2.SavedDate) = ctv.SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = ctv.Id)
	) AS SourceTable
PIVOT (MAX(SourceTable.[value]) FOR SourceTable.[key] IN ([ContentOutlineId],[BrandName],[Type],[Variation])) AS PivotTable