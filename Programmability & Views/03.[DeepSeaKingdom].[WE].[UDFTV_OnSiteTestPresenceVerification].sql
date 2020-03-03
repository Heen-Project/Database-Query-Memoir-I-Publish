USE [DeepSeaKingdom]
GO
CREATE FUNCTION [WE].[UDFTV_OnsiteTestPresenceVerification] (@QuarterSession VARCHAR(MAX))  
RETURNS @OnsiteTestPresenceVerificationTable TABLE
(  
	[Id] NVARCHAR(MAX),
	[SavedDate] NVARCHAR(MAX),
	[QuarterSessionId] NVARCHAR(MAX),
	[OnsiteTestBusinessId] NVARCHAR(MAX),
	[LatitudeId] NVARCHAR(MAX), 
	[Verified] NVARCHAR(MAX), 
	[Topic] NVARCHAR(MAX), 
	[Latitude] NVARCHAR(MAX), 
	[BrandName] NVARCHAR(MAX), 
	[Attend] NVARCHAR(MAX), 
	[TotalFamily] NVARCHAR(MAX), 
	[PresenceNote] NVARCHAR(MAX),
	[VerifiedBy] NVARCHAR(MAX),
	[VerifiedDate] NVARCHAR(MAX),
	[FamilyMemberId] NVARCHAR(MAX),
	[FamilyPictureId] NVARCHAR(MAX),
	[FamilyOnsiteTestBusinessId] NVARCHAR(MAX),
	[FamilyLatitudeId] NVARCHAR(MAX),
	[FamilyMemberNumber] NVARCHAR(MAX),
	[FamilyMemberName] NVARCHAR(MAX),
	[FamilySeatNumber] NVARCHAR(MAX),
	[FamilyPresenceTime] NVARCHAR(MAX),
	[FamilyAttendPlace] NVARCHAR(MAX),
	[FamilyStatus] NVARCHAR(MAX),
	[FamilyPresent] NVARCHAR(MAX),
	[FamilyNote] NVARCHAR(MAX),
	[FamilyCase] NVARCHAR(MAX)
) 
--WITH ENCRYPTION
AS  
BEGIN  
DECLARE @OnsiteTestPresenceVerificationId NVARCHAR(MAX)
DECLARE @OnsiteTestPresenceVerificationSavedDate NVARCHAR(MAX)
DECLARE @QuarterSessionId NVARCHAR(MAX)
DECLARE @OnsiteTestBusinessId NVARCHAR(MAX)
DECLARE @LatitudeId NVARCHAR(MAX)
DECLARE @Verified NVARCHAR(MAX)
DECLARE @Topic NVARCHAR(MAX)
DECLARE @Latitude NVARCHAR(MAX)
DECLARE @BrandName NVARCHAR(MAX)
DECLARE @Attend NVARCHAR(MAX)
DECLARE @TotalFamily NVARCHAR(MAX)
DECLARE @FamilyPresence NVARCHAR(MAX)
DECLARE @PresenceNote NVARCHAR(MAX)
DECLARE @VerifiedBy NVARCHAR(MAX)
DECLARE @VerifiedDate NVARCHAR(MAX)


DECLARE OnsiteTestPresenceVerification_Cursor CURSOR FOR
SELECT DISTINCT eav.Id-- lab.Name,csp.Note, csp.PersonId,
	,eav.SavedDate
	,DeepSeaKingdom.dbo.UDF_Split(eav.FileName,'|',3) AS QuarterSessionId
	,JSON_VALUE(eav.FileObject,'$.OnsiteTestBusinessId') AS OnsiteTestBusinessId
	,JSON_VALUE(eav.FileObject,'$.LatitudeId') AS LatitudeId
	,JSON_VALUE(eav.FileObject,'$.Verified') AS Verified
	,JSON_VALUE(eav.FileObject,'$.Topic') AS Topic
	,JSON_VALUE(eav.FileObject,'$.Latitude') AS Latitude
	,JSON_VALUE(eav.FileObject,'$.BrandName') AS BrandName
	,JSON_VALUE(eav.FileObject,'$.Attend') AS Attend
	,JSON_VALUE(eav.FileObject,'$.TotalFamily') AS TotalFamily
	,JSON_QUERY(eav.FileObject,'$.FamilyPresence') AS FamilyPresence
	,JSON_VALUE(eav.FileObject,'$.PresenceNote') AS PresenceNote
	,JSON_QUERY(eav.FileObject,'$.VerifiedBy') AS VerifiedBy
	,JSON_QUERY(eav.FileObject,'$.VerifiedDate') AS VerifiedDate
