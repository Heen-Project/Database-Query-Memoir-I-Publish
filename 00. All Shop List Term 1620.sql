/*
====================================================================================================
							Import Mark Related Tables 1620
====================================================================================================
*//*
----- Ingredient Branch 1610
	SELECT * FROM [DeepSeaKingdom].[WE].[MarkIngredient_Branch_1610]
----- Ingredient Branch 1620
	SELECT * FROM [DeepSeaKingdom].[WE].[MarkIngredient_Branch_1620]
----- Ingredient Branch 1630
	SELECT * FROM [DeepSeaKingdom].[WE].[MarkIngredient_Branch_1630]
----- Family Loan 1610
	SELECT * FROM [DeepSeaKingdom].[WE].[FamilyInLoan_1610]
----- Family Loan 1620
	SELECT * FROM [DeepSeaKingdom].[WE].[FamilyInLoan_1620]

/*	SELECT TOP 1 * 
	INTO [DeepSeaKingdom].[WE].[FamilyInLoan_1630]
	FROM OPENQUERY([OPRO],'SELECT DISTINCT o.External_SYSTEM_id, o.NAME_DISPLAY FROM PS_N_SF_OUTSTAND o WHERE o.Department = ''YYS01'' AND o.Position = ''RS1'' AND o.ITEM_TERM = ''1630''')*/



*//*
====================================================================================================
					Import Mark Tables 1620 -- Belum ada yang diimport
====================================================================================================
*//*
--Firmware
	SELECT * FROM [Temporary].[WE].[Firmware_GalaxionMark_1620]
	SELECT * FROM [Temporary].[WE].[Firmware_FamilyMarkZeroingCheating_1620]
	SELECT * FROM [Temporary].[WE].[Firmware_FamilyMarkZeroingPresenceLab_1620]
	SELECT * FROM [Temporary].[WE].[Firmware_FamilyMarkZeroingPresenceTheory_1620]
*/