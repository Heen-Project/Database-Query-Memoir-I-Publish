USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_FamilyMark]
--WITH ENCRYPTION
AS
SELECT DISTINCT as_ss.Id
	,JSON_VALUE(as_ss.FileObject,'$.BrandBusinessId') AS BrandBusinessId
	,JSON_VALUE(as_ss.FileObject,'$.MemberId') AS MemberId
	,LEFT(as_ss.FileName,CHARINDEX('|',as_ss.FileName)-1) AS QuarterSessionId
	,JSON_VALUE(as_ss.FileObject,'$.ContentOutlineId') AS ContentOutlineId
	,JSON_VALUE(as_ss.FileObject,'$.BrandName') AS BrandName
	,JSON_VALUE(as_ss.FileObject,'$.Type') AS Type
	,JSON_VALUE(as_ss.FileObject,'$.Number') AS Number
	,JSON_VALUE(as_ss.FileObject,'$.MarkBeforeOffense') AS MarkBeforeOffense
	,JSON_VALUE(as_ss.FileObject,'$.Mark') AS Mark
	,JSON_VALUE(as_ss.FileObject,'$.EntryBy') AS EntryBy
	,JSON_VALUE(as_ss.FileObject,'$.EntryDate') AS EntryDate
	,JSON_VALUE(as_ss.FileObject,'$.Status') AS Status
	,JSON_VALUE(as_ss.FileObject,'$.UpdateReason') AS UpdateReason
	,JSON_VALUE(as_ss.FileObject,'$.CorrectorId') AS CorrectorId
FROM OPENQUERY([LocalDB], 'SELECT ss.* FROM Items.dbo.[Galaxy.Model.FamilyMark] ss WHERE EXISTS (SELECT NULL FROM Items.dbo.[Galaxy.Model.FamilyMark] ss2 WHERE NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ss2.Id) AND ss2.FileName = ss.FileName Batch BY ss2.FileName HAVING MAX(ss2.SavedDate) = ss.SavedDate) AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ss.Id)') as_ss
WHERE ISJSON(as_ss.FileObject)>0