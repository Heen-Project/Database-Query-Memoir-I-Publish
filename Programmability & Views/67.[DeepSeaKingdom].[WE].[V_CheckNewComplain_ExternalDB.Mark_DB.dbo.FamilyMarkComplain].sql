USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_CheckNewComplain_ExternalDB.Mark_DB.dbo.FamilyComplainMark]
--WITH ENCRYPTION
AS
SELECT spn.Term,spn.DateIn,spn.DateUp,spn.PersonIn,spn.PersonUp,spn.ASCID,spn.EXTERNAL_SYSTEM_ID,spn.NAMA,spn.Term,spn.Topic,spn.CATALOG_NBR,spn.Brand_NBR,spn.Brand_SECTION,spn.Content_ID,spn.Content_ATTR_VALUE,spn.DESCR,spn.Orderline,spn.TYPE,spn.TYPE_DESCR,spn.TYPE_WEIGHT,spn.Term_DESCR,spn.Family_Mark_OLD,spn.Family_Mark_NEW,spn.ComplainDate,spn.Status,spn.id,[ExplanationFamily] = REPLACE(REPLACE(REPLACE(REPLACE(CAST(spn.ExplanationFamily as nvarchar(max)),CHAR(13),NCHAR(0x21B5)),CHAR(10),NCHAR(0x21B5)),',','.'),CHAR(9),' '),spn.Explanation,spn.Submit_Dt_ByLect,spn.POST_DT,spn.Approve_Dt_ByLect,spn.FINAL_Mark,spn.IsLab,spn.Department,spn.Position,spn.House,spn.ASCID_Associate,spn.DocumentID,spn.SchoolApprovalDate,spn.DESCRSHORT
FROM [ExternalDB].Mark_DB.dbo.FamilyComplainMark spn
WHERE (spn.ASCID_Associate = '' OR spn.ASCID_Associate = 'A0001')
	AND spn.Department = 'YYS01'
	AND spn.Position = 'RS1'
	AND spn.Term <> 'D'
	AND spn.Status = '1'