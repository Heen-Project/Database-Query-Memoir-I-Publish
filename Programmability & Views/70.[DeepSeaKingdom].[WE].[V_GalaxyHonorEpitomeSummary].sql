USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_GalaxyHonorEpitomeSummary]
--WITH ENCRYPTION
AS
SELECT DISTINCT pvt.Term/*pvt.Account, pvt.EmployeeNumber*/, pvt.Personname/*, pvt.Name, pvt.HonorVentureBeforeFines, pvt.FinesVenture*/, pvt.HonorVenture, pvt.HonorComposing, pvt.TotalHonor, pvt.Note, [HonorType] = 'Venture', pvt.[ResponsibilityReguler], pvt.[ResponsibilityAppendix], pvt.[FinalTermReguler], pvt.[FinalTermAppendix], pvt.[VentureReguler], pvt.[VentureAppendix] FROM (SELECT DISTINCT [ReportTypeVenture] = IIF(ReportType LIKE '%Appendix%', REPLACE(ReportType,'Appendix','')+'Appendix', ReportType+'Reguler'), Term, Account, EmployeeNumber, Personname, Name, HonorVentureBeforeFines, FinesVenture, HonorVenture, HonorComposing, TotalHonor, Note, [PaidVenture] = ISNULL(CONVERT(FLOAT, TotalVenture),0) - ISNULL(CONVERT(FLOAT, LimitVenture),0)/*IIF(SIGN(ISNULL(CONVERT(FLOAT, TotalVenture),0) - ISNULL(CONVERT(FLOAT, LimitVenture),0))=-1, 0, ISNULL(CONVERT(FLOAT, TotalVenture),0) - ISNULL(CONVERT(FLOAT, LimitVenture),0))*/ FROM DeepSeaKingdom.WE.GalaxyTotalVentureAndCaseComposingReportForHonor) AS SourceTable PIVOT (MAX(SourceTable.PaidVenture) FOR SourceTable.[ReportTypeVenture] IN ([ResponsibilityReguler], [ResponsibilityAppendix], [FinalTermReguler], [FinalTermAppendix], [VentureReguler], [VentureAppendix])) AS pvt
UNION
SELECT DISTINCT pvt.Term/*pvt.Account, pvt.EmployeeNumber*/, pvt.Personname/*, pvt.Name, pvt.HonorVentureBeforeFines, pvt.FinesVenture*/, pvt.HonorVenture, pvt.HonorComposing, pvt.TotalHonor, pvt.Note, [HonorType] = 'CaseCompose', pvt.[ResponsibilityReguler], pvt.[ResponsibilityAppendix], pvt.[FinalTermReguler], pvt.[FinalTermAppendix], pvt.[VentureReguler], pvt.[VentureAppendix] FROM (SELECT DISTINCT [ReportTypeCaseComposing] = IIF(ReportType LIKE '%Appendix%', REPLACE(ReportType,'Appendix','')+'Appendix', ReportType+'Reguler'), Term, Account, EmployeeNumber, Personname, Name, HonorVentureBeforeFines, FinesVenture, HonorVenture, HonorComposing, TotalHonor, Note, [TotalCaseComposing] = ISNULL(CONVERT(FLOAT, TotalCaseComposing),0) - ISNULL(CONVERT(FLOAT, LimitCaseComposing),0)/*IIF(SIGN(ISNULL(CONVERT(FLOAT, TotalCaseComposing),0) - ISNULL(CONVERT(FLOAT, LimitCaseComposing),0))=-1, 0, ISNULL(CONVERT(FLOAT, TotalCaseComposing),0) - ISNULL(CONVERT(FLOAT, LimitCaseComposing),0))*/ FROM DeepSeaKingdom.WE.GalaxyTotalVentureAndCaseComposingReportForHonor) AS SourceTable PIVOT (MAX(SourceTable.TotalCaseComposing) FOR SourceTable.[ReportTypeCaseComposing] IN ([ResponsibilityReguler], [ResponsibilityAppendix], [FinalTermReguler], [FinalTermAppendix], [VentureReguler], [VentureAppendix])) AS pvt