USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_CheckMaterialControlBranch] (
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
DECLARE @Query NVARCHAR(MAX), @ColumnPivot NVARCHAR(MAX)
;----------------------------------------------------------------------
SELECT @ColumnPivot = STUFF((SELECT DISTINCT ',['+ctv.[Type]+']' FROM (SELECT DISTINCT ctv.[Type] FROM DeepSeaKingdom.[WE].[V_BrandBusinessVariation] ctv) ctv FOR XML PATH('')),1,1,'')
;------------------------------
SET @Query = N'
SELECT DISTINCT pvt.* FROM (SELECT DISTINCT [QuarterSessions] = QuarterSessions.Description, [ContentName] = co.Name, ctv.BrandName, ctv.Type, ctv.Variation
FROM [DeepSeaKingdom].[WE].[V_BrandBusinessVariation] ctv
	JOIN [LocalDB].[Galaxy].[dbo].[ContentOutlines] co ON co.ContentOutlineId = ctv.ContentOutlineId
	JOIN [LocalDB].[Galaxy].[dbo].[QuarterSessions] ON QuarterSessions.QuarterSessionId = ctv.QuarterSessionId
'+CASE WHEN @Term IS NULL OR @Term = '' THEN '' ELSE 'WHERE QuarterSessions.QuarterSessionId IN ('''+@QuarterSessionId+''')' END+') SourceTable PIVOT (MAX(SourceTable.Variation) FOR SourceTable.Type IN ('+@ColumnPivot+')) AS pvt
ORDER BY 1,2,3'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END

