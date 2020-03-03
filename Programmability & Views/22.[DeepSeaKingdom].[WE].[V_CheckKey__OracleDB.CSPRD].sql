USE [DeepSeaKingdom]
GO
CREATE VIEW [WE].[V_CheckKey__OracleDB.CSPRD]
--WITH ENCRYPTION
AS
SELECT DISTINCT cols.table_name, cols.column_name, cols.position, cons.status, cons.owner, cons.constraint_type
FROM OPENQUERY ([OPRO],'SELECT * FROM sys.all_constraints') cons JOIN OPENQUERY ([OPRO],'SELECT * FROM sys.all_cons_columns') cols ON cons.constraint_name = cols.constraint_name
	AND cons.owner = cols.owner 
--WHERE cols.table_name LIKE '%Family_Mark%'
	--AND cons.constraint_type = 'P'
--ORDER BY cols.table_name, cols.position;