CREATE OR REPLACE FUNCTION PARALLEL_SQUAD_QTA2018 (
	squad_qta IN SYS_REFCURSOR
) 
RETURN PARALLEL_FUNCTION
PARALLEL_ENABLE (PARTITION squad_qta BY ANY)
PIPELINED
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    
     TYPE squad_qta_TYPE_cur IS RECORD (
        							
TIPOSTRUM			VARCHAR2(255),
CODICECLIENTE		VARCHAR2(255),
CODICERAPPORTO		VARCHAR2(255),
TIPO				VARCHAR2(255),
SOTTORAPPORTO		VARCHAR2(255),
STATO				VARCHAR2(255),
IDRAPPORTO			NUMBER,
IDPTF				NUMBER,
CODICETITOLO		VARCHAR2(255),
DESCRIZIONETITOLO	VARCHAR2(255),
DATASALDO			NUMBER,
VALORESALDO			FLOAT,
SUMQTA				FLOAT,
DIFF				FLOAT,
CODICEAGENZIA		VARCHAR2(255),
CODICEBANCA			VARCHAR2(255),
DATAINS				TIMESTAMP(6),
DATAAGG				TIMESTAMP(6),
COUNTER				NUMBER
);  
  

    
TYPE squad_qta_TYPE IS TABLE OF squad_qta_TYPE_cur;

RES_squad_qta squad_qta_TYPE;
	
ROWS    PLS_INTEGER := 10000;	
I 		NUMBER(38,0):=0;

BEGIN
							
		LOOP
			FETCH squad_qta BULK COLLECT INTO RES_squad_qta LIMIT ROWS;
            	EXIT WHEN RES_squad_qta.COUNT = 0;  
			
			I:=0;
			I:= RES_squad_qta.COUNT;
				
			FORALL J IN RES_squad_qta.FIRST .. RES_squad_qta.LAST	

				MERGE INTO squadrature_2018 S
						USING
								(SELECT RES_squad_qta(j).tipostrum 						AS tipostrum,
										RES_squad_qta(j).codicecliente  				AS codicecliente,
									    RES_squad_qta(j).codicerapporto  				AS codicerapporto,
										RES_squad_qta(j).tipo 							AS tipo,
										RES_squad_qta(j).sottorapporto 					AS sottorapporto,
										RES_squad_qta(j).codicebanca					AS codicebanca,
										RES_squad_qta(j).codiceagenzia 					AS codiceagenzia,
										RES_squad_qta(j).stato 							AS stato, 
										RES_squad_qta(j).idrapporto 					AS idrapporto, 
										RES_squad_qta(j).idptf	 						AS idptf, 
										RES_squad_qta(j).codicetitolo 					AS codicetitolo, 
										RES_squad_qta(j).descrizionetitolo				AS descrizionetitolo, 
										RES_squad_qta(j).DATASALDO						AS DATASALDO,
										RES_squad_qta(j).valoresaldo  					AS valoresaldo,
										RES_squad_qta(j).sumqta 						AS sumqta,
										RES_squad_qta(j).diff 						    AS diff, 
										sysdate 										AS datains,
										sysdate 										AS dataagg,
										0												AS counter
								 FROM dual
								) A
							ON (S.idrapporto = A.idrapporto
								AND S.codicetitolo = A.codicetitolo)					
		WHEN MATCHED THEN UPDATE 
								SET S.tipostrum = A.tipostrum,
									S.codicecliente = A.codicecliente,
									S.codicerapporto = A.codicerapporto,
									S.tipo = A.tipo,
									S.sottorapporto = A.sottorapporto,
									S.codiceagenzia = A.codiceagenzia,
									S.codicebanca = A.codicebanca,
									S.stato = A.stato,
									S.idptf = A.idptf,
									S.descrizionetitolo = A.descrizionetitolo,
									S.valoresaldo = A.valoresaldo,
									S.datasaldo = A.DATASALDO,
									S.sumqta = A.sumqta,
									S.diff = A.diff,
									S.dataagg = A.dataagg,
									S.counter = EXTRACT(DAY FROM (A.dataagg - S.datains))
		WHEN NOT MATCHED THEN 
							INSERT (tipostrum,
									codicecliente,
									codicerapporto,
									tipo,
									sottorapporto,
									codicebanca,
									codiceagenzia,
									stato,
									idrapporto,
									idptf,
									descrizionetitolo,
									codicetitolo,
									datasaldo,
									valoresaldo,
									sumqta,
									diff,
									datains,
									dataagg,
									counter)
							VALUES (A.tipostrum,
									A.codicecliente,
									A.codicerapporto,
									A.tipo,
									A.sottorapporto,
									A.codicebanca,
									A.codiceagenzia,
									A.stato,
									A.idrapporto,
									A.idptf,
									A.descrizionetitolo,
									A.codicetitolo,
									A.DATASALDO,
									A.valoresaldo,
									A.sumqta,
									A.diff,
									A.datains,
									A.dataagg,
									A.counter
							);	 
                            
            INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' SQUADRATURE QTA 2018 - COMMIT ON ROW: '|| I);
		COMMIT;
	     
	END LOOP;
	
    PIPE ROW(i);
	RETURN;
END
;