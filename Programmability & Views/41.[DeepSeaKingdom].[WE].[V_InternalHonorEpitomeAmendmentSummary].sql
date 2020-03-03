USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_InternalHonorEpitomeVentureSummary]
--WITH ENCRYPTION
AS
SELECT DISTINCT [Name] = UPPER(b.Name), [Personname] = UPPER(pvt.Corrector)
	--,[TotalPaid] = IIF(CEILING(ISNULL(pvt.[FinalTerm],0) + ISNULL(pvt.[Venture],0) + ISNULL(pvt.[Responsibility],0) - ISNULL(pvt.[FinalTerm Limit],0) - ISNULL(pvt.[Venture Limit],0) - ISNULL(pvt.[Responsibility Limit],0) + ISNULL(pvt.[FinalTerm Appendix],0) + ISNULL(pvt.[Venture Appendix],0) + ISNULL(pvt.[Responsibility Appendix],0)) < 0, 0, CEILING(ISNULL(pvt.[FinalTerm],0) + ISNULL(pvt.[Venture],0) + ISNULL(pvt.[Responsibility],0) - ISNULL(pvt.[FinalTerm Limit],0) - ISNULL(pvt.[Venture Limit],0) - ISNULL(pvt.[Responsibility Limit],0) + ISNULL(pvt.[FinalTerm Appendix],0) + ISNULL(pvt.[Venture Appendix],0) + ISNULL(pvt.[Responsibility Appendix],0)))
	,[FinalTerm] = ISNULL(pvt.[FinalTerm],0),[Venture] = ISNULL(pvt.[Venture],0),[Responsibility] = ISNULL(pvt.[Responsibility],0),[FinalTerm Limit] = ISNULL(pvt.[FinalTerm Limit],0),[Venture Limit] = ISNULL(pvt.[Venture Limit],0),[Responsibility Limit] = ISNULL(pvt.[Responsibility Limit],0),[FinalTerm Appendix] = ISNULL(pvt.[FinalTerm Appendix],0),[Venture Appendix] = ISNULL(pvt.[Venture Appendix],0),[Responsibility Appendix] = ISNULL(pvt.[Responsibility Appendix],0)
FROM 
(SELECT DISTINCT chrd.Corrector, [Type] = chrd.Type+(CASE WHEN chrd.LimitStatus <> 'Limit' THEN '' ELSE ' Limit' END)
	,[File] = 
	--SUM(chrd.FileCount) OVER (PARTITION BY chrd.Corrector, chrd.Type)
	SUM(chrd.HasFileCount) OVER (PARTITION BY chrd.Corrector, chrd.Type)
	--SUM(chrd.Deviation) OVER (PARTITION BY chrd.Corrector, chrd.Type)
FROM DeepSeaKingdom.WE.VentureHonorEpitomeDetail chrd
UNION
SELECT DISTINCT chard.Corrector, [Type] = chard.Type+' Appendix'
	,[File] = 
	SUM(chard.FileCount) OVER (PARTITION BY chard.Corrector, chard.Type)
	--SUM(chard.HasFileCount) OVER (PARTITION BY chard.Corrector, chard.Type)
	--SUM(chard.DeviationProcessed) OVER (PARTITION BY chard.Corrector, chard.Type)
FROM DeepSeaKingdom.WE.VentureHonorAppendixEpitomeDetail chard) p
PIVOT (MAX(p.[File]) FOR p.[Type] IN ([Responsibility],[Venture],[FinalTerm],[Responsibility Limit],[Venture Limit],[FinalTerm Limit],[Responsibility Appendix],[Venture Appendix],[FinalTerm Appendix])) AS pvt
	JOIN [LocalDB].Galaxy.dbo.NameBranchs nm ON nm.PersonName = pvt.Corrector JOIN [LocalDB].Galaxy.dbo.Members b ON b.MemberId = nm.MemberId