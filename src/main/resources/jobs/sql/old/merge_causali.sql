DECLARE 

    rowcounts NUMBER;
    
BEGIN

MERGE  INTO CAUSALE A1
	USING
	    (
	        SELECT 	tmp.TIPORAPPORTO || '_' || tmp.CODICECAUSALE    AS CODICECAUSALE,
	        		NULL											AS CAUCONTR,
					NULL 											AS DATAAGGIORNAMENTO,
					TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')) 			AS DATAINSERIMENTO,
					tmp.DESCRIZIONE      							AS DESCRIZIONE,  
					'1'												AS FLAGAGGSALDI,
					NULL											AS PROCEDURA,
					NULL											AS SEGNO,	
					'4'												AS TIPOCAUSALE,
					NULL											AS SOTL,
					tmp.CODICEBANCA      							AS CODICEBANCA,
					tmp.TIPORAPPORTO     							AS CANALE,
					tmp.TIPOLOGIACAUSALE 							AS TIPOLOGIA_CAUSALE,
					tmp.CODICECAUSALE 								AS CODICECAUSALE_ORI
	        FROM  TMP_PFCAUSALI tmp) A
	ON (A1.CODICECAUSALE= A.CODICECAUSALE)
	WHEN NOT MATCHED THEN
	INSERT
	    (
	        CODICECAUSALE,    
			CAUCONTR,         
			DATAAGGIORNAMENTO,
			DATAINSERIMENTO,  
			DESCRIZIONE,      
			FLAGAGGSALDI,     
			PROCEDURA,        
			SEGNO,            
			TIPOCAUSALE,      
			SOTL,             
			CODICEBANCA,      
			CANALE,           
			TIPOLOGIA_CAUSALE,
			CODICECAUSALE_ORI	
	    )
	    VALUES
	    (
	        A.CODICECAUSALE,    
			A.CAUCONTR,         
			A.DATAAGGIORNAMENTO,
			A.DATAINSERIMENTO,  
			A.DESCRIZIONE,      
			A.FLAGAGGSALDI,     
			A.PROCEDURA,        
			A.SEGNO,            
			A.TIPOCAUSALE,      
			A.SOTL,             
			A.CODICEBANCA,      
			A.CANALE,           
			A.TIPOLOGIA_CAUSALE,
			A.CODICECAUSALE_ORI
	    );
	    
	    rowcounts := SQL%ROWCOUNT;
	    
	   INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE CAMBI IN SERIE_STORICA: ' || rowcounts);
	COMMIT;
	
END;