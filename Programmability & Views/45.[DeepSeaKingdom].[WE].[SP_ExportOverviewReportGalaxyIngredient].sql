USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_ExportOverviewReportGalaxyIngredient](
    @Term NVARCHAR(MAX) = N''
    ,@WorkshopName NVARCHAR(MAX) = N'Firmware'
)
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
--IF OBJECT_ID('tempdb.dbo.##PresenceLimit', 'U') IS NOT NULL DROP TABLE ##PresenceLimit;
--IF OBJECT_ID('tempdb.dbo.##OnsiteTestPresenceVerification', 'U') IS NOT NULL DROP TABLE ##OnsiteTestPresenceVerification;
;----------------------------------------------------------------------
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX), @QueryInner NVARCHAR(MAX), @QueryHeader NVARCHAR(MAX), @QueryBranch NVARCHAR(MAX), @QueryOut NVARCHAR(MAX), @FileName VARCHAR(MAX), @bcpCommand VARCHAR(8000), @OpenQuery NVARCHAR(MAX), @LinkedServer NVARCHAR(MAX) = N'[LocalDB]', @GalaxyIngredient NVARCHAR(MAX)
;----------------------------------------------------------------------
IF @Term IS NULL OR @Term = '' SELECT @Term= MAX(Period)-IIF(MAX(Period)%100=10,80,10) FROM Seaweed.dbo.QuarterSessions
;------------------------------
SELECT @QuarterSessionId = QuarterSessions.QuarterSessionId FROM Seaweed.dbo.QuarterSessions WHERE QuarterSessions.Period = @Term
SELECT @WorkshopId = Workshops.WorkshopId FROM [LocalDB].Galaxy.dbo.Workshops WHERE Workshops.Name LIKE '%'+@WorkshopName+'%'
;------------------------------
IF @QuarterSessionId IS NULL SET @Term = NULL
IF @WorkshopId IS NULL SET @WorkshopName = NULL
;------------------------------
--SELECT al.* INTO ##PresenceLimit 
--FROM DeepSeaKingdom.WE.V_PresenceLimit al WHERE al.QuarterSessionId LIKE '%'+@QuarterSessionId+'%' AND al.WorkshopId LIKE '%'+@WorkshopId+'%'
;------------------------------
--SELECT DISTINCT eav.* INTO ##OnsiteTestPresenceVerification
--FROM DeepSeaKingdom.WE.UDFTV_OnsiteTestPresenceVerification(@QuarterSessionId) eav
;------------------------------
SET @OpenQuery = 'SELECT DISTINCT Topics.Name TopicName, co.Name ContentName, d.dept Department FROM Galaxy.dbo.BrandBusinesss ct JOIN Galaxy.dbo.Topics ON ct.TopicId = Topics.TopicId JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId JOIN (SELECT DISTINCT sub.Name [Topic], cou.Name [Content], dep.Name [Dept] FROM Galaxy.dbo.Topics sub JOIN Galaxy.dbo.ContentOutlines cou ON sub.ContentOutlineId = cou.ContentOutlineId AND sub.Name = cou.Name JOIN Galaxy.dbo.Departments dep ON dep.DepartmentId = sub.DepartmentId) d ON d.Content = co.Name WHERE ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%'' AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)'
;----------------------------------------------------------------------
/*
 * Sistem PeMarkan Lama
 * MID AND LAST PRACTICUM OnsiteTest RESULT Epitome
*/
SET @GalaxyIngredient = 'FinalTerm'
SET @FileName = REPLACE('D:\Overview PeMarkan Lama - MID AND LAST PRACTICUM OnsiteTest RESULT Epitome ['+@Term+'] '+CONVERT(VARCHAR,GETDATE(),105)+'.csv','/','-')
;------------------------------
    /*,[AbsentPracticumOld]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(Presence.MeetingCount-COALESCE(al.MaximumAbsence, IIF(Presence.MeetingCount>6,2,1))>Presence.TotalPresent, 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/ 
    /*,[AbsentPracticumNew]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(Presence.TotalAbsent>COALESCE(al.MaximumAbsence,IIF(Presence.MeetingCount>6,2,1))t, 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/ 
SET @QueryBranch = 'SELECT DISTINCT
        [ContentOutline]=(CASE WHEN s.ContentOutline <> s.TopicName THEN s.ContentOutline+''*'' ELSE s.ContentOutline END)
        ,[TopicName]=s.TopicName
        ,[AssociateCode]=s.AssociateCode
        ,[AssociateName]=s.AssociateName
        ,[MemberNumber]=s.MemberNumber
        ,[MemberName]=s.MemberName
        ,[BrandName]=s.BrandName
        ,['+@GalaxyIngredient+']=s.['+@GalaxyIngredient+']
        ,[Major]=AS_Topic.Department
    FROM DeepSeaKingdom.WE.FamilyMarkSummary s
        JOIN OPENQUERY('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') AS_Topic ON LEFT(AS_Topic.ContentName,CHARINDEX(''-'',AS_Topic.ContentName)-1)=LEFT(s.ContentOutline,CHARINDEX(''-'',s.ContentOutline)-1)
            AND AS_Topic.TopicName=s.TopicName
            AND s.Term = '''+@Term+'''
    WHERE s.['+@GalaxyIngredient+'] <> ''-''
        AND ISNUMERIC(s.['+@GalaxyIngredient+']) = 1
        AND s.WorkshopName='''+@WorkshopName+''''
SET @QueryHeader = 'SELECT DISTINCT [Major]=''Major'',[Topic Code]=''Topic Code'',[Topic Name]=''Topic Name'',[Brand]=''Brand'',[Associate Code]=''Associate Code'',[Associate Name]=''Associate Name'',[Family Count]=''Family Count'',[AVG '+@GalaxyIngredient+']=''AVG '+@GalaxyIngredient+''',[A]=''A'',[B]=''B'',[C]=''C'',[D]=''D'',[E]=''E'',[Absent]=''Absent'',[OrderKey]=1'
SET @QueryInner = 'SELECT DISTINCT 
    [Major]=summary.Major
    ,[Topic Code]=RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline)-1))
    ,[Topic Name]=REPLACE (summary.ContentOutline,RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline))),'''')
    ,[Brand]=summary.BrandName
    ,[Associate Code]=summary.AssociateCode
    ,[Associate Name]=UPPER(summary.AssociateName)
    ,[Family Count]=CONVERT(VARCHAR,COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))
    ,[AVG '+@GalaxyIngredient+']=CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0))
    ,[A]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] >= 85 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[B]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 85 AND summary.['+@GalaxyIngredient+'] >= 75 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[C]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 75 AND summary.['+@GalaxyIngredient+'] >= 65 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[D]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 65 AND summary.['+@GalaxyIngredient+'] >= 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[E]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[AbsentFinalOrMid]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(mss.Status NOT IN (''Present''), 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''
    ,[OrderKey]=2
FROM ('+@QueryBranch+') summary
    JOIN DeepSeaKingdom.WE.FamilyPresenceSummary Presence ON Presence.TopicName=summary.TopicName
        AND Presence.BrandName=summary.BrandName
        AND Presence.MemberNumber=summary.MemberNumber
    LEFT JOIN (SELECT DISTINCT mss.* FROM DeepSeaKingdom.dbo.ManualMarkSummary mss JOIN DeepSeaKingdom.dbo.ManualBranchDescription mmd ON mmd.Term = mss.Term AND mmd.ContentID = mss.ContentIDParent AND mmd.LovelySiteIngredient = mss.LovelySiteIngredient AND mmd.GalaxyIngredient IN (''FinalTerm'',''MidTerm'') AND mss.Term='''+@Term+''') mss ON mss.TopicName=summary.TopicName
        AND mss.BrandName=summary.BrandName
        AND mss.MemberNumber=summary.MemberNumber 
    /*LEFT JOIN ##PresenceLimit al ON al.QuarterSessionId = Presence.QuarterSessionId
        AND al.ContentOutlineId = Presence.ContentOutlineId 
    LEFT JOIN ##OnsiteTestPresenceVerification eav ON eav.Topic = Presence.TopicName
        AND eav.QuarterSessionId = Presence.QuarterSessionId
        AND eav.FamilyMemberNumber = Presence.MemberNumber
        AND EXISTS (SELECT NULL FROM ##OnsiteTestPresenceVerification eav2 WHERE eav2.QuarterSessionId = eav.QuarterSessionId AND eav2.Topic = eav.Topic AND eav2.FamilyMemberNumber = eav.FamilyMemberNumber Batch BY eav2.QuarterSessionId, eav2.Topic, eav2.FamilyMemberNumber HAVING MAX(CONVERT(DATETIME,eav2.SavedDate)) = CONVERT(DATETIME,eav.SavedDate))*/ 
