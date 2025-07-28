CREATE OR REPLACE FUNCTION PARALLEL_COSTI_MOV_POL (
	COSTI_MOV_POL IN SYS_REFCURSOR
) 
RETURN PARALLEL_FUNCTION
PARALLEL_ENABLE (PARTITION COSTI_MOV_POL BY ANY)
PIPELINED
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    
     TYPE COSTI_MOV_POL_TYPE_CUR IS RECORD (
        							
CODICE_BANCA       			VARCHAR2(5),   
CODICE_COSTO      			VARCHAR2(256), 
IDRAPPORTO         			NUMBER,        
NUMREG            			VARCHAR2(256), 
IMPORTO                     FLOAT(126),    
TIPO_FONTE                  VARCHAR2(50),  
DATA_DA                     NUMBER,        
DATA_A                      NUMBER,  
DATA_AGGIORNAMENTO          DATE,         
SSA                         VARCHAR2(8)   
 
);    
         		
	          		
TYPE COSTI_MOV_POL_TYPE IS TABLE OF COSTI_MOV_POL_TYPE_cur;

RES_COSTI_MOV_POL COSTI_MOV_POL_TYPE;
	
ROWS    PLS_INTEGER := 10000;	
I 		NUMBER(38,0):=0;


			
BEGIN
							
		LOOP
			FETCH COSTI_MOV_POL BULK COLLECT INTO RES_COSTI_MOV_POL LIMIT ROWS;
             	EXIT WHEN RES_COSTI_MOV_POL.COUNT = 0;  
			
			I:=0;
			I:= RES_COSTI_MOV_POL.COUNT;
				
			FORALL J IN RES_COSTI_MOV_POL.FIRST .. RES_COSTI_MOV_POL.LAST	
			
		MERGE INTO COSTO_MOVIMENTO CMOV
		  USING (SELECT RES_COSTI_MOV_POL(j).codice_banca 		as codice_banca,
						RES_COSTI_MOV_POL(j).codice_costo 		as codice_costo,
						RES_COSTI_MOV_POL(j).idrapporto 		as idrapporto,
						RES_COSTI_MOV_POL(j).numreg 			as numreg,
						RES_COSTI_MOV_POL(j).importo 			as importo,
					  	RES_COSTI_MOV_POL(j).tipo_fonte 		as tipo_fonte,
					  	RES_COSTI_MOV_POL(j).data_da 			as data_da,
					  	RES_COSTI_MOV_POL(j).data_a 			as data_a,
					  	RES_COSTI_MOV_POL(j).ssa 				as ssa,
					  	RES_COSTI_MOV_POL(j).data_aggiornamento as data_aggiornamento
				FROM dual
			) tomerge
			  ON
			  (CMOV.idrapporto = TOMERGE.idrapporto
			   AND CMOV.numreg = TOMERGE.numreg
			   AND CMOV.codice_costo = TOMERGE.codice_costo) 

		 WHEN MATCHED THEN UPDATE
	  SET  	
	  	CMOV.importo = TOMERGE.importo,
	  	CMOV.tipo_fonte = TOMERGE.tipo_fonte,
	  	CMOV.data_da = TOMERGE.data_da,
	  	CMOV.data_a = TOMERGE.data_a,
	  	CMOV.ssa = TOMERGE.ssa,
	  	CMOV.data_aggiornamento = TOMERGE.data_aggiornamento
	  	
	  	WHEN NOT MATCHED THEN
	  INSERT
	    (	codice_banca,
		  	codice_costo,
		  	idrapporto,
		  	numreg,
		  	importo,
		  	tipo_fonte,
		  	data_da,
		  	data_a,
		  	ssa,
		  	data_aggiornamento
		 )
	  VALUES 
	  (	  	TOMERGE.codice_banca,
		  	TOMERGE.codice_costo,
		  	TOMERGE.idrapporto,
		  	TOMERGE.numreg,
		  	TOMERGE.importo,
		  	TOMERGE.tipo_fonte,
		  	TOMERGE.data_da,
		  	TOMERGE.data_a,
		  	TOMERGE.ssa,
		  	TOMERGE.data_aggiornamento
		);
					
		INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE COSTO_MOVIMENTO POLIZZE - COMMIT ON ROW: '|| I);
		COMMIT;
	
	END LOOP;
	
    PIPE ROW(i);
	RETURN;
END;