USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateFamilyBatch] (
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
IF OBJECT_ID('DeepSeaKingdom.WE.RealFamilyBatch', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.RealFamilyBatch;
IF OBJECT_ID('DeepSeaKingdom.WE.FamilyResponsibilityBatch', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.FamilyResponsibilityBatch;
;----------------------------------------------------------------------
SELECT * 
INTO DeepSeaKingdom.WE.FamilyResponsibilityBatch
FROM DeepSeaKingdom.WE.UDFTV_FamilyResponsibilityBatch(@QuarterSessionId)
;------------------------------
SELECT * 
INTO DeepSeaKingdom.WE.RealFamilyBatch
FROM DeepSeaKingdom.WE.UDFTV_RealFamilyBatch (@QuarterSessionId)
;------------------------------
/*
Instead, for a permanent table you can use
IF OBJECT_ID('dbo.Marks', 'U') IS NOT NULL 
  DROP TABLE dbo.Marks;

Or, for a temporary table you can use
IF OBJECT_ID('tempdb.dbo.#T', 'U') IS NOT NULL
  DROP TABLE #T;
*/
END