WHERE LEFT(summary.MemberNumber,2) < ''18''
    /*AND summary.BrandName NOT LIKE ''L%''*/
ORDER BY [OrderKey],1,2,4,5,3,7'
;------------------------------
SET @QueryOut = @QueryHeader+' UNION '+@QueryInner
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut, CHAR(13), ''), CHAR(10), ''), CHAR(9), ' ')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '( ', '('), ' )', ')')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, ', ', ','), ' ,', ',')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '> ', '>'), ' >', '>')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '< ', '<'), ' <', '<')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '= ', '='), ' =', '=')
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut,' ','\/'),'/\',''),'\/',' ')
SET @bcpCommand = 'bcp "'+@QueryOut+'" queryout "'
SET @bcpCommand = @bcpCommand + @FileName + '" -T -t , -c'
PRINT 'Lama - MID AND LAST PRACTICUM OnsiteTest RESULT Epitome ['+@Term+'] Length ::'+CONVERT(VARCHAR,LEN(@bcpCommand))
IF LEN(@bcpCommand) >= 7950 EXECUTE (@QueryInner)
ELSE EXEC master.dbo.xp_cmdshell @bcpCommand
;----------------------------------------------------------------------
/*
 * Sistem PeMarkan Baru
 * MID AND LAST PRACTICUM OnsiteTest RESULT Epitome
*/
SET @FileName = REPLACE('D:\Overview PeMarkan Baru - MID AND LAST PRACTICUM OnsiteTest RESULT Epitome ['+@Term+'] '+CONVERT(VARCHAR,GETDATE(),105)+'.csv','/','-')
;------------------------------
    /*,[AbsentPracticumOld]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(Presence.MeetingCount-COALESCE(al.MaximumAbsence, IIF(Presence.MeetingCount>6,2,1))>Presence.TotalPresent, 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/ 
    /*,[AbsentPracticumNew]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(Presence.TotalAbsent>COALESCE(al.MaximumAbsence,IIF(Presence.MeetingCount>6,2,1))t, 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/ 
SET @QueryHeader = 'SELECT DISTINCT [Major]=''Major'',[Topic Code]=''Topic Code'',[Topic Name]=''Topic Name'',[Brand]=''Brand'',[Associate Code]=''Associate Code'',[Associate Name]=''Associate Name'',[Family Count]=''Family Count'',[AVG '+@GalaxyIngredient+']=''AVG '+@GalaxyIngredient+''',[A]=''A'',[A-]=''A-'',[B+]=''B+'',[B]=''B'',[B-]=''B-'',[C]=''C'',[D]=''D'',[E]=''E'',[Absent]=''Absent'',[OrderKey]=1'
SET @QueryInner = 'SELECT DISTINCT 
    [Major]=summary.Major
    ,[Topic Code]=RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline)-1))
    ,[Topic Name]=REPLACE (summary.ContentOutline,RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline))),'''')
    ,[Brand]=summary.BrandName
    ,[Associate Code]=summary.AssociateCode
    ,[Associate Name]=UPPER(summary.AssociateName)
    ,[Family Count]=CONVERT(VARCHAR,COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))
    ,[AVG '+@GalaxyIngredient+']=CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0))
    ,[A]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] >= 90 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[A-]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 90 AND summary.['+@GalaxyIngredient+'] >= 85 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[B+]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 85 AND summary.['+@GalaxyIngredient+'] >= 80 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[B]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 80 AND summary.['+@GalaxyIngredient+'] >= 75 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[B-]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 75 AND summary.['+@GalaxyIngredient+'] >= 70 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[C]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 70 AND summary.['+@GalaxyIngredient+'] >= 65 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[D]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 65 AND summary.['+@GalaxyIngredient+'] >= 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[E]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[AbsentFinalOrMid]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(mss.Status NOT IN (''Present''), 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''
    ,[OrderKey]=2
FROM ('+@QueryBranch+') summary
    JOIN DeepSeaKingdom.WE.FamilyPresenceSummary Presence ON Presence.TopicName=summary.TopicName
        AND Presence.BrandName=summary.BrandName
        AND Presence.MemberNumber=summary.MemberNumber
    LEFT JOIN (SELECT DISTINCT mss.* FROM DeepSeaKingdom.dbo.ManualMarkSummary mss JOIN DeepSeaKingdom.dbo.ManualBranchDescription mmd ON mmd.Term = mss.Term AND mmd.ContentID = mss.ContentIDParent AND mmd.LovelySiteIngredient = mss.LovelySiteIngredient AND mmd.GalaxyIngredient IN (''FinalTerm'',''MidTerm'') AND mss.Term='''+@Term+''') mss ON mss.TopicName=summary.TopicName
        AND mss.BrandName=summary.BrandName
        AND mss.MemberNumber=summary.MemberNumber 
    /*LEFT JOIN ##PresenceLimit al ON al.QuarterSessionId = Presence.QuarterSessionId
        AND al.ContentOutlineId = Presence.ContentOutlineId 
    LEFT JOIN ##OnsiteTestPresenceVerification eav ON eav.Topic = Presence.TopicName
        AND eav.QuarterSessionId = Presence.QuarterSessionId
        AND eav.FamilyMemberNumber = Presence.MemberNumber
        AND EXISTS (SELECT NULL FROM ##OnsiteTestPresenceVerification eav2 WHERE eav2.QuarterSessionId = eav.QuarterSessionId AND eav2.Topic = eav.Topic AND eav2.FamilyMemberNumber = eav.FamilyMemberNumber Batch BY eav2.QuarterSessionId, eav2.Topic, eav2.FamilyMemberNumber HAVING MAX(CONVERT(DATETIME,eav2.SavedDate)) = CONVERT(DATETIME,eav.SavedDate))*/ 
