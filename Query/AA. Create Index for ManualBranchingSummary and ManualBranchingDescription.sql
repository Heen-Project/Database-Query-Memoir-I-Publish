;----------------------------------------------------------------------
CREATE INDEX [Index__1__Family_Mark_DTL_AND_LAM_Brand_ACTV] ON [DeepSeaKingdom].[dbo].[ManualMarkSummary] ([Term] DESC, [BrandNbrTheory] ASC, [MemberYY] ASC, [Orderline] ASC, [ContentID] ASC)
--CREATE NONCLUSTERED INDEX [Index__1__Family_Mark_DTL] ON [DeepSeaKingdom].[dbo].[ManualMarkSummary] ([Term]) INCLUDE ([BrandNbrTheory],[ContentID],[MemberYY],[Orderline])
;------------------------------
CREATE INDEX [Index__2__ManualBranchDescription] ON [DeepSeaKingdom].[dbo].[ManualMarkSummary] ([Term] DESC, [ContentIDParent] ASC, [LovelySiteIngredient] ASC)
;------------------------------
CREATE INDEX [Index__3__MemberNumber] ON [DeepSeaKingdom].[dbo].[ManualMarkSummary] ([MemberNumber] ASC)
;------------------------------
--CREATE NONCLUSTERED INDEX [Index__4__LAM_Brand_ACTV] ON [DeepSeaKingdom].[dbo].[ManualMarkSummary] ([Term],[ContentID]) INCLUDE ([BrandNbrTheory],[MemberYY],[Orderline])
;----------------------------------------------------------------------
CREATE INDEX [Index__1__ManualMarkSummary] ON [DeepSeaKingdom].[dbo].[ManualBranchDescription] ([Term] DESC, [ContentID] ASC, [LovelySiteIngredient] ASC) 
;------------------------------
CREATE INDEX [Index__2__GalaxyIngredient] ON [DeepSeaKingdom].[dbo].[ManualBranchDescription] ([GalaxyIngredient] ASC)
;------------------------------
CREATE INDEX [Index__3__ContentCode] ON [DeepSeaKingdom].[dbo].[ManualBranchDescription] ([ContentCode] ASC)
;------------------------------
--CREATE INDEX [Index__4__ManualBranchDescription] ON [DeepSeaKingdom].[dbo].[ManualBranchDescription] ([Term] DESC, [GalaxyIngredient] ASC, [GalaxyNumber] ASC) 
;----------------------------------------------------------------------