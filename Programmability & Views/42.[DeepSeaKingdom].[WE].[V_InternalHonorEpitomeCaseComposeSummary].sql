USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_InternalHonorEpitomeCaseComposeSummary]
--WITH ENCRYPTION
AS
/*
	Yang ini blom ada Appendix
*/
--SELECT DISTINCT [Name] = UPPER(b.Name), [Personname] = UPPER(pvt.CaseComposer)
--	--,[Total] = ISNULL(pvt.[FinalTerm],0)+ISNULL(pvt.[Venture],0)+ISNULL(pvt.[Responsibility],0)
--	,[FinalTerm] = ISNULL(pvt.[FinalTerm],0)
--	--, [Venture] = ISNULL(pvt.[Venture],0), [Responsibility] = ISNULL(pvt.[Responsibility],0)
--	,[FinalTerm Appendix] = 0
--FROM 
--(SELECT DISTINCT cmhrd.CaseComposer, [Type] = cmhrd.Type, [CaseCount] = SUM(cmhrd.CaseCount) OVER (PARTITION BY cmhrd.CaseComposer, cmhrd.Type)
--FROM DeepSeaKingdom.WE.CaseComposingHonorEpitomeDetail cmhrd) p
--PIVOT (MAX(p.[CaseCount]) FOR p.[Type] IN ([Responsibility],[Venture],[FinalTerm])) AS pvt
--	JOIN [LocalDB].Galaxy.dbo.NameBranchs nm ON nm.PersonName = pvt.CaseComposer JOIN [LocalDB].Galaxy.dbo.Members b ON b.MemberId = nm.MemberId

/*
	Yang ini Termasuk Appendix - Kalo udah di update di DeepSeaKingdom.dbo.HonorEpitomeSummary
*/
SELECT DISTINCT [Name] = UPPER(b.Name), [Personname] = UPPER(hrs.Personname), [FinalTerm] = hrs.FinalTermReguler, [FinalTerm Appendix] =  hrs.FinalTermAppendix
FROM DeepSeaKingdom.dbo.HonorEpitomeSummary hrs JOIN [LocalDB].Galaxy.dbo.NameBranchs nm ON nm.PersonName = hrs.Personname JOIN [LocalDB].Galaxy.dbo.Members b ON b.MemberId = nm.MemberId
WHERE hrs.HonorType = 'CaseCompose'