WHERE LEFT(summary.MemberNumber,2) > ''17''
    /*AND summary.BrandName NOT LIKE ''L%''*/
    AND summary.['+@GalaxyIngredient+'] IS NOT NULL 
ORDER BY [OrderKey],1,2,4,5,3,7'
;------------------------------
SET @QueryOut = @QueryHeader+' UNION '+@QueryInner
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut, CHAR(13), ''), CHAR(10), ''), CHAR(9), ' ')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '( ', '('), ' )', ')')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, ', ', ','), ' ,', ',')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '> ', '>'), ' >', '>')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '< ', '<'), ' <', '<')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '= ', '='), ' =', '=')
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut,' ','\/'),'/\',''),'\/',' ')
SET @bcpCommand = 'bcp "'+@QueryOut+'" queryout "'
SET @bcpCommand = @bcpCommand + @FileName + '" -T -t , -c'
PRINT 'Baru - MID AND LAST PRACTICUM OnsiteTest RESULT Epitome ['+@Term+'] Length ::'+CONVERT(VARCHAR,LEN(@bcpCommand))
IF LEN(@bcpCommand) >= 7950 EXECUTE (@QueryInner)
ELSE EXEC master.dbo.xp_cmdshell @bcpCommand
;----------------------------------------------------------------------
/*
 * Sistem PeMarkan Lama
 * Venture AND REPORT RESULT Epitome
*/
SET @GalaxyIngredient = 'Venture'
DECLARE @GalaxyIngredient2 NVARCHAR(MAX) = 'Responsibility'
SET @FileName = REPLACE('D:\Overview PeMarkan Lama - Venture AND REPORT Epitome ['+@Term+'] '+CONVERT(VARCHAR,GETDATE(),105)+'.csv','/','-')
;------------------------------
SET @QueryBranch = 'SELECT DISTINCT
        [ContentOutline]=(CASE WHEN s.ContentOutline <> s.TopicName THEN s.ContentOutline+''*'' ELSE s.ContentOutline END)
        ,[TopicName]=s.TopicName
        ,[AssociateCode]=s.AssociateCode
        ,[AssociateName]=s.AssociateName
        ,[MemberNumber]=s.MemberNumber
        ,[MemberName]=s.MemberName
        ,[BrandName]=s.BrandName
        ,['+@GalaxyIngredient+']=s.['+@GalaxyIngredient+']
        ,['+@GalaxyIngredient2+']=s.['+@GalaxyIngredient2+']
        ,[Major]=AS_Topic.Department
    FROM DeepSeaKingdom.WE.FamilyMarkSummary s
        JOIN OPENQUERY('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') AS_Topic ON LEFT(AS_Topic.ContentName,CHARINDEX(''-'',AS_Topic.ContentName)-1)=LEFT(s.ContentOutline,CHARINDEX(''-'',s.ContentOutline)-1)
            AND AS_Topic.TopicName=s.TopicName
            AND s.Term = '''+@Term+'''
    WHERE (s.['+@GalaxyIngredient+'] <> ''-'' OR s.['+@GalaxyIngredient2+'] <> ''-'')
        AND (ISNUMERIC(s.['+@GalaxyIngredient+']) = 1 AND ISNUMERIC(s.['+@GalaxyIngredient2+']) = 1)
        AND s.WorkshopName='''+@WorkshopName+''''
