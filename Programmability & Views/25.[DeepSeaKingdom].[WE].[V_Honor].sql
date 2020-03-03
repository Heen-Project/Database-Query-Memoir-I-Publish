USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_Honor]
--WITH ENCRYPTION
AS
SELECT DISTINCT p.Id
	,JSON_VALUE(p.FileObject,'$.QuarterSessionId') AS QuarterSessionId
	,JSON_VALUE(p.FileObject,'$.WorkshopId') AS WorkshopId
	,JSON_VALUE(p.FileObject,'$.VentureHonor') AS VentureHonor
	,JSON_VALUE(p.FileObject,'$.CaseComposingHonor') AS CaseComposingHonor
	,JSON_VALUE(p.FileObject,'$.TeachingHonor') AS TeachingHonor
	,JSON_VALUE(p.FileObject,'$.ResponsibilityWeight') AS ResponsibilityWeight
	,JSON_VALUE(p.FileObject,'$.VentureWeight') AS VentureWeight
	,JSON_VALUE(p.FileObject,'$.MidTermWeight') AS MidTermWeight
	,JSON_VALUE(p.FileObject,'$.FinalTermWeight') AS FinalTermWeight
FROM [LocalDB].Items.dbo.[Galaxy.Model.Honor] p
WHERE ISJSON(p.FileObject)>0
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.Honor] p2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = p2.Id) AND p2.FileName = p.FileName Batch BY p2.FileName HAVING MAX(p2.SavedDate) = p.SavedDate) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = p.Id)