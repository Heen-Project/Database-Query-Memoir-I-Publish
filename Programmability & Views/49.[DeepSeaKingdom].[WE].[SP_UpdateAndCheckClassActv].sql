USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_UpdateAndCheckLamBrandActv](
	@Term NVARCHAR(MAX) = N''
	,@GalaxyIngredient NVARCHAR(MAX) = N''
	,@UpdateRepeat BIT = 0
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
SET @Query = 'UPDATE mss SET mss.Orderline = lca.Orderline
	FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
		JOIN [ExternalDB].Mark_DB.dbo.LAM_Brand_ACTV lca ON lca.Brand_NBR = mss.BrandNbrTheory
			AND lca.DESCR = mss.LovelySiteIngredient
			AND lca.Content_ID = mss.ContentID
			AND lca.Term = mss.Term
			AND mss.Term = '''+@Term+''''
IF @UpdateRepeat = 0  SET @Query = @Query + '
			AND mss.Orderline IS NULL'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
IF @GalaxyIngredient IS NULL OR @GalaxyIngredient = '' SET @Query = 'SELECT DISTINCT mss.*, lca.*
	FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
		LEFT JOIN [ExternalDB].Mark_DB.dbo.LAM_Brand_ACTV_Shop lca ON lca.Brand_NBR = mss.BrandNbrTheory
			AND lca.Orderline = mss.Orderline
			AND lca.Content_ID = mss.ContentID
			AND lca.Term = mss.Term
	WHERE mss.Term = '''+@Term+'''
		AND mss.Orderline IS NOT NULL
		AND lca.Term IS NULL
	ORDER BY mss.Term, mss.WorkshopName, mss.BrandNbrTheory, mss.ContentID, mss.Orderline, mss.MemberYY'
ELSE SET @Query = 'SELECT DISTINCT mmd.GalaxyIngredient, mmd.GalaxyNumber ,mss.*, lca.*
	FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
		JOIN DeepSeaKingdom.dbo.ManualBranchDescription mmd ON mmd.ContentID = mss.ContentIDParent
			AND mmd.LovelySiteIngredient = mss.LovelySiteIngredient
			AND mmd.Term = mss.Term
			AND mss.Term = '''+@Term+'''
		LEFT JOIN [ExternalDB].Mark_DB.dbo.LAM_Brand_ACTV_Shop lca ON lca.Brand_NBR = mss.BrandNbrTheory
			AND lca.Orderline = mss.Orderline
			AND lca.Content_ID = mss.ContentID
			AND lca.Term = mss.Term
	WHERE mmd.GalaxyIngredient IN ('+@GalaxyIngredient+')
		AND lca.Term IS NULL
	ORDER BY mmd.GalaxyIngredient, mmd.GalaxyNumber, mss.Term, mss.WorkshopName, mss.BrandNbrTheory, mss.ContentID, mss.Orderline, mss.MemberYY'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END