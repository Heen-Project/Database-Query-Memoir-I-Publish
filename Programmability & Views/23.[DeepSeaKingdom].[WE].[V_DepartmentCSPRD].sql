USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_DepartmentCSPRD]
--WITH ENCRYPTION
AS
SELECT DISTINCT [ACAD Batch] = d.DESCR100, [ACAD ORG] = d.DESCR100_2, [DEPARTMENT] = d.DESCR100_3, [Kelompok Rumpun] = d.DESCR100_4, [Rumpun Ilmu] = d.DESCR100_5, [ContentCode] = d.DESCR10, [ContentName] = d.Content_TITLE_LONG FROM OPENQUERY([OPRO], 'SELECT d.* FROM SYSADM.PS_N_DEPARTMENT_VW d WHERE d.Department = ''YYS01'' AND d.Position = ''RS1'' ') d