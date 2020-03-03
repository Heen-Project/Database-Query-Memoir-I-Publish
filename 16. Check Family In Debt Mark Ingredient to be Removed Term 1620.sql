;------------------------------
DECLARE @Term NVARCHAR(MAX) = N'1620'
	,@WorkshopName NVARCHAR(MAX) = N'Firmware'
;------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX)
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
;------------------------------

/******************************************************************************************
 *		Generate Family Mark Ingredient that going to be Removed Because Loan
 ******************************************************************************************//*
	 * @FamilyInLoanTable, pasttin tablenya ada kolom EXTERNAL_SYSTEM_ID yang isinya MemberNumber (Kalo dikosongin bakal check dari View PS_N_SF_OUTSTAND dari bcs)
*/
	--EXECUTE [WE].[SP_GenerateFamilyInLoanRemoved] @Term = @Term
	--	,@FamilyInLoanTable = '[DeepSeaKingdom].[WE].[FamilyInLoan_1620]'
	SELECT * FROM DeepSeaKingdom.WE.FamilyInLoanRemoved ORDER BY 2,4,1,5,6