SET @QueryHeader = 'SELECT DISTINCT [Major]=''Major'',[Topic Code]=''Topic Code'',[Topic Name]=''Topic Name'',[Brand]=''Brand'',[Associate Code]=''Associate Code'',[Associate Name]=''Associate Name'',[Family Count]=''Family Count'',[AVG '+@GalaxyIngredient+']=''AVG '+@GalaxyIngredient+''',[A '+@GalaxyIngredient+']=''A '+@GalaxyIngredient+''',[B '+@GalaxyIngredient+']=''B '+@GalaxyIngredient+''',[C '+@GalaxyIngredient+']=''C '+@GalaxyIngredient+''',[D '+@GalaxyIngredient+']=''D '+@GalaxyIngredient+''',[E '+@GalaxyIngredient+']=''E '+@GalaxyIngredient+''',[AVG '+@GalaxyIngredient2+']=''AVG '+@GalaxyIngredient2+''',[A '+@GalaxyIngredient2+']=''A '+@GalaxyIngredient2+''',[B '+@GalaxyIngredient2+']=''B '+@GalaxyIngredient2+''',[C '+@GalaxyIngredient2+']=''C '+@GalaxyIngredient2+''',[D '+@GalaxyIngredient2+']=''D '+@GalaxyIngredient2+''',[E '+@GalaxyIngredient2+']=''E '+@GalaxyIngredient2+''',[OrderKey]=1'
SET @QueryInner = 'SELECT DISTINCT
    [Major]=summary.Major
    ,[Topic Code]=RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline)-1))
    ,[Topic Name]=REPLACE (summary.ContentOutline,RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline))),'''')
    ,[Brand]=summary.BrandName
    ,[Associate Code]=summary.AssociateCode
    ,[Associate Name]=UPPER(summary.AssociateName)
    ,[Family Count]=CONVERT(VARCHAR,COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))
    ,[AVG '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0)))
    ,[A '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] >= 85 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 85 AND summary.['+@GalaxyIngredient+'] >= 75 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[C '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 75 AND summary.['+@GalaxyIngredient+'] >= 65 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[D '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 65 AND summary.['+@GalaxyIngredient+'] >= 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[E '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[AVG '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0)))
    ,[A '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] >= 85 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 85 AND summary.['+@GalaxyIngredient2+'] >= 75 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[C '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 75 AND summary.['+@GalaxyIngredient2+'] >= 65 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[D '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 65 AND summary.['+@GalaxyIngredient2+'] >= 50 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[E '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 50 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[OrderKey]=2
FROM ('+@QueryBranch+') summary
    JOIN DeepSeaKingdom.WE.FamilyPresenceSummary Presence ON Presence.TopicName=summary.TopicName
        AND Presence.BrandName=summary.BrandName
        AND Presence.MemberNumber=summary.MemberNumber
WHERE LEFT(summary.MemberNumber,2) < ''18''
    /*AND summary.BrandName NOT LIKE ''L%''*/
ORDER BY [OrderKey],1,2,4,5,3,7'
;------------------------------
SET @QueryOut = @QueryHeader+' UNION '+@QueryInner
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut, CHAR(13), ''), CHAR(10), ''), CHAR(9), ' ')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '( ', '('), ' )', ')')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, ', ', ','), ' ,', ',')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '> ', '>'), ' >', '>')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '< ', '<'), ' <', '<')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '= ', '='), ' =', '=')
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut,' ','\/'),'/\',''),'\/',' ')
SET @bcpCommand = 'bcp "'+@QueryOut+'" queryout "'
SET @bcpCommand = @bcpCommand + @FileName + '" -T -t , -c'
PRINT 'Lama - Venture AND REPORT Epitome ['+@Term+'] Length ::'+CONVERT(VARCHAR,LEN(@bcpCommand))
IF LEN(@bcpCommand) >= 7950 EXECUTE (@QueryInner)
ELSE EXEC master.dbo.xp_cmdshell @bcpCommand
;----------------------------------------------------------------------
/*
 * Sistem PeMarkan Baru
 * Venture AND REPORT RESULT Epitome
*/
SET @FileName = REPLACE('D:\Overview PeMarkan Baru - Venture AND REPORT Epitome ['+@Term+'] '+CONVERT(VARCHAR,GETDATE(),105)+'.csv','/','-')
;------------------------------
SET @QueryHeader = 'SELECT DISTINCT [Major]=''Major'',[Topic Code]=''Topic Code'',[Topic Name]=''Topic Name'',[Brand]=''Brand'',[Associate Code]=''Associate Code'',[Associate Name]=''Associate Name'',[Family Count]=''Family Count'',[AVG '+@GalaxyIngredient+']=''AVG '+@GalaxyIngredient+''',[A '+@GalaxyIngredient+']=''A '+@GalaxyIngredient+''',[A- '+@GalaxyIngredient+']=''A- '+@GalaxyIngredient+''',[B+ '+@GalaxyIngredient+']=''B+ '+@GalaxyIngredient+''',[B '+@GalaxyIngredient+']=''B '+@GalaxyIngredient+''',[B- '+@GalaxyIngredient+']=''B- '+@GalaxyIngredient+''',[C '+@GalaxyIngredient+']=''C '+@GalaxyIngredient+''',[D '+@GalaxyIngredient+']=''D '+@GalaxyIngredient+''',[E '+@GalaxyIngredient+']=''E '+@GalaxyIngredient+''',[AVG '+@GalaxyIngredient2+']=''AVG '+@GalaxyIngredient2+''',[A '+@GalaxyIngredient2+']=''A '+@GalaxyIngredient2+''',[A- '+@GalaxyIngredient2+']=''A- '+@GalaxyIngredient2+''',[B+ '+@GalaxyIngredient2+']=''B+ '+@GalaxyIngredient2+''',[B '+@GalaxyIngredient2+']=''B '+@GalaxyIngredient2+''',[B- '+@GalaxyIngredient2+']=''B- '+@GalaxyIngredient2+''',[C '+@GalaxyIngredient2+']=''C '+@GalaxyIngredient2+''',[D '+@GalaxyIngredient2+']=''D '+@GalaxyIngredient2+''',[E '+@GalaxyIngredient2+']=''E '+@GalaxyIngredient2+''',[OrderKey]=1'
SET @QueryInner = 'SELECT DISTINCT 
    [Major]=summary.Major
    ,[Topic Code]=RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline)-1))
    ,[Topic Name]=REPLACE (summary.ContentOutline,RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline))),'''')
    ,[Brand]=summary.BrandName
    ,[Associate Code]=summary.AssociateCode
    ,[Associate Name]=UPPER(summary.AssociateName)
    ,[Family Count]=CONVERT(VARCHAR,COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))
    ,[AVG '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0)))
    ,[A '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] >= 90 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[A- '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 90 AND summary.['+@GalaxyIngredient+'] >= 85 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B+ '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 85 AND summary.['+@GalaxyIngredient+'] >= 80 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 80 AND summary.['+@GalaxyIngredient+'] >= 75 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B- '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 75 AND summary.['+@GalaxyIngredient+'] >= 70 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[C '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 70 AND summary.['+@GalaxyIngredient+'] >= 65 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[D '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 65 AND summary.['+@GalaxyIngredient+'] >= 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[E '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[AVG '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0)))
    ,[A '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] >= 90 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[A- '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 90 AND summary.['+@GalaxyIngredient2+'] >= 85 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B+ '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 85 AND summary.['+@GalaxyIngredient2+'] >= 80 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 80 AND summary.['+@GalaxyIngredient2+'] >= 75 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B- '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 75 AND summary.['+@GalaxyIngredient2+'] >= 70 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[C '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 70 AND summary.['+@GalaxyIngredient2+'] >= 65 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[D '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 65 AND summary.['+@GalaxyIngredient2+'] >= 50 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[E '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient2+'] < 50 THEN summary.['+@GalaxyIngredient2+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[OrderKey]=2
FROM ('+@QueryBranch+') summary
    JOIN DeepSeaKingdom.WE.FamilyPresenceSummary Presence ON Presence.TopicName=summary.TopicName
        AND Presence.BrandName=summary.BrandName
        AND Presence.MemberNumber=summary.MemberNumber
WHERE LEFT(summary.MemberNumber,2) > ''17''
    /*AND summary.BrandName NOT LIKE ''L%''*/
ORDER BY [OrderKey],1,2,4,5,3,7'
;------------------------------
SET @QueryOut = @QueryHeader+' UNION '+@QueryInner
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut, CHAR(13), ''), CHAR(10), ''), CHAR(9), ' ')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '( ', '('), ' )', ')')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, ', ', ','), ' ,', ',')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '> ', '>'), ' >', '>')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '< ', '<'), ' <', '<')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '= ', '='), ' =', '=')
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut,' ','\/'),'/\',''),'\/',' ')
SET @bcpCommand = 'bcp "'+@QueryOut+'" queryout "'
SET @bcpCommand = @bcpCommand + @FileName + '" -T -t , -c'
PRINT 'Baru - Venture AND REPORT Epitome ['+@Term+'] Length ::'+CONVERT(VARCHAR,LEN(@bcpCommand))
IF LEN(@bcpCommand) >= 7950 EXECUTE (@QueryInner)
ELSE EXEC master.dbo.xp_cmdshell @bcpCommand
;----------------------------------------------------------------------
/*
 * Sistem PeMarkan Lama
 * PRACTICUM Epitome
*/
SET @GalaxyIngredient = 'TotalMark'
SET @GalaxyIngredient2 = 'Responsibility'
DECLARE @GalaxyIngredient3 NVARCHAR(MAX) = 'Venture', @GalaxyIngredient4 NVARCHAR(MAX) = 'FinalTerm'
SET @FileName = REPLACE('D:\Overview PeMarkan Lama - PRACTICUM Epitome ['+@Term+'] '+CONVERT(VARCHAR,GETDATE(),105)+'.csv','/','-')
;------------------------------
    /*,[PresencePercentageOld]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,SUM(Presence.TotalPresent) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, SUM(Presence.MeetingCount) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/
    /*,[PresencePercentageNew]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,SUM(Presence.MeetingCount-Presence.TotalAbsent) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, SUM(Presence.MeetingCount) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/
SET @QueryBranch = 'SELECT DISTINCT
        [ContentOutline]=(CASE WHEN s.ContentOutline <> s.TopicName THEN s.ContentOutline+''*'' ELSE s.ContentOutline END)
        ,[TopicName]=s.TopicName
        ,[AssociateCode]=s.AssociateCode
        ,[AssociateName]=s.AssociateName
        ,[MemberNumber]=s.MemberNumber
        ,[MemberName]=s.MemberName
        ,[BrandName]=s.BrandName
        ,['+@GalaxyIngredient+']=s.['+@GalaxyIngredient+']
        ,['+@GalaxyIngredient2+']=s.['+@GalaxyIngredient2+']
        ,['+@GalaxyIngredient3+']=s.['+@GalaxyIngredient3+']
        ,['+@GalaxyIngredient4+']=s.['+@GalaxyIngredient4+']
        ,[Major]=AS_Topic.Department
    FROM DeepSeaKingdom.WE.FamilyMarkSummary s
        JOIN OPENQUERY('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') AS_Topic ON LEFT(AS_Topic.ContentName,CHARINDEX(''-'',AS_Topic.ContentName)-1)=LEFT(s.ContentOutline,CHARINDEX(''-'',s.ContentOutline)-1)
            AND AS_Topic.TopicName=s.TopicName
            AND s.Term = '''+@Term+'''
    WHERE s.['+@GalaxyIngredient+'] <> ''-''
        AND (ISNUMERIC(s.['+@GalaxyIngredient+']) = 1
        AND s.WorkshopName='''+@WorkshopName+''''
SET @QueryHeader = 'SELECT DISTINCT [Major]=''Major'',[Topic Code]=''Topic Code'',[Topic Name]=''Topic Name'',[Brand]=''Brand'',[Associate Code]=''Associate Code'',[Associate Name]=''Associate Name'',[Family Count]=''Family Count'',[AVG '+@GalaxyIngredient2+']=''AVG '+@GalaxyIngredient2+''',[AVG '+@GalaxyIngredient3+']=''AVG '+@GalaxyIngredient3+''',[AVG '+@GalaxyIngredient4+']=''AVG '+@GalaxyIngredient4+''',[AVG '+@GalaxyIngredient+']=''AVG '+@GalaxyIngredient+''',[A '+@GalaxyIngredient+']=''A '+@GalaxyIngredient+''',[B '+@GalaxyIngredient+']=''B '+@GalaxyIngredient+''',[C '+@GalaxyIngredient+']=''C '+@GalaxyIngredient+''',[D '+@GalaxyIngredient+']=''D '+@GalaxyIngredient+''',[E '+@GalaxyIngredient+']=''E '+@GalaxyIngredient+''',[Presence Percentage]=''Presence Percentage'',[OrderKey]=1' 
SET @QueryInner = 'SELECT DISTINCT
    [Major]=summary.Major
    ,[Topic Code]=RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline)-1))
    ,[Topic Name]=REPLACE (summary.ContentOutline,RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline))),'''')
    ,[Brand]=summary.BrandName
    ,[Associate Code]=summary.AssociateCode
    ,[Associate Name]=UPPER(summary.AssociateName)
    ,[Family Count]=CONVERT(VARCHAR,COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))
    ,[AVG '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'', CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0)))
    ,[AVG '+@GalaxyIngredient3+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient3+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient3+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'', CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient3+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient3+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0)))
    ,[AVG '+@GalaxyIngredient4+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient4+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient4+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'', CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient4+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient4+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0)))
    ,[AVG '+@GalaxyIngredient+']=CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0))
    ,[A '+@GalaxyIngredient+']=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] >= 85 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[B '+@GalaxyIngredient+']=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 85 AND summary.['+@GalaxyIngredient+'] >= 75 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[C '+@GalaxyIngredient+']=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 75 AND summary.['+@GalaxyIngredient+'] >= 65 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[D '+@GalaxyIngredient+']=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 65 AND summary.['+@GalaxyIngredient+'] >= 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[E '+@GalaxyIngredient+']=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[Presence Percentage]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,SUM(Presence.MeetingCount-Presence.TotalAbsent) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, SUM(Presence.MeetingCount) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''
    ,[OrderKey]=2
FROM ('+@QueryBranch+')) summary
    JOIN DeepSeaKingdom.WE.FamilyPresenceSummary Presence ON Presence.TopicName=summary.TopicName
        AND Presence.BrandName=summary.BrandName
        AND Presence.MemberNumber=summary.MemberNumber 
WHERE LEFT(summary.MemberNumber,2) < ''18''
    /*AND summary.BrandName NOT LIKE ''L%''*/
ORDER BY [OrderKey],1,2,4,5,3,7'
;------------------------------
SET @QueryOut = @QueryHeader+' UNION '+@QueryInner
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut, CHAR(13), ''), CHAR(10), ''), CHAR(9), ' ')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '( ', '('), ' )', ')')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, ', ', ','), ' ,', ',')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '> ', '>'), ' >', '>')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '< ', '<'), ' <', '<')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '= ', '='), ' =', '=')
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut,' ','\/'),'/\',''),'\/',' ')
SET @bcpCommand = 'bcp "'+@QueryOut+'" queryout "'
SET @bcpCommand = @bcpCommand + @FileName + '" -T -t , -c'
PRINT 'Lama - PRACTICUM Epitome ['+@Term+'] Length ::'+CONVERT(VARCHAR,LEN(@bcpCommand))
IF LEN(@bcpCommand) >= 7950 EXECUTE (@QueryInner)
ELSE EXEC master.dbo.xp_cmdshell @bcpCommand
;----------------------------------------------------------------------
/*
 * Sistem PeMarkan Baru
 * PRACTICUM Epitome
*/
SET @FileName = REPLACE('D:\Overview PeMarkan Baru - PRACTICUM Epitome ['+@Term+'] '+CONVERT(VARCHAR,GETDATE(),105)+'.csv','/','-')
;------------------------------
    /*,[PresencePercentageOld]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,SUM(Presence.TotalPresent) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, SUM(Presence.MeetingCount) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/
    /*,[PresencePercentageNew]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,SUM(Presence.MeetingCount-Presence.TotalAbsent) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, SUM(Presence.MeetingCount) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/
SET @QueryHeader = 'SELECT DISTINCT [Major]=''Major'',[Topic Code]=''Topic Code'',[Topic Name]=''Topic Name'',[Brand]=''Brand'',[Associate Code]=''Associate Code'',[Associate Name]=''Associate Name'',[Family Count]=''Family Count'',[AVG '+@GalaxyIngredient2+']=''AVG '+@GalaxyIngredient2+''',[AVG '+@GalaxyIngredient3+']=''AVG '+@GalaxyIngredient3+''',[AVG '+@GalaxyIngredient4+']=''AVG '+@GalaxyIngredient4+''',[AVG '+@GalaxyIngredient+']=''AVG '+@GalaxyIngredient+''',[A '+@GalaxyIngredient+']=''A '+@GalaxyIngredient+''',[A- '+@GalaxyIngredient+']=''A- '+@GalaxyIngredient+''',[B+ '+@GalaxyIngredient+']=''B+ '+@GalaxyIngredient+''',[B '+@GalaxyIngredient+']=''B '+@GalaxyIngredient+''',[B- '+@GalaxyIngredient+']=''B- '+@GalaxyIngredient+''',[C '+@GalaxyIngredient+']=''C '+@GalaxyIngredient+''',[D '+@GalaxyIngredient+']=''D '+@GalaxyIngredient+''',[E '+@GalaxyIngredient+']=''E '+@GalaxyIngredient+''',[Presence Percentage]=''Presence Percentage'',[OrderKey]=1' 
SET @QueryInner = 'SELECT DISTINCT
    [Major]=summary.Major
    ,[Topic Code]=RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline)-1))
    ,[Topic Name]=REPLACE (summary.ContentOutline,RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline))),'''')
    ,[Brand]=summary.BrandName
    ,[Associate Code]=summary.AssociateCode
    ,[Associate Name]=UPPER(summary.AssociateName)
    ,[Family Count]=CONVERT(VARCHAR,COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))
    ,[AVG '+@GalaxyIngredient2+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'', CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient2+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient2+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0)))
    ,[AVG '+@GalaxyIngredient3+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient3+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient3+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'', CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient3+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient3+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0)))
    ,[AVG '+@GalaxyIngredient4+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient4+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient4+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL, ''-'', CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient4+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient4+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0)))
    ,[AVG '+@GalaxyIngredient+']=CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0))
    ,[A '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] >= 90 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[A- '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 90 AND summary.['+@GalaxyIngredient+'] >= 85 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B+ '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 85 AND summary.['+@GalaxyIngredient+'] >= 80 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 80 AND summary.['+@GalaxyIngredient+'] >= 75 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[B- '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 75 AND summary.['+@GalaxyIngredient+'] >= 70 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[C '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 70 AND summary.['+@GalaxyIngredient+'] >= 65 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[D '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 65 AND summary.['+@GalaxyIngredient+'] >= 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[E '+@GalaxyIngredient+']=IIF(AVG(CAST((CASE WHEN summary.['+@GalaxyIngredient+']=''-'' THEN NULL ELSE summary.['+@GalaxyIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) IS NULL,''-'',CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@GalaxyIngredient+'] < 50 THEN summary.['+@GalaxyIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%'')
    ,[Presence Percentage]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,SUM(Presence.MeetingCount-Presence.TotalAbsent) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, SUM(Presence.MeetingCount) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''
    ,[OrderKey]=2
FROM ('+@QueryBranch+')) summary
    JOIN DeepSeaKingdom.WE.FamilyPresenceSummary Presence ON Presence.TopicName=summary.TopicName
        AND Presence.BrandName=summary.BrandName
        AND Presence.MemberNumber=summary.MemberNumber 
WHERE LEFT(summary.MemberNumber,2) > ''17''
    /*AND summary.BrandName NOT LIKE ''L%''*/
ORDER BY [OrderKey],1,2,4,5,3,7'
;------------------------------
SET @QueryOut = @QueryHeader+' UNION '+@QueryInner
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut, CHAR(13), ''), CHAR(10), ''), CHAR(9), ' ')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '( ', '('), ' )', ')')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, ', ', ','), ' ,', ',')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '> ', '>'), ' >', '>')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '< ', '<'), ' <', '<')
SET @QueryOut = REPLACE(REPLACE(@QueryOut, '= ', '='), ' =', '=')
SET @QueryOut = REPLACE(REPLACE(REPLACE(@QueryOut,' ','\/'),'/\',''),'\/',' ')
SET @bcpCommand = 'bcp "'+@QueryOut+'" queryout "'
SET @bcpCommand = @bcpCommand + @FileName + '" -T -t , -c'
PRINT 'Baru - PRACTICUM Epitome ['+@Term+'] Length ::'+CONVERT(VARCHAR,LEN(@bcpCommand))
IF LEN(@bcpCommand) >= 7950 EXECUTE (@QueryInner)
ELSE EXEC master.dbo.xp_cmdshell @bcpCommand
;----------------------------------------------------------------------
--IF OBJECT_ID('tempdb.dbo.##PresenceLimit', 'U') IS NOT NULL DROP TABLE ##PresenceLimit;
--IF OBJECT_ID('tempdb.dbo.##OnsiteTestPresenceVerification', 'U') IS NOT NULL DROP TABLE ##OnsiteTestPresenceVerification;
;----------------------------------------------------------------------
END