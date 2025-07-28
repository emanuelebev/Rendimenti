SELECT sum(column_value)
FROM TABLE (PARALLEL_MOVIMENTI (CURSOR (

	SELECT	/*+ PARALLEL(8) */	 
            RAPP.ID                                                                                          AS IDRAPPORTO,
            TMOV.CODICE                                                                                      AS NUMREG,
            TMOV.CAMBIO                                                                                      AS CAMBIO,
            TMOV.TIPORAPPORTO || '_' || TMOV.CAUSALE                                                         AS CAUSALE,
            CASE
            	WHEN TMOV.TIPORAPPORTO = '02' --PER I LIBRETTI IMPOSTARE FISSO A LIQ_EUR_LIB
					THEN NVL(TMOV.CODICEINTERNO,'LIQ_EUR_LIB')
				ELSE SUBSTR(TMOV.CODICEINTERNO, 2) 
			END                                                                               				 AS CODICETITOLO,
            CASE WHEN (TMOV.TIPORAPPORTO = '03' AND TMOV.CTVREGOLATO < 0) 
            			THEN (TMOV.CTVREGOLATO - TMOV.IMPOSTE - TMOV.COMMISSIONI)
            	 WHEN (TMOV.TIPORAPPORTO = '03' AND TMOV.CTVREGOLATO >= 0) 
            			THEN (TMOV.CTVREGOLATO - TMOV.IMPOSTE + TMOV.COMMISSIONI)
            	ELSE (TMOV.CTVREGOLATO)*(-1) END															 AS CTV,  	 --(PTR-277)
            CASE WHEN TMOV.TIPORAPPORTO = '03' THEN TMOV.CTVREGOLATO END  									 AS CTVORIG, --(PTR-214)
            TMOV.CTVREGOLATODIVISA                                                                           AS CTVDIVISA,
            TMOV.CTVMERCATO                                                                                  AS CTVNETTO,
			CASE 
            	WHEN TMOV.TIPORAPPORTO = '14' --PER I FONDI (PTR-176)
            		THEN TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATACONTABILE, 'YYYY-MM-DD'), 'YYYYMMDD'))
            	WHEN TMOV.TIPORAPPORTO = '97' --PER I FONDI ESTERNI (PTR-805)
            		THEN TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATACONTABILE, 'YYYY-MM-DD'), 'YYYYMMDD'))
            	WHEN TMOV.TIPORAPPORTO = '03' --PER I BFP (PTR-257)
            		THEN TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATACONTABILE, 'YYYY-MM-DD'), 'YYYYMMDD'))
            	ELSE TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATAVALUTA, 'YYYY-MM-DD'), 'YYYYMMDD')) END			 	 AS "DATA",
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATACONTABILE, 'YYYY-MM-DD'),
                              'YYYYMMDD'))                                                                   AS DATACONT,
            CASE 
            	WHEN TMOV.TIPORAPPORTO = '15' --PER BUONI/FONDI/POLIZZE È FISSA A EUR. PER TITOLI È LA DIVISA DEL PREZZO
            		THEN  (SELECT DIVISA 
            			  FROM SERIE_STORICA 
            			  WHERE CODICETITOLO = SUBSTR(TMOV.CODICEINTERNO, 2) 
            			  AND DATALIVELLO = (SELECT MAX(DATALIVELLO)
            			  			  		 FROM SERIE_STORICA 
            			  			  		 WHERE CODICETITOLO = SUBSTR(TMOV.CODICEINTERNO, 2) ))
            	ELSE 'EUR'
            END 																							 AS DIVISA,
            NULL                                                                                             AS FLAGPCT,
            TMOV.PREZZO                                                                                      AS PREZZO,
            CASE
            	WHEN TMOV.TIPORAPPORTO = '02' --PER I LIBRETTI INVECE IL CAMPO VA CARICATO CON IL CONTROVALORE REGOLATO
            		THEN TMOV.CTVREGOLATO
            	ELSE 
            		TMOV.QUANTITA
            END																								 AS QTA,
            TMOV.RATEOLORDO                                                                                  AS RATEOLORDO,
            TMOV.RATEONETTO                                                                                  AS RATEONETTO,
            TMOV.COMMISSIONI                                                                                 AS SPESECOMM,
            TMOV.IMPOSTE                                                                                     AS TASSAZIONE,
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATAVALUTA, 'YYYY-MM-DD'), 'YYYYMMDD'))                           AS VALUTA,
            TMOV.FLAGSTORNO                                                                                  AS STORNO,
            TMOV.CTVMERCATO                                                                                  AS CTV_MERCATO,
            TMOV.CTVMERCATODIVISA                                                                            AS CTV_MERCATO_DIVISA,
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATACONTABILE, 'YYYY-MM-DD'),
                              'YYYYMMDD'))                                                                   AS DATA_REGISTRAZIONE,
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATAORDINE, 'YYYY-MM-DD'),
                              'YYYYMMDD'))                                                                   AS DATA_SOTTOSCRIZIONE,
            TMOV.PREZZOMERCATO                                                                               AS PREZZO_MERCATO,
            TMOV.CODICESTORNO                                                                                AS N_OPERAZIONE_STORNO,
            TMOV.FLAGCANCELLATO                                                                              AS F_CANCELLATO,
            NULL                                                                                             AS C_CANALE,
            NULL                                                                                             AS Z_CANALE,
            NULL                                                                                             AS QTA_CAPITALE,
            NULL                                                                                             AS PROVENIENZACAUSALE,
            TO_NUMBER(TO_CHAR(TO_DATE(TMOV.DATAAGGIORNAMENTO, 'YYYY-MM-DD HH24:MI:SS'),
                              'YYYYMMDDHH24MISS'))                                                           AS D_AGGIORNAMENTO,
            TMOV.TIPORAPPORTO                                                                                AS C_PROCEDURA,
            NULL                                                                                             AS BANCA_DA,
            NULL                                                                                             AS CODICEAGENZIA_DA,
            NULL                                                                                             AS CODICERAPPORTO_DA,
            NULL                                                                                             AS BANCA_A,
            NULL                                                                                             AS CODICEAGENZIA_A,
            NULL                                                                                             AS CODICERAPPORTO_A,
            RAPP.CODICEAGENZIA                                                                               AS CODICEFILIALE,
            CASE 
            	WHEN TMOV.TIPORAPPORTO = '03'
            		THEN SUBSTR(TMOV.CODICERAPPORTO, 0, INSTR(TMOV.CODICERAPPORTO, '-')-1)
            	ELSE NULL
            END 																							 AS CODICERAPPORTO_ORI,
            TMOV.CAUSALE																					 AS CAUSALE_ORI,
            NULL																							 AS FONTE,
        	TMOV.IMPOSTA_REST                                                                                AS IMPOSTA_REST
          FROM
            TMP_PFMOV_TITOLI TMOV
          INNER JOIN RAPPORTO RAPP
          	ON CASE
      		WHEN TMOV.TIPORAPPORTO = '03'
      			THEN SUBSTR(TMOV.CODICERAPPORTO, INSTR(TMOV.CODICERAPPORTO, '-')+1)
      		ELSE
      			TMOV.CODICERAPPORTO 
      		END = RAPP.CODICERAPPORTO
          	AND TMOV.CODICEBANCA = RAPP.CODICEBANCA
          	AND TMOV.TIPORAPPORTO = RAPP.TIPO
          ORDER BY  RAPP.ID, TMOV.CODICE
 )));