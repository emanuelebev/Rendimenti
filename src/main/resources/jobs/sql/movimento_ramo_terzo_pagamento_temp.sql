DECLARE

I 				NUMBER(38,0):=0;
CHECK_TBL		NUMBER(38,0):=0;



BEGIN

SELECT COUNT(*) INTO CHECK_TBL FROM ALL_TABLES WHERE UPPER(TABLE_NAME)=UPPER('TEMP_MOV_PAG_FONDO') AND OWNER='RENDIMPC';

	IF (CHECK_TBL = 1) THEN
		EXECUTE IMMEDIATE 'DROP TABLE RENDIMPC.TEMP_MOV_PAG_FONDO';
        
        EXECUTE IMMEDIATE 'CREATE TABLE RENDIMPC.TEMP_MOV_PAG_FONDO(	RAMO 							VARCHAR2(255), 
																	CODICE_PRODOTTO 				VARCHAR2(255), 
																	NUMERO_POLIZZA 					VARCHAR2(255), 
																	DATA_COMUNICAZIONE_PAGAMENTO 	VARCHAR2(255), 
																	CF_BENEFICIARIO 				VARCHAR2(255), 
																	MODALITA_PAGAMENTO 				VARCHAR2(255), 
																	CODICE_FONDO 					VARCHAR2(255), 
																	TIPOLOGIA_LIQUIDAZIONE 			VARCHAR2(255), 
																	ISIN 							VARCHAR2(255), 
																	QUOTE 							FLOAT(126), 
																	NAV 							FLOAT(126), 
																	IMPORTO 						FLOAT(126), 
																	DATA_NAV 						VARCHAR2(255), 
																	CODICE_ATTIVITA 				VARCHAR2(255), 
																	PROVVIGIONI_INTERMEDIARIO 		FLOAT(126), 
																	COSTO_ETF 						FLOAT(126), 
																	COMMISSIONI_DI_GESTIONE 		FLOAT(126), 
																	NUMERO_PRATICA 					VARCHAR2(255)
																   ) ';		
	
	        COMMIT;
    
    ELSE
    
        EXECUTE IMMEDIATE 'CREATE TABLE RENDIMPC.TEMP_MOV_PAG_FONDO(	RAMO 							VARCHAR2(255), 
																	CODICE_PRODOTTO 				VARCHAR2(255), 
																	NUMERO_POLIZZA 					VARCHAR2(255), 
																	DATA_COMUNICAZIONE_PAGAMENTO 	VARCHAR2(255), 
																	CF_BENEFICIARIO 				VARCHAR2(255), 
																	MODALITA_PAGAMENTO 				VARCHAR2(255), 
																	CODICE_FONDO 					VARCHAR2(255), 
																	TIPOLOGIA_LIQUIDAZIONE 			VARCHAR2(255), 
																	ISIN 							VARCHAR2(255), 
																	QUOTE 							FLOAT(126), 
																	NAV 							FLOAT(126), 
																	IMPORTO 						FLOAT(126), 
																	DATA_NAV 						VARCHAR2(255), 
																	CODICE_ATTIVITA 				VARCHAR2(255), 
																	PROVVIGIONI_INTERMEDIARIO 		FLOAT(126), 
																	COSTO_ETF 						FLOAT(126), 
																	COMMISSIONI_DI_GESTIONE 		FLOAT(126), 
																	NUMERO_PRATICA 					VARCHAR2(255)
																   ) ';		
	
	        COMMIT;
	END IF;

		
END;	