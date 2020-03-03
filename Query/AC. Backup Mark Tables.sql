/******************************************************************************************
 *								Manual Backup Mark Tables
 ******************************************************************************************//*
SELECT * FROM Temporary.WE.[ManualBackup__ITDATABASE.LMS.dbo.MsMtkPraktikumHYU]
SELECT * FROM Temporary.WE.[ManualBackup__ITDATABASE.LMS.dbo.TrLabBatch]
SELECT * FROM Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.TrLabContentTypeBatch]
SELECT * FROM Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.TempMarkAkhirPrakt]
SELECT * FROM Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.Transaksi_Mark_UPTPL]
SELECT * FROM Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.Transaksi_Mark_Mahasiswa]
SELECT * FROM Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.Transaksi_IPS_IPK]
SELECT * FROM Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.Family_Mark_DTL_Shop]
SELECT * FROM Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.PS_Family_Mark_DTL_Shop]
SELECT * FROM Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.LAM_Brand_ACTV_Shop]
SELECT * FROM Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.Family_Mark_DTL]
SELECT * FROM Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.LAM_Brand_ACTV]

--TRUNCATE TABLE Temporary.WE.[ManualBackup__ITDATABASE.LMS.dbo.MsMtkPraktikumHYU]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ITDATABASE.LMS.dbo.TrLabBatch]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.TrLabContentTypeBatch]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.TempMarkAkhirPrakt]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.Transaksi_Mark_UPTPL]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.Transaksi_Mark_Mahasiswa]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.Transaksi_IPS_IPK]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.Family_Mark_DTL_Shop]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.PS_Family_Mark_DTL_Shop]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.LAM_Brand_ACTV_Shop]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.Family_Mark_DTL]
--TRUNCATE TABLE Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.LAM_Brand_ACTV]

--INSERT INTO Temporary.WE.[ManualBackup__ITDATABASE.LMS.dbo.MsMtkPraktikumHYU] SELECT * FROM [ITDATABASE].LMS.dbo.MsMtkPraktikumHYU --1684 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ITDATABASE.LMS.dbo.TrLabBatch] SELECT * FROM [ITDATABASE].LMS.dbo.TrLabBatch --52123 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.TrLabContentTypeBatch] SELECT * FROM [ITDATABASE].CRM_DEV.dbo.TrLabContentTypeBatch --2018 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.TempMarkAkhirPrakt] SELECT * FROM [ITDATABASE].CRM_DEV.dbo.TempMarkAkhirPrakt --138074 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.Transaksi_Mark_UPTPL] SELECT * FROM [ITDATABASE].CRM_DEV.dbo.Transaksi_Mark_UPTPL --677648 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.Transaksi_Mark_Mahasiswa] SELECT * FROM [ITDATABASE].CRM_DEV.dbo.Transaksi_Mark_Mahasiswa --5209366 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ITDATABASE.CRM_DEV.dbo.Transaksi_IPS_IPK] SELECT * FROM [ITDATABASE].CRM_DEV.dbo.Transaksi_IPS_IPK --1046573 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.Family_Mark_DTL_Shop] SELECT * FROM [ExternalDB].Mark_DB.dbo.Family_Mark_DTL_Shop --24753 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.PS_Family_Mark_DTL_Shop] SELECT * FROM [ExternalDB].Mark_DB.dbo.PS_Family_Mark_DTL_Shop --47390 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.LAM_Brand_ACTV_Shop] SELECT * FROM [ExternalDB].Mark_DB.dbo.LAM_Brand_ACTV_Shop --1529 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.Family_Mark_DTL] SELECT * FROM [ExternalDB].Mark_DB.dbo.Family_Mark_DTL --1742190 (03-Apr-2017)
--INSERT INTO Temporary.WE.[ManualBackup__ExternalDB.Mark_DB.dbo.LAM_Brand_ACTV] SELECT * FROM [ExternalDB].Mark_DB.dbo.LAM_Brand_ACTV --58635 (03-Apr-2017)
*/

/******************************************************************************************
 *							Manual Backup Mark Tables
 ******************************************************************************************//*
SELECT * 
--INTO Temporary.WE.[ManualBackup__DeepSeaKingdom.DeepSeaKingdom.dbo.ManualMarkSummary] --56237 (26-Apr-2017)
FROM DeepSeaKingdom.dbo.ManualMarkSummary

SELECT * 
--INTO Temporary.WE.[ManualBackup__DeepSeaKingdom.DeepSeaKingdom.dbo.ManualBranchDescription] --399 (26-Apr-2017)
FROM DeepSeaKingdom.dbo.ManualBranchDescription
*/