USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_ExportOverviewReportLovelySiteIngredient](
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
DECLARE @QuarterSessionId NVARCHAR(MAX), @WorkshopId NVARCHAR(MAX), @LovelySiteIngredient NVARCHAR(MAX), @QueryInner NVARCHAR(MAX), @QueryHeader NVARCHAR(MAX), @QueryBranch NVARCHAR(MAX), @QueryOut NVARCHAR(MAX), @FileName VARCHAR(MAX), @bcpCommand VARCHAR(8000), @LovelySiteIngredientList NVARCHAR(MAX), @OpenQuery NVARCHAR(MAX), @LinkedServer NVARCHAR(MAX) = N'[LocalDB]'
;------------------------------
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
;----------------------------------------------------------------------
DECLARE LovelySiteIngredient_Cursor CURSOR FOR
SELECT DISTINCT mmd.LovelySiteIngredient FROM DeepSeaKingdom.dbo.ManualBranchDescription mmd WHERE mmd.WorkshopName = @WorkshopName AND mmd.Term = @Term
;------------------------------
SELECT DISTINCT @LovelySiteIngredientList = STUFF((SELECT DISTINCT ',[' + mmd.LovelySiteIngredient+']' FROM DeepSeaKingdom.dbo.ManualBranchDescription mmd WHERE mmd.WorkshopName = @WorkshopName AND mmd.Term = @Term FOR XML PATH('')),1,1,'')
;------------------------------
SET @OpenQuery = 'SELECT DISTINCT Topics.Name TopicName, co.Name ContentName, d.dept Department FROM Galaxy.dbo.BrandBusinesss ct JOIN Galaxy.dbo.Topics ON ct.TopicId = Topics.TopicId JOIN Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = Topics.ContentOutlineId JOIN (SELECT DISTINCT sub.Name [Topic], cou.Name [Content], dep.Name [Dept] FROM Galaxy.dbo.Topics sub JOIN Galaxy.dbo.ContentOutlines cou ON sub.ContentOutlineId = cou.ContentOutlineId AND sub.Name = cou.Name JOIN Galaxy.dbo.Departments dep ON dep.DepartmentId = sub.DepartmentId) d ON d.Content = co.Name WHERE ct.QuarterSessionId LIKE ''%'+@QuarterSessionId+'%'' AND NOT EXISTS(SELECT NULL FROM Galaxy.dbo.DeletedItems di WHERE di.DataId = ct.BrandBusinessId)'
;----------------------------------------------------------------------
OPEN LovelySiteIngredient_Cursor
    FETCH NEXT FROM LovelySiteIngredient_Cursor INTO @LovelySiteIngredient
    WHILE @@FETCH_STATUS = 0   
    BEGIN
        --
        /*
         * Sistem PeMarkan Lama
         * [LAB: Ingredient]
        */
        SET @QueryBranch = 'SELECT DISTINCT
                [ContentOutline]=(CASE WHEN s.ContentOutline <> s.TopicName THEN s.ContentOutline+''*'' ELSE s.ContentOutline END)
                ,[TopicName]=s.TopicName
                ,[AssociateCode]=s.AssociateCode
                ,[AssociateName]=s.AssociateName
                ,[MemberNumber]=s.MemberNumber
                ,[MemberName]=s.MemberName
                ,[BrandName]=s.BrandName
                ,['+@LovelySiteIngredient+']=s.['+@LovelySiteIngredient+']
                ,[Major]=AS_Topic.Department
                ,s.isMidOrFInal
            FROM (SELECT DISTINCT pvt.*
                FROM (
                    SELECT DISTINCT unpvt.House, unpvt.ContentOutline, unpvt.TopicName, unpvt.BrandName, unpvt.AssociateCode, unpvt.AssociateName, unpvt.MemberNumber, unpvt.MemberName, unpvt.TotalMark, unpvt.Mark, mmd.LovelySiteIngredient,[isMidOrFInal] = IIF(unpvt.Type IN (''MidTerm'',''FinalTerm''), NULL, ''-'')  
                    FROM (SELECT * FROM DeepSeaKingdom.WE.FamilyMarkSummary s WHERE s.WorkshopName='''+@WorkshopName+''' AND s.Term = '''+@Term+''') p UNPIVOT([Mark] FOR [Type] IN ([Responsibility],[Venture],[MidTerm],[FinalTerm])) AS unpvt 
                        LEFT JOIN DeepSeaKingdom.dbo.ManualBranchDescription mmd ON mmd.ContentCode=LEFT(unpvt.ContentOutline,CHARINDEX(''-'',unpvt.ContentOutline)-1) 
                            AND mmd.GalaxyIngredient=unpvt.Type 
                    WHERE unpvt.Mark <> ''-'' 
                        AND ISNUMERIC(unpvt.Mark) = 1) p 
                    PIVOT(MAX(p.Mark) FOR p.LovelySiteIngredient IN ('+@LovelySiteIngredientList+')) AS pvt) s
                JOIN OPENQUERY('+@LinkedServer+','''+REPLACE(@OpenQuery,'''','''''')+''') AS_Topic ON LEFT(AS_Topic.ContentName,CHARINDEX(''-'',AS_Topic.ContentName)-1)=LEFT(s.ContentOutline,CHARINDEX(''-'',s.ContentOutline)-1)
                    AND AS_Topic.TopicName=s.TopicName'
        ;------------------------------
        SET @FileName = REPLACE('D:\Overview PeMarkan Lama - '+RIGHT(@LovelySiteIngredient,LEN(@LovelySiteIngredient)-(CHARINDEX(':',@LovelySiteIngredient)+1))+' ['+@Term+'] '+CONVERT(VARCHAR,GETDATE(),105)+'.csv','/','-')
        SET @QueryHeader = 'SELECT DISTINCT [Major]=''Major'',[Topic Code]=''Topic Code'',[Topic Name]=''Topic Name'',[Brand]=''Brand'',[Associate Code]=''Associate Code'',[Associate Name]=''Associate Name'',[Family Count]=''Family Count'',[AVG '+RIGHT(@LovelySiteIngredient,LEN(@LovelySiteIngredient)-(CHARINDEX(':',@LovelySiteIngredient)+1))+']=''AVG '+RIGHT(@LovelySiteIngredient,LEN(@LovelySiteIngredient)-(CHARINDEX(':',@LovelySiteIngredient)+1))+''',[A]=''A'',[B]=''B'',[C]=''C'',[D]=''D'',[E]=''E'',[Absent]=''Absent'',[OrderKey]=1'
        SET @QueryInner = 'SELECT DISTINCT 
    [Major]=summary.Major
    ,[Topic Code]=RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline)-1))
    ,[Topic Name]=REPLACE (summary.ContentOutline,RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline))),'''')
    ,[Brand]=summary.BrandName
    ,[Associate Code]=summary.AssociateCode
    ,[Associate Name]=UPPER(summary.AssociateName)
    ,[Family Count]=CONVERT(VARCHAR,COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))
    ,[AVG '+RIGHT(@LovelySiteIngredient,LEN(@LovelySiteIngredient)-(CHARINDEX(':',@LovelySiteIngredient)+1))+']=CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@LovelySiteIngredient+']=''-'' THEN NULL ELSE summary.['+@LovelySiteIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0))
    ,[A]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] >= 85 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[B]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 85 AND summary.['+@LovelySiteIngredient+'] >= 75 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[C]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 75 AND summary.['+@LovelySiteIngredient+'] >= 65 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[D]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 65 AND summary.['+@LovelySiteIngredient+'] >= 50 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[E]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 50 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    /*,[AbsentPracticumOld]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(Presence.MeetingCount-COALESCE(al.MaximumAbsence, IIF(Presence.MeetingCount>6,2,1))>Presence.TotalPresent, 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/ 
    /*,[AbsentPracticumNew]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(Presence.TotalAbsent>COALESCE(al.MaximumAbsence,IIF(Presence.MeetingCount>6,2,1)), 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/ 
    /*,[AbsentFinalOrMidGalaxy]=COALESCE(summary.isMidOrFInal,CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(eav.FamilyStatus NOT IN (''Present''), 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0)))+IIF(summary.isMidOrFInal=''-'','''',''%'')*/
    ,[AbsentFinalOrMidAtlantis]=COALESCE(summary.isMidOrFInal,CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(mss.Status NOT IN (''Present''), 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0)))+IIF(summary.isMidOrFInal=''-'','''',''%'')
    ,[OrderKey]=2
FROM ('+@QueryBranch+') summary
    JOIN DeepSeaKingdom.WE.FamilyPresenceSummary Presence ON Presence.TopicName=summary.TopicName
        AND Presence.BrandName=summary.BrandName
        AND Presence.MemberNumber=summary.MemberNumber
    LEFT JOIN DeepSeaKingdom.dbo.ManualMarkSummary mss ON mss.TopicName=summary.TopicName
        AND mss.BrandName=summary.BrandName
        AND mss.MemberNumber=summary.MemberNumber
        AND mss.Term='''+@Term+'''
        AND mss.LovelySiteIngredient='''+@LovelySiteIngredient+'''
    /*LEFT JOIN ##PresenceLimit al ON al.QuarterSessionId = Presence.QuarterSessionId
        AND al.ContentOutlineId = Presence.ContentOutlineId
    LEFT JOIN ##OnsiteTestPresenceVerification eav ON eav.Topic = Presence.TopicName
        AND eav.QuarterSessionId = Presence.QuarterSessionId
        AND eav.FamilyMemberNumber = Presence.MemberNumber
        AND EXISTS (SELECT NULL FROM ##OnsiteTestPresenceVerification eav2 WHERE eav2.QuarterSessionId = eav.QuarterSessionId AND eav2.Topic = eav.Topic AND eav2.FamilyMemberNumber = eav.FamilyMemberNumber Batch BY eav2.QuarterSessionId, eav2.Topic, eav2.FamilyMemberNumber HAVING MAX(CONVERT(DATETIME,eav2.SavedDate)) = CONVERT(DATETIME,eav.SavedDate))*/  
WHERE LEFT(summary.MemberNumber,2) < ''18''
    /*AND summary.BrandName NOT LIKE ''L%''*/
    AND summary.['+@LovelySiteIngredient+'] IS NOT NULL 
ORDER BY [OrderKey],1,2,4,5,3,7'
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
        PRINT 'Lama - '+RIGHT(@LovelySiteIngredient,LEN(@LovelySiteIngredient)-(CHARINDEX(':',@LovelySiteIngredient)+1))+' ['+@Term+'] Length ::'+CONVERT(VARCHAR,LEN(@bcpCommand))
        IF LEN(@bcpCommand) >= 7950 EXECUTE (@QueryInner)
        ELSE EXEC master.dbo.xp_cmdshell @bcpCommand
;----------------------------------------------------------------------------------------------------
        /*
         * Sistem PeMarkan Baru
         * [LAB: Ingredient]
        */
        SET @FileName = REPLACE('D:\Overview PeMarkan Baru - '+RIGHT(@LovelySiteIngredient,LEN(@LovelySiteIngredient)-(CHARINDEX(':',@LovelySiteIngredient)+1))+' ['+@Term+'] '+CONVERT(VARCHAR,GETDATE(),105)+'.csv','/','-')
        SET @QueryHeader = 'SELECT DISTINCT [Major]=''Major'',[Topic Code]=''Topic Code'',[Topic Name]=''Topic Name'',[Brand]=''Brand'',[Associate Code]=''Associate Code'',[Associate Name]=''Associate Name'',[Family Count]=''Family Count'',[AVG '+RIGHT(@LovelySiteIngredient,LEN(@LovelySiteIngredient)-(CHARINDEX(':',@LovelySiteIngredient)+1))+']=''AVG '+RIGHT(@LovelySiteIngredient,LEN(@LovelySiteIngredient)-(CHARINDEX(':',@LovelySiteIngredient)+1))+''',[A]=''A'',[A-]=''A-'',[B+]=''B+'',[B]=''B'',[B-]=''B-'',[C]=''C'',[D]=''D'',[E]=''E'',[Absent]=''Absent'',[OrderKey]=1'
        SET @QueryInner = 'SELECT DISTINCT 
    [Major]=summary.Major
    ,[Topic Code]=RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline)-1))
    ,[Topic Name]=REPLACE (summary.ContentOutline,RTRIM(LEFT(summary.ContentOutline,CHARINDEX(''-'',summary.ContentOutline))),'''')
    ,[Brand]=summary.BrandName
    ,[Associate Code]=summary.AssociateCode
    ,[Associate Name]=UPPER(summary.AssociateName)
    ,[Family Count]=CONVERT(VARCHAR,COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))
    ,[AVG '+RIGHT(@LovelySiteIngredient,LEN(@LovelySiteIngredient)-(CHARINDEX(':',@LovelySiteIngredient)+1))+']=CONVERT(VARCHAR,ROUND(AVG(CAST((CASE WHEN summary.['+@LovelySiteIngredient+']=''-'' THEN NULL ELSE summary.['+@LovelySiteIngredient+'] END) AS FLOAT)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName),0))
    ,[A]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] >= 90 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[A-]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 90 AND summary.['+@LovelySiteIngredient+'] >= 85 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[B+]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 85 AND summary.['+@LovelySiteIngredient+'] >= 80 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[B]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 80 AND summary.['+@LovelySiteIngredient+'] >= 75 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[B-]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 75 AND summary.['+@LovelySiteIngredient+'] >= 70 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[C]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 70 AND summary.['+@LovelySiteIngredient+'] >= 65 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[D]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 65 AND summary.['+@LovelySiteIngredient+'] >= 50 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    ,[E]=CAST(ROUND(CAST(COUNT(CASE WHEN summary.['+@LovelySiteIngredient+'] < 50 THEN summary.['+@LovelySiteIngredient+'] ELSE NULL END) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT) / CAST(COUNT(summary.MemberNumber) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName) AS FLOAT)*100,0) AS VARCHAR)+''%''
    /*,[AbsentPracticumOld]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(Presence.MeetingCount-COALESCE(al.MaximumAbsence, IIF(Presence.MeetingCount>6,2,1))>Presence.TotalPresent, 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/ 
    /*,[AbsentPracticumNew]=CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(Presence.TotalAbsent>COALESCE(al.MaximumAbsence,IIF(Presence.MeetingCount>6,2,1)), 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0))+''%''*/ 
    /*,[AbsentFinalOrMidGalaxy]=COALESCE(summary.isMidOrFInal,CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(eav.FamilyStatus NOT IN (''Present''), 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0)))+IIF(summary.isMidOrFInal=''-'','''',''%'')*/
    ,[AbsentFinalOrMidAtlantis]=COALESCE(summary.isMidOrFInal,CONVERT(VARCHAR,ROUND(CONVERT(FLOAT,COUNT(IIF(mss.Status NOT IN (''Present''), 1, NULL)) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))/CONVERT(FLOAT, COUNT(Presence.MemberId) OVER (PARTITION BY summary.ContentOutline,summary.BrandName,summary.AssociateCode,summary.AssociateName))*100,0)))+IIF(summary.isMidOrFInal=''-'','''',''%'') 
    ,[OrderKey]=2
FROM ('+@QueryBranch+') summary
    JOIN DeepSeaKingdom.WE.FamilyPresenceSummary Presence ON Presence.TopicName=summary.TopicName
        AND Presence.BrandName=summary.BrandName
        AND Presence.MemberNumber=summary.MemberNumber
    LEFT JOIN DeepSeaKingdom.dbo.ManualMarkSummary mss ON mss.TopicName=summary.TopicName
        AND mss.BrandName=summary.BrandName
        AND mss.MemberNumber=summary.MemberNumber
        AND mss.Term='''+@Term+'''
        AND mss.LovelySiteIngredient='''+@LovelySiteIngredient+'''
    /*LEFT JOIN ##PresenceLimit al ON al.QuarterSessionId = Presence.QuarterSessionId
        AND al.ContentOutlineId = Presence.ContentOutlineId 
    LEFT JOIN ##OnsiteTestPresenceVerification eav ON eav.Topic = Presence.TopicName
        AND eav.QuarterSessionId = Presence.QuarterSessionId
        AND eav.FamilyMemberNumber = Presence.MemberNumber
        AND EXISTS (SELECT NULL FROM ##OnsiteTestPresenceVerification eav2 WHERE eav2.QuarterSessionId = eav.QuarterSessionId AND eav2.Topic = eav.Topic AND eav2.FamilyMemberNumber = eav.FamilyMemberNumber Batch BY eav2.QuarterSessionId, eav2.Topic, eav2.FamilyMemberNumber HAVING MAX(CONVERT(DATETIME,eav2.SavedDate)) = CONVERT(DATETIME,eav.SavedDate))*/ 
WHERE LEFT(summary.MemberNumber,2) > ''17''
    /*AND summary.BrandName NOT LIKE ''L%''*/
    AND summary.['+@LovelySiteIngredient+'] IS NOT NULL
ORDER BY [OrderKey],1,2,4,5,3,7'
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
        PRINT 'Baru - '+RIGHT(@LovelySiteIngredient,LEN(@LovelySiteIngredient)-(CHARINDEX(':',@LovelySiteIngredient)+1))+' ['+@Term+'] Length ::'+CONVERT(VARCHAR,LEN(@bcpCommand))
        IF LEN(@bcpCommand) >= 7950 EXECUTE (@QueryInner)
        ELSE EXEC master.dbo.xp_cmdshell @bcpCommand
        --
    FETCH NEXT FROM LovelySiteIngredient_Cursor INTO @LovelySiteIngredient
    END  
CLOSE LovelySiteIngredient_Cursor
DEALLOCATE LovelySiteIngredient_Cursor
;----------------------------------------------------------------------
--IF OBJECT_ID('tempdb.dbo.##PresenceLimit', 'U') IS NOT NULL DROP TABLE ##PresenceLimit;
--IF OBJECT_ID('tempdb.dbo.##OnsiteTestPresenceVerification', 'U') IS NOT NULL DROP TABLE ##OnsiteTestPresenceVerification;
;----------------------------------------------------------------------
END