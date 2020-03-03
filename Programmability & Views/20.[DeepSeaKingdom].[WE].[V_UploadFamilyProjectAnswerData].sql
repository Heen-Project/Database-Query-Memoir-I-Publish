USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_UploadFamilyVentureAnswerData]
--WITH ENCRYPTION
AS
SELECT DISTINCT as_uspad.Id
	,JSON_VALUE(as_uspad.FileObject,'$.QuarterSessionId') AS QuarterSessionId
	,JSON_VALUE(as_uspad.FileObject,'$.ContentOutlineId') AS ContentOutlineId
	,JSON_VALUE(as_uspad.FileObject,'$.ContentName') AS ContentName
	,JSON_VALUE(as_uspad.FileObject,'$.BrandName') AS BrandName
	,JSON_VALUE(as_uspad.FileObject,'$.BrandBusinessId') AS BrandBusinessId
	,JSON_VALUE(as_uspad.FileObject,'$.Number') AS Number
	,JSON_VALUE(as_uspad.FileObject,'$.BatchNumber') AS BatchNumber
	,JSON_VALUE(as_uspad.FileObject,'$.People') AS People
	,JSON_VALUE(as_uspad.FileObject,'$.PeopleId') AS PeopleId
	,JSON_VALUE(as_uspad.FileObject,'$.UploadDate') AS UploadDate
	,JSON_VALUE(as_uspad.FileObject,'$.Status') AS Status
	,JSON_VALUE(as_uspad.FileObject,'$.Hash') AS Hash
	,JSON_VALUE(as_uspad.FileObject,'$.FileId') AS FileId
	,JSON_QUERY(as_uspad.FileObject,'$.Files') AS Files
	,JSON_VALUE(as_uspad.FileObject,'$.FinalizedBy') AS FinalizedBy
	,JSON_VALUE(as_uspad.FileObject,'$.FinalizedById') AS FinalizedById
	,JSON_VALUE(as_uspad.FileObject,'$.FinalizedDate') AS FinalizedDate
	,JSON_VALUE(as_uspad.FileObject,'$.ComputerName') AS ComputerName
	,JSON_VALUE(as_uspad.FileObject,'$.Source') AS Source
FROM OPENQUERY([LocalDB], 'SELECT uspad.* FROM Items.dbo.[Galaxy.Model.UploadFamilyVentureAnswerData] uspad WHERE EXISTS (SELECT NULL FROM Items.dbo.[Galaxy.Model.UploadFamilyVentureAnswerData] uspad2 WHERE NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = uspad2.Id) AND uspad2.FileName = uspad.FileName Batch BY uspad2.FileName HAVING MAX(uspad2.SavedDate) = uspad.SavedDate) AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = uspad.Id)') as_uspad
WHERE ISJSON(as_uspad.FileObject)>0