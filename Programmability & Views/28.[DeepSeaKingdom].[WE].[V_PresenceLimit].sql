USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_PresenceLimit]
--WITH ENCRYPTION
AS
SELECT DISTINCT al.Id
	,JSON_VALUE(al.FileObject,'$.ContentOutlineId') AS ContentOutlineId
	,JSON_VALUE(al.FileObject,'$.QuarterSessionId') AS QuarterSessionId
	,JSON_VALUE(al.FileObject,'$.WorkshopId') AS WorkshopId
	,JSON_VALUE(al.FileObject,'$.MaximumAbsence') AS MaximumAbsence
	,JSON_VALUE(al.FileObject,'$.ContentOutline') AS ContentOutline
FROM [LocalDB].Items.dbo.[Galaxy.Model.PresenceLimit] al
WHERE ISJSON(al.FileObject)>0
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.PresenceLimit] al2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = al2.Id) AND al2.FileName = al.FileName Batch BY al2.FileName HAVING MAX(al2.SavedDate) = al.SavedDate) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = al.Id)
