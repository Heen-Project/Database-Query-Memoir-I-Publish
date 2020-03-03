USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_UploadFamilyResponsibilityAnswerData]
--WITH ENCRYPTION
AS
SELECT DISTINCT as_usaad.Id
	,JSON_VALUE(as_usaad.FileObject,'$.QuarterSessionId') AS QuarterSessionId
	,JSON_VALUE(as_usaad.FileObject,'$.ContentOutlineId') AS ContentOutlineId
	,JSON_VALUE(as_usaad.FileObject,'$.ContentName') AS ContentName
	,JSON_VALUE(as_usaad.FileObject,'$.ResponsibilityNumber') AS ResponsibilityNumber
	,JSON_VALUE(as_usaad.FileObject,'$.Variation') AS Variation
	,JSON_VALUE(as_usaad.FileObject,'$.BrandName') AS BrandName
	,JSON_VALUE(as_usaad.FileObject,'$.MemberId') AS MemberId
	,JSON_VALUE(as_usaad.FileObject,'$.MemberNumber') AS MemberNumber
	,JSON_VALUE(as_usaad.FileObject,'$.People') AS People
	,JSON_VALUE(as_usaad.FileObject,'$.PeopleId') AS PeopleId
	,JSON_VALUE(as_usaad.FileObject,'$.UploadDate') AS UploadDate
	,JSON_VALUE(as_usaad.FileObject,'$.Status') AS Status
	,JSON_VALUE(as_usaad.FileObject,'$.Hash') AS Hash
	,JSON_VALUE(as_usaad.FileObject,'$.FileId') AS FileId
	,JSON_QUERY(as_usaad.FileObject,'$.Files') AS Files
	,JSON_VALUE(as_usaad.FileObject,'$.FinalizedBy') AS FinalizedBy
	,JSON_VALUE(as_usaad.FileObject,'$.FinalizedById') AS FinalizedById
	,JSON_VALUE(as_usaad.FileObject,'$.FinalizedDate') AS FinalizedDate
	,JSON_VALUE(as_usaad.FileObject,'$.ComputerName') AS ComputerName
	,JSON_VALUE(as_usaad.FileObject,'$.Source') AS Source
FROM OPENQUERY([LocalDB], 'SELECT usaad.* FROM Items.dbo.[Galaxy.Model.UploadFamilyResponsibilityAnswerData] usaad WHERE EXISTS (SELECT NULL FROM Items.dbo.[Galaxy.Model.UploadFamilyResponsibilityAnswerData] usaad2 WHERE NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = usaad2.Id) AND usaad2.FileName = usaad.FileName Batch BY usaad2.FileName HAVING MAX(usaad2.SavedDate) = usaad.SavedDate) AND NOT EXISTS (SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = usaad.Id)') as_usaad
WHERE ISJSON(as_usaad.FileObject)>0