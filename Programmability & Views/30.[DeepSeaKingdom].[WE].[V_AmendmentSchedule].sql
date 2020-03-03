USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_VentureSchedule]
--WITH ENCRYPTION
AS
SELECT DISTINCT cs.Id
	,JSON_VALUE(cs.FileObject,'$.QuarterSessionId') AS QuarterSessionId
	,JSON_VALUE(cs.FileObject,'$.CorrectorId') AS CorrectorId
	,JSON_VALUE(cs.FileObject,'$.Corrector') AS Corrector
	,JSON_VALUE(cs.FileObject,'$.ContentOutlineId') AS ContentOutlineId
	,JSON_VALUE(cs.FileObject,'$.ContentName') AS ContentName
	,JSON_VALUE(cs.FileObject,'$.BrandName') AS BrandName
	,JSON_VALUE(cs.FileObject,'$.StartDate') AS StartDate
	,JSON_VALUE(cs.FileObject,'$.EndDate') AS EndDate
	,JSON_VALUE(cs.FileObject,'$.StartDateString') AS StartDateString
	,JSON_VALUE(cs.FileObject,'$.EndDateString') AS EndDateString
	,JSON_VALUE(cs.FileObject,'$.BundleLimit') AS BundleLimit
	,JSON_VALUE(cs.FileObject,'$.FinishDate') AS FinishDate
	,JSON_VALUE(cs.FileObject,'$.Extension') AS Extension
	,JSON_VALUE(cs.FileObject,'$.ExtendedDate') AS ExtendedDate
	,JSON_VALUE(cs.FileObject,'$.ExtensionReason') AS ExtensionReason
	,JSON_VALUE(cs.FileObject,'$.Status') AS Status
	,JSON_VALUE(cs.FileObject,'$.Type') AS Type
	,JSON_VALUE(cs.FileObject,'$.Number') AS Number
	,JSON_VALUE(cs.FileObject,'$.FamilyCount') AS FamilyCount
	,JSON_VALUE(cs.FileObject,'$.Latitude') AS Latitude
FROM OPENQUERY([LocalDB], 'SELECT cs.* FROM Items.dbo.[Galaxy.Model.VentureSchedule] cs WHERE EXISTS (SELECT NULL FROM Items.dbo.[Galaxy.Model.VentureSchedule] cs2 WHERE NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = cs2.Id) AND cs2.FileName = cs.FileName Batch BY cs2.FileName HAVING MAX(cs2.SavedDate) = cs.SavedDate) AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = cs.Id)') cs
WHERE ISJSON(cs.FileObject)>0
