CREATE OR REPLACE FUNCTION PARALLEL_COSTI_NDG (
	COSTI_NDG IN SYS_REFCURSOR
) 
RETURN PARALLEL_FUNCTION
PARALLEL_ENABLE (PARTITION COSTI_NDG BY ANY)
PIPELINED
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    
     TYPE COSTI_NDG_TYPE_CUR IS RECORD (
        							
CODICE_BANCA       			VARCHAR2(5),   
CODICE_COSTO      			VARCHAR2(256), 
NDG							NUMBER,
IDRAPPORTO         			NUMBER,        
NUMREG            			VARCHAR2(256), 
IMPORTO                     FLOAT(126),    
TIPO_FONTE                  VARCHAR2(50),  
DATA_DA                     NUMBER,        
DATA_A                      NUMBER,  
DATA          				NUMBER
 
);    
         		
	          		
TYPE COSTI_NDG_TYPE IS TABLE OF COSTI_NDG_TYPE_cur;

RES_COSTI_NDG COSTI_NDG_TYPE;
	
ROWS    PLS_INTEGER := 10000;	
I 		NUMBER(38,0):=0;


			
BEGIN
							
		LOOP
			FETCH COSTI_NDG BULK COLLECT INTO RES_COSTI_NDG LIMIT ROWS;
             	EXIT WHEN RES_COSTI_NDG.COUNT = 0;  
			
			I:=0;
			I:= RES_COSTI_NDG.COUNT;
				
			FORALL J IN RES_COSTI_NDG.FIRST .. RES_COSTI_NDG.LAST	
			
		MERGE INTO COSTO_NDG CMOV
		  USING (SELECT RES_COSTI_NDG(j).codice_banca 		AS codice_banca,
						RES_COSTI_NDG(j).codice_costo 		AS codice_costo,
						RES_COSTI_NDG(j).ndg		 		AS ndg,
						RES_COSTI_NDG(j).idrapporto 		AS idrapporto,
						RES_COSTI_NDG(j).numreg 			AS numreg,
						RES_COSTI_NDG(j).importo 			AS importo,
					  	RES_COSTI_NDG(j).tipo_fonte 		AS tipo_fonte,
					  	RES_COSTI_NDG(j).data_da 			AS data_da,
					  	RES_COSTI_NDG(j).data_a 			AS data_a,
					  	RES_COSTI_NDG(j).data				AS data
				FROM dual
			) tomerge
			  ON
			  (CMOV.codice_banca = TOMERGE.codice_banca
			   AND CMOV.codice_costo = TOMERGE.codice_costo
			   AND CMOV.ndg = TOMERGE.ndg
			   AND CMOV.data = TOMERGE.data
			   AND CMOV.numreg = TOMERGE.numreg) 

		 WHEN MATCHED THEN UPDATE
	  SET  	
	  	CMOV.idrapporto = TOMERGE.idrapporto,
	  	CMOV.importo = TOMERGE.importo,
	  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
	  	CMOV.data_da = TOMERGE.data_da,
	  	CMOV.data_a = TOMERGE.data_a
	  	
	  	WHEN NOT MATCHED THEN
	  INSERT
	    (	codice_banca,
		  	codice_costo,
		  	ndg,
		  	idrapporto,
		  	numreg,
		  	importo,
		  	tipo_fonte,
		  	data_da,
		  	data_a,
		  	data
		 )
	  VALUES 
	  (	  	TOMERGE.codice_banca,
		  	TOMERGE.codice_costo,
		  	TOMERGE.ndg,
		  	TOMERGE.idrapporto,
		  	TOMERGE.numreg,
		  	TOMERGE.importo,
		  	TOMERGE.tipo_fonte,
		  	TOMERGE.data_da,
		  	TOMERGE.data_a,
		  	TOMERGE.data
		);
					
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTO_NDG - COMMIT ON ROW: '|| I);
		COMMIT;
	
	END LOOP;
	
    PIPE ROW(i);
	RETURN;
END;