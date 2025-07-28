SELECT sum(column_value)
FROM TABLE (PARALLEL_COSTI_MOV_POL (CURSOR (

          SELECT /*+ PARALLEL(8) */	  
            case when substr(TCOST.codicebanca, 1) != '0' and length(TCOST.codicebanca)= 4 
            	then '0' || TCOST.codicebanca
			else TCOST.codicebanca end as CODICE_BANCA,
            TCOST.CODICECOSTO     	AS CODICE_COSTO,
            RAPP.ID               	AS IDRAPPORTO,
            TCOST.CODICEMOVIMENTO	AS NUMREG,
            TCOST.IMPORTO         	AS IMPORTO,
            'CM'                  	AS TIPO_FONTE,
            NULL                  	AS DATA_DA,
            NULL                  	AS DATA_A,
            NULL                  	AS SSA,
            NULL                  	AS DATA_AGGIORNAMENTO
          FROM
            TMP_PFCOSTI_TITOLI TCOST
          INNER JOIN MOVIMENTO MOV 
          	ON TCOST.CODICEMOVIMENTO = MOV.NUMREG
          INNER JOIN RAPPORTO RAPP 
            ON MOV.IDRAPPORTO = RAPP.ID
          ORDER BY RAPP.ID, TCOST.CODICEMOVIMENTO, TCOST.CODICECOSTO
)));