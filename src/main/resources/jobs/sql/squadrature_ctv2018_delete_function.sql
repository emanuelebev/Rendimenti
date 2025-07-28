CREATE OR REPLACE FUNCTION PARALLEL_SQCTV2018_DEL (
	squad_ctv_del IN SYS_REFCURSOR
) 
RETURN PARALLEL_FUNCTION
PARALLEL_ENABLE (PARTITION squad_ctv_del BY ANY)
PIPELINED
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    
     TYPE squad_ctv_del_TYPE_cur IS RECORD (
        							
IDPTF	NUMBER,
CODICETITOLO	VARCHAR2(255)
);  
  
  
TYPE squad_ctv_del_TYPE IS TABLE OF squad_ctv_del_TYPE_cur;

RES_squad_ctv_del squad_ctv_del_TYPE;
	
ROWS    PLS_INTEGER := 10000;
I 		NUMBER(38,0):=0;

BEGIN
							
		LOOP
			FETCH squad_ctv_del BULK COLLECT INTO RES_squad_ctv_del LIMIT ROWS;
            	EXIT WHEN RES_squad_ctv_del.COUNT = 0;  
			
			I:=0;
			I:= RES_squad_ctv_del.COUNT;
				
			FORALL J IN RES_squad_ctv_del.FIRST .. RES_squad_ctv_del.LAST	

				DELETE FROM SQUADRATURE_CTV_2018 DEL
					WHERE DEL.IDPTF = RES_squad_ctv_del(J).IDPTF
					AND DEL.CODICETITOLO = RES_squad_ctv_del(J).CODICETITOLO;
					
			INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' Squadrature CTV 2018 eliminate: ' || I || ' record'); 
		COMMIT;		        
		
	END LOOP;
	
	INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' Squadrature CTV eliminate: ' || I || ' record'); 
	COMMIT;	
	
    PIPE ROW(i);
	RETURN;
END
;