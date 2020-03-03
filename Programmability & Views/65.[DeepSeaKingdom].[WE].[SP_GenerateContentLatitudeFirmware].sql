USE [DeepSeaKingdom]
GO
CREATE PROCEDURE [WE].[SP_GenerateContentLatitudeFirmware]
WITH RECOMPILE--, ENCRYPTION
AS
BEGIN
SET NOCOUNT ON
;----------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.##FirmwareInContentOutline', 'U') IS NOT NULL DROP TABLE ##FirmwareInContentOutline;
IF OBJECT_ID('tempdb.dbo.##FirmwareInMaster', 'U') IS NOT NULL DROP TABLE ##FirmwareInMaster;
IF OBJECT_ID('tempdb.dbo.##FirmwareContentOutline', 'U') IS NOT NULL DROP TABLE ##FirmwareContentOutline;
IF OBJECT_ID('tempdb.dbo.##FirmwareLatitude', 'U') IS NOT NULL DROP TABLE ##FirmwareLatitude;
;----------------------------------------------------------------------
DECLARE @Query NVARCHAR(MAX)
;----------------------------------------------------------------------
SET @Query = N'
SELECT DISTINCT [ContentCode] = LEFT(co.Name, CHARINDEX(''-'',co.Name)-1), [ContentName] = co.Name, sico.FirmwareName, sico.FirmwareVersion
INTO ##FirmwareInContentOutline
FROM DeepSeaKingdom.WE.V_FirmwareInContentOutline sico JOIN [LocalDB].Galaxy.dbo.ContentOutlines co ON co.ContentOutlineId = sico.ContentOutlineId'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @Query = N'
SELECT DISTINCT [House] = r.House,[LatitudeName] = r.Name, [FirmwareName] = sim.FirmwareName, [FirmwareVersion] = sim.FirmwareVersion
INTO ##FirmwareInMaster
FROM DeepSeaKingdom.WE.V_FirmwareInMaster sim 
	JOIN DeepSeaKingdom.WE.V_MasterInLatitude mir ON mir.MasterId = sim.MasterId
	JOIN [LocalDB].Galaxy.dbo.Latitudes r ON r.LatitudeId = mir.LatitudeId'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @Query = N'
SELECT DISTINCT sico.ContentCode, sico.ContentName, [Firmware] = STUFF((SELECT '';''+sico2.FirmwareName+'' ''+sico2.FirmwareVersion FROM ##FirmwareInContentOutline sico2 WHERE sico.ContentCode = sico2.ContentCode FOR XML PATH('''')),1,1,''''), [FirmwareCount] = COUNT(sico.FirmwareName) OVER (PARTITION BY sico.ContentCode, sico.ContentName)
INTO ##FirmwareContentOutline
FROM ##FirmwareInContentOutline sico'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
SET @Query = N'
SELECT sico.ContentCode, sico.ContentName, sim.House, sim.LatitudeName, sim.FirmwareName, sim.FirmwareVersion, [FirmwareCount] = COUNT(sim.FirmwareName) OVER (PARTITION BY sico.ContentCode, sico.ContentName, sim.House, sim.LatitudeName)
INTO ##FirmwareLatitude
FROM ##FirmwareInMaster sim 
	JOIN ##FirmwareInContentOutline sico ON sim.FirmwareName = sico.FirmwareName
		AND sim.FirmwareVersion = sico.FirmwareVersion'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
IF OBJECT_ID('DeepSeaKingdom.WE.ContentLatitudeFirmware', 'U') IS NOT NULL DROP TABLE DeepSeaKingdom.WE.ContentLatitudeFirmware;
;----------------------------------------------------------------------
SET @Query = N'
SELECT DISTINCT sr.ContentCode, sr.ContentName, sr.House, sr.LatitudeName, sco.Firmware, sr.FirmwareCount
INTO DeepSeaKingdom.WE.ContentLatitudeFirmware
FROM ##FirmwareLatitude sr 
	JOIN ##FirmwareContentOutline sco ON sco.ContentCode = sr.ContentCode
		AND sco.FirmwareCount = sr.FirmwareCount
ORDER BY 1, 3'
;------------------------------
EXECUTE (@Query)
;----------------------------------------------------------------------
IF OBJECT_ID('tempdb.dbo.##FirmwareInContentOutline', 'U') IS NOT NULL DROP TABLE ##FirmwareInContentOutline;
IF OBJECT_ID('tempdb.dbo.##FirmwareInMaster', 'U') IS NOT NULL DROP TABLE ##FirmwareInMaster;
IF OBJECT_ID('tempdb.dbo.##FirmwareContentOutline', 'U') IS NOT NULL DROP TABLE ##FirmwareContentOutline;
IF OBJECT_ID('tempdb.dbo.##FirmwareLatitude', 'U') IS NOT NULL DROP TABLE ##FirmwareLatitude;
;----------------------------------------------------------------------
END

