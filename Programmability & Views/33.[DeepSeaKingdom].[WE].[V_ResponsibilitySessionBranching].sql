USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_ResponsibilitySessionBranch]
--WITH ENCRYPTION
AS
SELECT DISTINCT PivotTableOuter.[Id], PivotTableOuter.[QuarterSessionId], PivotTableOuter.[ContentOutlineId], PivotTableOuter.[Type], PivotTableOuter.[Session], [Number] = ISNULL(PivotTableOuter.[Number],0), PivotTableOuter.[Description], PivotTableOuter.[MinutesDuration], PivotTableOuter.[MinutesDelay], PivotTableOuter.[isOnline], PivotTableOuter.[isNoFile], PivotTableOuter.[isTakeHome]
FROM( SELECT DISTINCT PivotTableInner.[Id], PivotTableInner.[QuarterSessionId], PivotTableInner.[ContentOutlineId], PivotTableInner.[Type], [InnerKey] = detailInnerArr.[key], [InnerValue] = detailInnerArr.[value], detailInner.[key], detailInner.[value]
FROM( SELECT DISTINCT asm.[Id], fo.[key], fo.[value]
	FROM [LocalDB].[Items].[dbo].[Galaxy.Model.ResponsibilitySessionBranch] asm 
		CROSS APPLY OPENJSON (asm.[FileObject]) AS fo
	WHERE ISJSON(asm.[FileObject])>0
		AND EXISTS (SELECT NULL FROM [LocalDB].Items.dbo.[Galaxy.Model.ResponsibilitySessionBranch] asm2 WHERE NOT EXISTS (SELECT NULL FROM [LocalDB].[Galaxy].[dbo].[DeletedItems] di WHERE di.[DataId] = asm2.[Id]) AND asm2.[FileName] = asm.[FileName] Batch BY asm2.[FileName] HAVING MAX(asm2.[SavedDate]) = asm.[SavedDate]) 
		AND NOT EXISTS (SELECT NULL FROM [LocalDB].[Galaxy].[dbo].[DeletedItems] di WHERE di.[DataId] = asm.[Id]) ) AS SourceTableInner
PIVOT (MAX(SourceTableInner.[value]) FOR SourceTableInner.[key] IN ([QuarterSessionId],[ContentOutlineId],[Type],[Detail])) AS PivotTableInner
		CROSS APPLY OPENJSON (PivotTableInner.[Detail]) AS detailInnerArr
		CROSS APPLY OPENJSON (detailInnerArr.[value]) AS detailInner ) AS SourceTableOuter
PIVOT (MAX(SourceTableOuter.[value]) FOR SourceTableOuter.[key] IN ([Session],[Number],[Description],[MinutesDuration],[MinutesDelay],[isOnline],[isNoFile],[isTakeHome])) AS PivotTableOuter