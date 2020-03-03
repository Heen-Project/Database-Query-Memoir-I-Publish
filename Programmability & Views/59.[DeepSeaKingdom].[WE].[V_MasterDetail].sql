USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_MasterDetail]
--WITH ENCRYPTION
AS
SELECT PivotTable.[Id]/*, PivotTable.[Master]*/,JSON_VALUE(PivotTable.Master,'$.MasterId') AS MasterId, JSON_VALUE(PivotTable.Master,'$.Name') AS MasterName, PivotTable.[PIC], PivotTable.[Description], PivotTable.[InsertDate]
FROM (SELECT md.[Id],fo.[key],fo.[value]
	FROM [LocalDB].Items.dbo.[Galaxy.Model.MasterDetail] md 
		CROSS APPLY OPENJSON (md.FileObject) AS fo
	WHERE ISJSON(md.FileObject)>0
		--AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.MasterDetail] md2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = md2.Id) Batch BY md2.FileName HAVING MAX(md2.SavedDate) = md.SavedDate) 
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.MasterDetail] md2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = md2.Id) AND LEFT(md2.FileName,CHARINDEX('|',md2.FileName)-1) = LEFT(md.FileName,CHARINDEX('|',md.FileName)-1) Batch BY LEFT(md2.FileName,CHARINDEX('|',md2.FileName)-1) HAVING MAX(md2.SavedDate) = md.SavedDate) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = md.Id)) AS SourceTable
	PIVOT (MAX(SourceTable.[value]) FOR SourceTable.[key] IN ([Master],[PIC],[Description],[InsertDate])) AS PivotTable