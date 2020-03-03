USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_CheckFamilyMarkDtl](
	@Term NVARCHAR(MAX) = N''
	,@ExcludeMemberYY NVARCHAR(MAX) = N''
	,@ExcludeMemberNumber NVARCHAR(MAX) = N''
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
DECLARE @Query NVARCHAR(MAX)
;----------------------------------------------------------------------
SET @Query = 'SELECT DISTINCT mss.*
	FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
		LEFT JOIN [ExternalDB].Mark_DB.dbo.PS_Family_Mark_DTL_Shop sgd ON sgd.Brand_NBR = mss.BrandNbrTheory
			AND sgd.ASCID = mss.MemberYY
			AND sgd.Orderline = mss.Orderline
			AND sgd.Term = mss.Term
	WHERE mss.Term = '''+@Term+'''
		AND mss.Orderline IS NOT NULL
		AND sgd.Term IS NULL'
IF @ExcludeMemberYY IS NOT NULL AND @ExcludeMemberYY <> '' SET @Query = @Query + '
			AND mss.MemberYY NOT IN ('+@ExcludeMemberYY+')'
IF @ExcludeMemberNumber IS NOT NULL AND @ExcludeMemberNumber <> '' SET @Query = @Query + '
			AND mss.MemberNumber NOT IN ('+@ExcludeMemberNumber+')'
SET @Query = @Query + '
ORDER BY mss.Term, mss.WorkshopName, mss.BrandNbrTheory, mss.ContentID, mss.Orderline, mss.MemberYY'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END