FROM [LocalDB].Items.dbo.[Galaxy.Model.OnsiteTestPresenceVerification] eav
WHERE ISJSON(eav.FileObject)>0
	AND eav.FileName LIKE '%|%|'+@QuarterSession+'%'
	AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.OnsiteTestPresenceVerification] eav2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = eav2.Id) AND eav2.FileName = eav.FileName Batch BY eav2.FileName HAVING MAX(eav2.SavedDate) = eav.SavedDate) 
	AND NOT EXISTS (SELECT NULL FROM [LocalDB].Galaxy.dbo.DeletedItems di WHERE di.DataId = eav.Id)
OPEN OnsiteTestPresenceVerification_Cursor
	FETCH NEXT FROM OnsiteTestPresenceVerification_Cursor INTO @OnsiteTestPresenceVerificationId, @OnsiteTestPresenceVerificationSavedDate, @QuarterSessionId, @OnsiteTestBusinessId, @LatitudeId, @Verified, @Topic, @Latitude, @BrandName, @Attend, @TotalFamily, @FamilyPresence, @PresenceNote, @VerifiedBy, @VerifiedDate
	WHILE @@FETCH_STATUS = 0   
	BEGIN 
		--
		INSERT INTO @OnsiteTestPresenceVerificationTable
		SELECT @OnsiteTestPresenceVerificationId, @OnsiteTestPresenceVerificationSavedDate, @QuarterSessionId, @OnsiteTestBusinessId, @LatitudeId, @Verified, @Topic, @Latitude, @BrandName, @Attend, @TotalFamily, @PresenceNote, @VerifiedBy, @VerifiedDate, as_Familys.MemberId, as_Familys.PictureId, as_Familys.OnsiteTestBusinessId, as_Familys.LatitudeId, as_Familys.MemberNumber, as_Familys.MemberName, as_Familys.SeatNumber, as_Familys.PresenceTime, as_Familys.AttendPlace, as_Familys.Status, as_Familys.Present, as_Familys.Note, as_Familys.[Case]
		FROM (SELECT DISTINCT * FROM OPENJSON(@FamilyPresence) WITH (MemberId nvarchar(max),PictureId nvarchar(max),OnsiteTestBusinessId nvarchar(max),LatitudeId nvarchar(max),MemberNumber nvarchar(max),MemberName nvarchar(max),SeatNumber nvarchar(max),PresenceTime nvarchar(max),AttendPlace nvarchar(max),Status nvarchar(max),Present nvarchar(max),Note nvarchar(max),[Case] nvarchar(max))) as_Familys
		--
	FETCH NEXT FROM OnsiteTestPresenceVerification_Cursor INTO @OnsiteTestPresenceVerificationId, @OnsiteTestPresenceVerificationSavedDate, @QuarterSessionId, @OnsiteTestBusinessId, @LatitudeId, @Verified, @Topic, @Latitude, @BrandName, @Attend, @TotalFamily, @FamilyPresence, @PresenceNote, @VerifiedBy, @VerifiedDate
	END  
CLOSE OnsiteTestPresenceVerification_Cursor
DEALLOCATE OnsiteTestPresenceVerification_Cursor
RETURN
END