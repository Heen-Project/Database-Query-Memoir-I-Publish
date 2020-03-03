USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_UploadFamilyOnsiteTestAnswerData]
--WITH ENCRYPTION
AS
SELECT DISTINCT as_usead.Id
	,JSON_VALUE(as_usead.FileObject,'$.QuarterSessionId') AS QuarterSessionId
	,JSON_VALUE(as_usead.FileObject,'$.ContentOutlineId') AS ContentOutlineId
	,JSON_VALUE(as_usead.FileObject,'$.ContentName') AS ContentName
	,JSON_VALUE(as_usead.FileObject,'$.OnsiteTestBusinessId') AS OnsiteTestBusinessId
	,JSON_VALUE(as_usead.FileObject,'$.LatitudeName') AS LatitudeName
	,JSON_VALUE(as_usead.FileObject,'$.MemberId') AS MemberId
	,JSON_VALUE(as_usead.FileObject,'$.MemberNumber') AS MemberNumber
	,JSON_VALUE(as_usead.FileObject,'$.People') AS People
	,JSON_VALUE(as_usead.FileObject,'$.PeopleId') AS PeopleId
	,JSON_VALUE(as_usead.FileObject,'$.UploadDate') AS UploadDate
	,JSON_VALUE(as_usead.FileObject,'$.Status') AS Status
	,JSON_VALUE(as_usead.FileObject,'$.Hash') AS Hash
	,JSON_VALUE(as_usead.FileObject,'$.FileId') AS FileId
	,JSON_QUERY(as_usead.FileObject,'$.Files') AS Files
	,JSON_VALUE(as_usead.FileObject,'$.FinalizedBy') AS FinalizedBy
	,JSON_VALUE(as_usead.FileObject,'$.FinalizedById') AS FinalizedById
	,JSON_VALUE(as_usead.FileObject,'$.FinalizedDate') AS FinalizedDate
	,JSON_VALUE(as_usead.FileObject,'$.ComputerName') AS ComputerName
	,JSON_VALUE(as_usead.FileObject,'$.Source') AS Source
FROM OPENQUERY([LocalDB], 'SELECT usead.* FROM Items.dbo.[Galaxy.Model.UploadFamilyOnsiteTestAnswerData] usead WHERE EXISTS (SELECT NULL FROM Items.dbo.[Galaxy.Model.UploadFamilyOnsiteTestAnswerData] usead2 WHERE NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = usead2.Id) AND usead2.FileName = usead.FileName Batch BY usead2.FileName HAVING MAX(usead2.SavedDate) = usead.SavedDate) AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = usead.Id)') as_usead
WHERE ISJSON(as_usead.FileObject)>0