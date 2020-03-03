USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_HonorException]
--WITH ENCRYPTION
AS
SELECT PivotTable.id, PivotTable.QuarterSessionId, [ContentOutlineId] = ucoil.[value], [Ingredient] = NULL, [Number] = NULL
FROM( SELECT pe.id
		,fo.[key]
		,fo.[value]
	FROM [LocalDB].Items.dbo.[Galaxy.Model.HonorException] pe 
		CROSS APPLY OPENJSON (pe.FileObject) AS fo
	WHERE ISJSON(pe.FileObject)>0
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.HonorException] pe2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = pe2.Id) AND pe2.FileName = pe.FileName Batch BY pe2.FileName HAVING MAX(pe2.SavedDate) = pe.SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = pe.Id)
	) AS SourceTable
PIVOT (MAX(SourceTable.[value]) FOR SourceTable.[key] IN ([QuarterSessionId],[UncheckedContentOutlineIdList])) AS PivotTable
		CROSS APPLY OPENJSON (PivotTable.UncheckedContentOutlineIdList) AS ucoil
UNION
SELECT PivotTable.id, PivotTable.QuarterSessionId, [ContentOutlineId] = JSON_VALUE(ucoil.value,'$.ContentOutlineId'), [Ingredient] = JSON_VALUE(ucoil.value,'$.Ingredient'), [Number] = JSON_VALUE(ucoil.value,'$.Number')
FROM( SELECT pe.id
		,fo.[key]
		,fo.[value]
	FROM [LocalDB].Items.dbo.[Galaxy.Model.HonorException] pe 
		CROSS APPLY OPENJSON (pe.FileObject) AS fo
	WHERE ISJSON(pe.FileObject)>0
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.HonorException] pe2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = pe2.Id) AND pe2.FileName = pe.FileName Batch BY pe2.FileName HAVING MAX(pe2.SavedDate) = pe.SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = pe.Id)
	) AS SourceTable
PIVOT (MAX(SourceTable.[value]) FOR SourceTable.[key] IN ([QuarterSessionId],[UncheckedContentOutlineDetails])) AS PivotTable
		CROSS APPLY OPENJSON (PivotTable.UncheckedContentOutlineDetails) AS ucoil