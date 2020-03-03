USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateOnsiteTestScheduleBeforePublish](
	@Term NVARCHAR(MAX) = N''
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
;----------------------------------------------------------------------
DECLARE @Query NVARCHAR(MAX), @QueryInner NVARCHAR(MAX), @QueryHeader NVARCHAR(MAX), @QueryInnerParent NVARCHAR(MAX), @QueryInnerDummy NVARCHAR(MAX), @QueryParent NVARCHAR(MAX), @QueryDummy NVARCHAR(MAX), @Department NVARCHAR(MAX) = 'YYS01', @AcadCareer NVARCHAR(MAX) = 'RS1'
;----------------------------------------------------------------------
SET @QueryHeader = 'SELECT DISTINCT esd.OnsiteTestScheduleDateID, esd.OnsiteTestCalendarSetupDetailID, esd.Department, esd.Position, esd.TERM, [OnsiteTestHouse] = esd.House, esd.ShiftID, esd.Content_ID, esd.Brand_SECTION, esd.SCTN_COMBINED_ID, esd.ShiftStart, esd.OnsiteTestDuration, esd.OnsiteTestDate, esd.MLTP, esd.Content_OFFER_NBR, esd.OnsiteTestType, esd.Brand_Status, esd.DESCRSHORT, esd.Orderline, esd.TYPE, esr.OnsiteTestScheduleLatitudeID, esr.FacilityID, esr.Latitude, esr.LatitudeAllocation, esr.LOCATION, esr.House, esr.DetailLatitudeTemplateConfigurationID'
;------------------------------
SET @QueryInner = '
FROM [ExternalDB].[OnsiteTest_DB].[dbo].[OnsiteTestScheduleDate] esd
	JOIN [ExternalDB].[OnsiteTest_DB].[dbo].[OnsiteTestScheduleLatitude] esr ON esd.OnsiteTestScheduleDateID = esr.OnsiteTestScheduleDateID
		AND esr.Term <> ''D''
		AND esd.Term <> ''D''
		AND esd.Department = '''+@Department+'''
		AND esd.Position = '''+@AcadCareer+''''
;------------------------------
SET @QueryInnerParent = @QueryHeader + @QueryInner+'
		AND (esd.SCTN_COMBINED_ID IS NULL OR (esd.SCTN_COMBINED_ID IS NOT NULL AND esd.Brand_Status = ''Parent''))
WHERE esd.TERM = '''+@Term+''''
;------------------------------
SET @QueryInnerDummy = @QueryHeader + @QueryInner+'
		AND (esd.SCTN_COMBINED_ID IS NOT NULL AND esd.Brand_Status = ''Dummy'')
WHERE esd.TERM = '''+@Term+''''
;------------------------------
SET @QueryDummy = 'SELECT DISTINCT [Content_ID_Parent] = OnsiteTest_parent.Content_ID, OnsiteTest_dummy.OnsiteTestScheduleDateID, OnsiteTest_dummy.OnsiteTestCalendarSetupDetailID, OnsiteTest_dummy.Department, OnsiteTest_dummy.Position, OnsiteTest_dummy.TERM, [OnsiteTestHouse] = OnsiteTest_dummy.House, OnsiteTest_dummy.ShiftID, OnsiteTest_dummy.Content_ID, OnsiteTest_dummy.Brand_SECTION, OnsiteTest_dummy.SCTN_COMBINED_ID, OnsiteTest_dummy.ShiftStart, OnsiteTest_dummy.OnsiteTestDuration, OnsiteTest_dummy.OnsiteTestDate, OnsiteTest_dummy.MLTP, OnsiteTest_dummy.Content_OFFER_NBR, OnsiteTest_dummy.OnsiteTestType, OnsiteTest_dummy.Brand_Status, OnsiteTest_dummy.DESCRSHORT, OnsiteTest_dummy.Orderline, OnsiteTest_dummy.TYPE, OnsiteTest_dummy.OnsiteTestScheduleLatitudeID, OnsiteTest_dummy.FacilityID, OnsiteTest_dummy.Latitude, OnsiteTest_dummy.LatitudeAllocation, OnsiteTest_dummy.LOCATION, OnsiteTest_dummy.House, OnsiteTest_dummy.DetailLatitudeTemplateConfigurationID
FROM ('+@QueryInnerParent+') OnsiteTest_parent
	 JOIN ('+@QueryInnerDummy+') OnsiteTest_dummy ON OnsiteTest_dummy.SCTN_COMBINED_ID = OnsiteTest_parent.SCTN_COMBINED_ID
		AND OnsiteTest_dummy.OnsiteTestType = OnsiteTest_parent.OnsiteTestType
		AND OnsiteTest_dummy.Orderline = OnsiteTest_parent.Orderline
		AND OnsiteTest_dummy.Department = OnsiteTest_parent.Department
		AND OnsiteTest_dummy.Position = OnsiteTest_parent.Position
		AND OnsiteTest_dummy.TERM = OnsiteTest_parent.TERM
		/*AND OnsiteTest_dummy.Latitude = OnsiteTest_parent.Latitude*/'
;------------------------------
SET @QueryParent = 'SELECT DISTINCT [Content_ID_Parent] = esd.Content_ID, esd.OnsiteTestScheduleDateID, esd.OnsiteTestCalendarSetupDetailID, esd.Department, esd.Position, esd.TERM, [OnsiteTestHouse] = esd.House, esd.ShiftID, esd.Content_ID, esd.Brand_SECTION, esd.SCTN_COMBINED_ID, esd.ShiftStart, esd.OnsiteTestDuration, esd.OnsiteTestDate, esd.MLTP, esd.Content_OFFER_NBR, esd.OnsiteTestType, esd.Brand_Status, esd.DESCRSHORT, esd.Orderline, esd.TYPE, esr.OnsiteTestScheduleLatitudeID, esr.FacilityID, esr.Latitude, esr.LatitudeAllocation, esr.LOCATION, esr.House, esr.DetailLatitudeTemplateConfigurationID'+ @QueryInner+'
		AND (esd.SCTN_COMBINED_ID IS NULL OR (esd.SCTN_COMBINED_ID IS NOT NULL AND esd.Brand_Status = ''Parent''))
WHERE esd.TERM = '''+@Term+''''
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.OnsiteTestScheduleBeforePublish', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.OnsiteTestScheduleBeforePublish;
;----------------------------------------------------------------------
SET @Query = 'SELECT DISTINCT * INTO DeepSeaKingdom.WE.OnsiteTestScheduleBeforePublish FROM ('+@QueryDummy+' UNION '+@QueryParent+') OnsiteTest'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END

