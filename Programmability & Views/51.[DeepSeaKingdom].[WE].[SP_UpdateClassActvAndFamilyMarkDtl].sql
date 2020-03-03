USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_UpdateLamBrandActvAndFamilyMarkDtl](
	@Term NVARCHAR(MAX) = N''
	,@Update BIT = 0
	,@LamBrandActvPostDate NVARCHAR(MAX) = N''
	,@FamilyMarkDtlSubmitDate NVARCHAR(MAX) = N''
	,@ASCID NVARCHAR(MAX) = NULL
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
IF OBJECT_ID('[DeepSeaKingdom].[WE].[LAM_Brand_ACTV]', 'U') IS NOT NULL DROP TABLE [DeepSeaKingdom].[WE].[LAM_Brand_ACTV];
IF OBJECT_ID('[DeepSeaKingdom].[WE].[Family_Mark_DTL]', 'U') IS NOT NULL DROP TABLE [DeepSeaKingdom].[WE].[Family_Mark_DTL];
;------------------------------
DECLARE @Query NVARCHAR(MAX), @QueryBody NVARCHAR(MAX)
	,@Family_Mark_DTL_TABLE NVARCHAR(MAX) = '[ExternalDB].[Mark_DB].[dbo].[PS_Family_Mark_DTL_Shop]'
	,@LAM_Brand_ACTV_TABLE NVARCHAR(MAX) = '[ExternalDB].[Mark_DB].[dbo].[LAM_Brand_ACTV_Shop]'
	,@DeepSeaKingdom_Family_Mark_DTL NVARCHAR(MAX) = '[DeepSeaKingdom].[WE].[Family_Mark_DTL]'
	,@DeepSeaKingdom_LAM_Brand_ACTV NVARCHAR(MAX) = '[DeepSeaKingdom].[WE].[LAM_Brand_ACTV]'
	,@History_Family_Mark_DTL NVARCHAR(MAX) = '[DeepSeaKingdom].[dbo].[HISTORY_Family_Mark_DTL]'
	,@History_LAM_Brand_ACTV NVARCHAR(MAX) = '[DeepSeaKingdom].[dbo].[HISTORY_LAM_Brand_ACTV]'
;------------------------------
SET @Query = 'SELECT * INTO '+@DeepSeaKingdom_LAM_Brand_ACTV+' FROM '+@LAM_Brand_ACTV_TABLE+' WHERE Term = '''+@Term+''''
IF @Update = 1 EXECUTE (@Query)
;------------------------------
SET @Query = 'SELECT * INTO '+@DeepSeaKingdom_Family_Mark_DTL+' FROM '+@Family_Mark_DTL_TABLE+' WHERE Term = '''+@Term+''''
IF @Update = 1 EXECUTE (@Query)
;------------------------------
SET @Query = 'CREATE INDEX IDX__LAM_Brand_ACTV ON '+@DeepSeaKingdom_LAM_Brand_ACTV+' (Term, Brand_NBR, Orderline, Content_ID);
CREATE INDEX IDX__Family_Mark_DTL ON '+@DeepSeaKingdom_Family_Mark_DTL+' (Term, Brand_NBR, ASCID, Orderline);'
IF @Update = 1 EXECUTE (@Query)
;----------------------------------------------------------------------
SET @QueryBody = 'FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
	JOIN '+@DeepSeaKingdom_Family_Mark_DTL+' sgd ON sgd.Brand_NBR = mss.BrandNbrTheory
		AND sgd.ASCID = mss.MemberYY
		AND sgd.Orderline = mss.Orderline
		AND sgd.Term = mss.Term
		AND mss.Term = '''+@Term+'''
	JOIN '+@DeepSeaKingdom_LAM_Brand_ACTV+' lca ON lca.Brand_NBR = sgd.Brand_NBR
		AND lca.Orderline = sgd.Orderline
		AND lca.Term = sgd.Term
		--AND lca.Content_ID = mss.ContentID
	WHERE (mss.Mark <> sgd.Family_Mark 
			OR sgd.SUBMITTED_PROID IS NULL 
			OR sgd.SUBMITTED_PROID = '''')
		AND ISNUMERIC(mss.Mark) = 1'
IF @ExcludeMemberYY IS NOT NULL AND @ExcludeMemberYY <> '' SET @QueryBody = @QueryBody + '
		AND mss.MemberYY NOT IN ('+@ExcludeMemberYY+')'
IF @ExcludeMemberNumber IS NOT NULL AND @ExcludeMemberNumber <> '' SET @QueryBody = @QueryBody + '
		AND mss.MemberNumber NOT IN ('+@ExcludeMemberNumber+')'
;------------------------------
SET @Query = '	UPDATE lca 
	SET lca.SUBMIT_DT = GETDATE()
		,lca.APPROVE_DATE = IIF(lca.APPROVE_DATE IS NULL OR lca.APPROVE_DATE = '''', GETDATE(), lca.APPROVE_DATE)
	--	,lca.ASCID = '''''
IF @LamBrandActvPostDate IS NOT NULL AND @LamBrandActvPostDate <> '' SET @Query = @Query+ '
		,lca.POST_DT = '''+@LamBrandActvPostDate+''''
SET @Query = @Query+ '
	OUTPUT NEWID(), DELETED.[Term], DELETED.[Brand_NBR], DELETED.[Orderline], DELETED.[TYPE], DELETED.[DESCR], DELETED.[DESCRSHORT], DELETED.[Content_ID], DELETED.[SUBMIT_DT], DELETED.[APPROVE_DATE], DELETED.[POST_DT], DELETED.[ASCID], DELETED.[Brand_OnsiteTest_TYPE], DELETED.[DESCRLONG_NOTES], GETDATE(), '''+@LAM_Brand_ACTV_TABLE+''', NULL, IIF(INSERTED.[SUBMIT_DT] = DELETED.[SUBMIT_DT], NULL, INSERTED.[SUBMIT_DT]), IIF(INSERTED.[APPROVE_DATE] = DELETED.[APPROVE_DATE], NULL, INSERTED.[APPROVE_DATE]), IIF(INSERTED.[POST_DT] = DELETED.[POST_DT], NULL, INSERTED.[POST_DT]), IIF(INSERTED.[ASCID] = DELETED.[ASCID], NULL, INSERTED.[ASCID])
	INTO '+@History_LAM_Brand_ACTV
SET @Query = @Query +'
	'+ @QueryBody
;------------------------------
IF @Update = 1 EXECUTE (@Query)
;----------------------------------------------------------------------
SET @QueryBody = 'FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
	JOIN '+@DeepSeaKingdom_Family_Mark_DTL+' sgd ON sgd.Brand_NBR = mss.BrandNbrTheory
		AND sgd.ASCID = mss.MemberYY
		AND sgd.Orderline = mss.Orderline
		AND sgd.Term = mss.Term
		AND mss.Term = '''+@Term+'''
	WHERE (mss.Mark <> sgd.Family_Mark 
			OR sgd.SUBMITTED_PROID IS NULL 
			OR sgd.SUBMITTED_PROID = '''')
		AND ISNUMERIC(mss.Mark) = 1'
IF @ExcludeMemberYY IS NOT NULL AND @ExcludeMemberYY <> '' SET @QueryBody = @QueryBody + '
		AND mss.MemberYY NOT IN ('+@ExcludeMemberYY+')'
IF @ExcludeMemberNumber IS NOT NULL AND @ExcludeMemberNumber <> '' SET @QueryBody = @QueryBody + '
		AND mss.MemberNumber NOT IN ('+@ExcludeMemberNumber+')'
;------------------------------
SET @Query = '	UPDATE sgd 
	SET sgd.Family_Mark = mss.Mark
		,sgd.SUBMITTED_PROID = IIF(sgd.SUBMITTED_PROID IS NULL OR sgd.SUBMITTED_PROID = '''', '''+@ASCID+''', sgd.SUBMITTED_PROID)
		,sgd.LASTUPDPROID = '''+@ASCID+''''
IF @FamilyMarkDtlSubmitDate IS NOT NULL AND @FamilyMarkDtlSubmitDate <> '' SET @Query = @Query+ '
		,sgd.SUBMITTED_DT = '''+@FamilyMarkDtlSubmitDate+''''
SET @Query = @Query+ '
		,sgd.UPDATED_DTTM = GETDATE()
	OUTPUT NEWID(), DELETED.[Term], DELETED.[Brand_NBR], DELETED.[ASCID], DELETED.[Orderline], DELETED.[Family_Mark], DELETED.[EXCLUDE_FROM_Mark], DELETED.[DUE_DT], DELETED.[SUBMITTED_PROID], DELETED.[SUBMITTED_DT], DELETED.[LASTUPDPROID], DELETED.[UPDATED_DTTM], GETDATE(), '''+@Family_Mark_DTL_TABLE+''', NULL, IIF(INSERTED.[Family_Mark] = DELETED.[Family_Mark], NULL, INSERTED.[Family_Mark]), IIF(INSERTED.[SUBMITTED_PROID] = DELETED.[SUBMITTED_PROID], NULL, INSERTED.[SUBMITTED_PROID]), IIF(INSERTED.[SUBMITTED_DT] = DELETED.[SUBMITTED_DT], NULL, INSERTED.[SUBMITTED_DT]), IIF(INSERTED.[LASTUPDPROID] = DELETED.[LASTUPDPROID], NULL, INSERTED.[LASTUPDPROID]), IIF(INSERTED.[UPDATED_DTTM] = DELETED.[UPDATED_DTTM], NULL, INSERTED.[UPDATED_DTTM])
	INTO '+@History_Family_Mark_DTL+'
	' + @QueryBody
;------------------------------
IF @Update = 1 EXECUTE (@Query)
;----------------------------------------------------------------------
SET @QueryBody = 'FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
	JOIN '+@Family_Mark_DTL_TABLE+' sgd ON sgd.Brand_NBR = mss.BrandNbrTheory
		AND sgd.ASCID = mss.MemberYY
		AND sgd.Orderline = mss.Orderline
		AND sgd.Term = mss.Term
		AND mss.Term = '''+@Term+'''
	JOIN '+@LAM_Brand_ACTV_TABLE+' lca ON lca.Brand_NBR = sgd.Brand_NBR
		AND lca.Orderline = sgd.Orderline
		AND lca.Term = sgd.Term
		--AND lca.Content_ID = mss.ContentID
	WHERE (mss.Mark <> sgd.Family_Mark 
			OR sgd.SUBMITTED_PROID IS NULL 
			OR sgd.SUBMITTED_PROID = '''')
		AND ISNUMERIC(mss.Mark) = 1'
IF @ExcludeMemberYY IS NOT NULL AND @ExcludeMemberYY <> '' SET @QueryBody = @QueryBody + '
		AND mss.MemberYY NOT IN ('+@ExcludeMemberYY+')'
IF @ExcludeMemberNumber IS NOT NULL AND @ExcludeMemberNumber <> '' SET @QueryBody = @QueryBody + '
		AND mss.MemberNumber NOT IN ('+@ExcludeMemberNumber+')'
;------------------------------
SET @Query = '	UPDATE lca 
	SET lca.SUBMIT_DT = GETDATE()
		,lca.APPROVE_DATE = IIF(lca.APPROVE_DATE IS NULL OR lca.APPROVE_DATE = '''', GETDATE(), lca.APPROVE_DATE)
	--	,lca.ASCID = '''''
IF @LamBrandActvPostDate IS NOT NULL AND @LamBrandActvPostDate <> '' SET @Query = @Query+ '
		,lca.POST_DT = '''+@LamBrandActvPostDate+''''
SET @Query = @Query +'
	'+ @QueryBody
IF @Update = 0 SET @Query = ''
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @QueryBody = 'FROM DeepSeaKingdom.dbo.ManualMarkSummary mss
	JOIN '+@Family_Mark_DTL_TABLE+' sgd ON sgd.Brand_NBR = mss.BrandNbrTheory
		AND sgd.ASCID = mss.MemberYY
		AND sgd.Orderline = mss.Orderline
		AND sgd.Term = mss.Term
		AND mss.Term = '''+@Term+'''
	WHERE (mss.Mark <> sgd.Family_Mark 
			OR sgd.SUBMITTED_PROID IS NULL 
			OR sgd.SUBMITTED_PROID = '''')
		AND ISNUMERIC(mss.Mark) = 1'
IF @ExcludeMemberYY IS NOT NULL AND @ExcludeMemberYY <> '' SET @QueryBody = @QueryBody + '
		AND mss.MemberYY NOT IN ('+@ExcludeMemberYY+')'
IF @ExcludeMemberNumber IS NOT NULL AND @ExcludeMemberNumber <> '' SET @QueryBody = @QueryBody + '
		AND mss.MemberNumber NOT IN ('+@ExcludeMemberNumber+')'
;------------------------------
SET @Query = '	UPDATE sgd 
	SET sgd.Family_Mark = mss.Mark
		,sgd.SUBMITTED_PROID = IIF(sgd.SUBMITTED_PROID IS NULL OR sgd.SUBMITTED_PROID = '''', '''+@ASCID+''', sgd.SUBMITTED_PROID)
		,sgd.LASTUPDPROID = '''+@ASCID+''''
IF @FamilyMarkDtlSubmitDate IS NOT NULL AND @FamilyMarkDtlSubmitDate <> '' SET @Query = @Query+ '
		,sgd.SUBMITTED_DT = '''+@FamilyMarkDtlSubmitDate+''''
SET @Query = @Query+ '
		,sgd.UPDATED_DTTM = GETDATE()
	' + @QueryBody
IF @Update = 0 SET @Query = 'SELECT [OldMark] = sgd.Family_Mark, [NewMark] = mss.Mark, sgd.*, mss.*
	' + @QueryBody
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
END