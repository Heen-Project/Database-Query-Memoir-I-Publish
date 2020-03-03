USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_RecalculateHonorEpitomeSummary](
	@Term NVARCHAR(MAX) = N''
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term = MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
SELECT @WorkshopId = Workshops.WorkshopId FROM [LocalDB].Galaxy.dbo.Workshops WHERE Workshops.Name LIKE '%'+@WorkshopName+'%'
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
IF @WorkshopId IS NULL SET @WorkshopName = NULL
;----------------------------------------------------------------------
UPDATE hrs SET hrs.[TotalPaid] = IIF(CEILING (ISNULL(CONVERT(FLOAT,hrs.[ResponsibilityReguler]),0) + ISNULL(CONVERT(FLOAT,hrs.[FinalTermReguler]),0) + ISNULL(CONVERT(FLOAT,hrs.[MidTermReguler]),0) + ISNULL(CONVERT(FLOAT,hrs.[VentureReguler]),0) + ISNULL(CONVERT(FLOAT,hrs.[ResponsibilityAppendix]),0) + ISNULL(CONVERT(FLOAT,hrs.[FinalTermAppendix]),0) + ISNULL(CONVERT(FLOAT,hrs.[MidTermAppendix]),0) + ISNULL(CONVERT(FLOAT,hrs.[VentureAppendix]),0))<0,0,CEILING (ISNULL(CONVERT(FLOAT,hrs.[ResponsibilityReguler]),0) + ISNULL(CONVERT(FLOAT,hrs.[FinalTermReguler]),0) + ISNULL(CONVERT(FLOAT,hrs.[MidTermReguler]),0) + ISNULL(CONVERT(FLOAT,hrs.[VentureReguler]),0) + ISNULL(CONVERT(FLOAT,hrs.[ResponsibilityAppendix]),0) + ISNULL(CONVERT(FLOAT,hrs.[FinalTermAppendix]),0) + ISNULL(CONVERT(FLOAT,hrs.[MidTermAppendix]),0) + ISNULL(CONVERT(FLOAT,hrs.[VentureAppendix]),0)))
FROM [dbo].[HonorEpitomeSummary] hrs
WHERE hrs.QuarterSessionId = @QuarterSessionId
	AND hrs.WorkshopName = @WorkshopName
;----------------------------------------------------------------------
END