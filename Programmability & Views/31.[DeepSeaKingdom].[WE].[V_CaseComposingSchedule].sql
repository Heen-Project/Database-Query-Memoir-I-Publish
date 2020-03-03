USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_CaseComposingSchedule]
--WITH ENCRYPTION
AS
SELECT DISTINCT cms.Id
	,JSON_VALUE(cms.FileObject,'$.QuarterSessionId') AS QuarterSessionId
	,JSON_VALUE(cms.FileObject,'$.WorkshopId') AS WorkshopId
	,JSON_VALUE(cms.FileObject,'$.CaseComposerId') AS CaseComposerId
	,JSON_VALUE(cms.FileObject,'$.CaseComposer') AS CaseComposer
	,JSON_VALUE(cms.FileObject,'$.ContentOutlineId') AS ContentOutlineId
	,JSON_VALUE(cms.FileObject,'$.ContentName') AS ContentName
	,JSON_VALUE(cms.FileObject,'$.StartDate') AS StartDate
	,JSON_VALUE(cms.FileObject,'$.EndDate') AS EndDate
	,JSON_VALUE(cms.FileObject,'$.StartDateString') AS StartDateString
	,JSON_VALUE(cms.FileObject,'$.EndDateString') AS EndDateString
	,JSON_VALUE(cms.FileObject,'$.FinishDate') AS FinishDate
	,JSON_VALUE(cms.FileObject,'$.AcceptedDate') AS AcceptedDate
	,JSON_VALUE(cms.FileObject,'$.ExtendedDate') AS ExtendedDate
	,JSON_VALUE(cms.FileObject,'$.ExtensionReason') AS ExtensionReason
	,JSON_VALUE(cms.FileObject,'$.Status') AS Status
	,JSON_VALUE(cms.FileObject,'$.Type') AS Type
	,JSON_VALUE(cms.FileObject,'$.Variation') AS Variation
	,JSON_VALUE(cms.FileObject,'$.ApproveBy') AS ApproveBy
	,JSON_QUERY(cms.FileObject,'$.fileDetail') AS fileDetail
	,JSON_VALUE(cms.FileObject,'$.NoteFromCoordinator') AS NoteFromCoordinator
FROM OPENQUERY([LocalDB], 'SELECT cms.* FROM Items.dbo.[Galaxy.Model.CaseComposingSchedule] cms WHERE EXISTS (SELECT NULL FROM Items.dbo.[Galaxy.Model.CaseComposingSchedule] cms2 WHERE NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = cms2.Id) AND cms2.FileName = cms.FileName Batch BY cms2.FileName HAVING MAX(cms2.SavedDate) = cms.SavedDate) AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = cms.Id)') cms
WHERE ISJSON(cms.FileObject)>0
