DECLARE

ROWCOUNTS 	NUMBER;


BEGIN
	
	DELETE FROM MOVIMENTO WHERE IDRAPPORTO = (SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000301188500002') AND NUMREG = 'MOVIMP-00000301188500002-00000521838-20171231';
	DELETE FROM MOVIMENTO WHERE IDRAPPORTO = (SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000297627600000') AND NUMREG = 'MOVIMP-00000297627600000-00016521710-20171231';
	DELETE FROM MOVIMENTO WHERE IDRAPPORTO = (SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000087424700000') AND NUMREG = 'MOVIMP-00000087424700000-00016521662-20171231';
	DELETE FROM MOVIMENTO WHERE IDRAPPORTO = (SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000297832800000') AND NUMREG = 'MOVIMP-00000297832800000-00016521778-20171231';
	DELETE FROM MOVIMENTO WHERE IDRAPPORTO = (SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000294049100000') AND NUMREG = 'MOVIMP-00000294049100000-00016521748-20171231';
	DELETE FROM MOVIMENTO WHERE IDRAPPORTO = (SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000296692800000') AND NUMREG = 'MOVIMP-00000296692800000-00016521753-20171231';
	DELETE FROM MOVIMENTO WHERE IDRAPPORTO = (SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000214043000000') AND NUMREG = 'MOVIMP-00000214043000000-00000372524-20171231';
	DELETE FROM MOVIMENTO WHERE IDRAPPORTO = (SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000163817000000') AND NUMREG = 'MOVIMP-00000163817000000-00000372524-20171231';
	DELETE FROM MOVIMENTO WHERE IDRAPPORTO = (SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000303133900000') AND NUMREG = 'MOVIMP-00000303133900000-00000453255-20171231';
	
		ROWCOUNTS := SQL%ROWCOUNT;	
	
	INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' BONIFICA MOVIMP TITOLI RIGHE MOVIMENTO ELIMINATE: ' || ROWCOUNTS);
		
	COMMIT;
		
	INSERT INTO MOVIMENTO (IDRAPPORTO,NUMREG,CODICETITOLO,CAUSALE,DATA,DATACONT,CAMBIO,CTV,CTVDIVISA,CTVNETTO,QTA,DIVISA,VALUTA,CAUSALE_ORI,D_AGGIORNAMENTO,C_PROCEDURA) VALUES ((SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000301188500002'),'MOVIMP-00000301188500002-00000521838-20171231','00000521838','15_MOVIMP',20171231,NULL,NULL,0,0,NULL,15,'EUR', 20171231,'MOVIMP',TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')),'PDR');
	INSERT INTO MOVIMENTO (IDRAPPORTO,NUMREG,CODICETITOLO,CAUSALE,DATA,DATACONT,CAMBIO,CTV,CTVDIVISA,CTVNETTO,QTA,DIVISA,VALUTA,CAUSALE_ORI,D_AGGIORNAMENTO,C_PROCEDURA) VALUES ((SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000297627600000'),'MOVIMP-00000297627600000-00016521710-20171231','00016521710','15_MOVIMP',20171231,NULL,NULL,0,0,NULL,8000,'EUR', 20171231,'MOVIMP',TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')),'PDR');
	INSERT INTO MOVIMENTO (IDRAPPORTO,NUMREG,CODICETITOLO,CAUSALE,DATA,DATACONT,CAMBIO,CTV,CTVDIVISA,CTVNETTO,QTA,DIVISA,VALUTA,CAUSALE_ORI,D_AGGIORNAMENTO,C_PROCEDURA) VALUES ((SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000087424700000'),'MOVIMP-00000087424700000-00016521662-20171231','00016521662','15_MOVIMP',20171231,NULL,NULL,0,0,NULL,20000,'EUR', 20171231,'MOVIMP',TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')),'PDR');
	INSERT INTO MOVIMENTO (IDRAPPORTO,NUMREG,CODICETITOLO,CAUSALE,DATA,DATACONT,CAMBIO,CTV,CTVDIVISA,CTVNETTO,QTA,DIVISA,VALUTA,CAUSALE_ORI,D_AGGIORNAMENTO,C_PROCEDURA) VALUES ((SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000297832800000'),'MOVIMP-00000297832800000-00016521778-20171231','00016521778','15_MOVIMP',20171231,NULL,NULL,0,0,NULL,300000,'EUR', 20171231,'MOVIMP',TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')),'PDR');
	INSERT INTO MOVIMENTO (IDRAPPORTO,NUMREG,CODICETITOLO,CAUSALE,DATA,DATACONT,CAMBIO,CTV,CTVDIVISA,CTVNETTO,QTA,DIVISA,VALUTA,CAUSALE_ORI,D_AGGIORNAMENTO,C_PROCEDURA) VALUES ((SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000294049100000'),'MOVIMP-00000294049100000-00016521748-20171231','00016521748','15_MOVIMP',20171231,NULL,NULL,0,0,NULL,400,'EUR', 20171231,'MOVIMP',TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')),'PDR');
	INSERT INTO MOVIMENTO (IDRAPPORTO,NUMREG,CODICETITOLO,CAUSALE,DATA,DATACONT,CAMBIO,CTV,CTVDIVISA,CTVNETTO,QTA,DIVISA,VALUTA,CAUSALE_ORI,D_AGGIORNAMENTO,C_PROCEDURA) VALUES ((SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000296692800000'),'MOVIMP-00000296692800000-00016521753-20171231','00016521753','15_MOVIMP',20171231,NULL,NULL,0,0,NULL,2000,'EUR', 20171231,'MOVIMP',TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')),'PDR');
	INSERT INTO MOVIMENTO (IDRAPPORTO,NUMREG,CODICETITOLO,CAUSALE,DATA,DATACONT,CAMBIO,CTV,CTVDIVISA,CTVNETTO,QTA,DIVISA,VALUTA,CAUSALE_ORI,D_AGGIORNAMENTO,C_PROCEDURA) VALUES ((SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000214043000000'),'MOVIMP-00000214043000000-00000372524-20171231','00000372524','15_MOVIMP',20171231,NULL,NULL,0,0,NULL,13,'EUR', 20171231,'MOVIMP',TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')),'PDR');
	INSERT INTO MOVIMENTO (IDRAPPORTO,NUMREG,CODICETITOLO,CAUSALE,DATA,DATACONT,CAMBIO,CTV,CTVDIVISA,CTVNETTO,QTA,DIVISA,VALUTA,CAUSALE_ORI,D_AGGIORNAMENTO,C_PROCEDURA) VALUES ((SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000163817000000'),'MOVIMP-00000163817000000-00000372524-20171231','00000372524','15_MOVIMP',20171231,NULL,NULL,0,0,NULL,12,'EUR', 20171231,'MOVIMP',TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')),'PDR');
	INSERT INTO MOVIMENTO (IDRAPPORTO,NUMREG,CODICETITOLO,CAUSALE,DATA,DATACONT,CAMBIO,CTV,CTVDIVISA,CTVNETTO,QTA,DIVISA,VALUTA,CAUSALE_ORI,D_AGGIORNAMENTO,C_PROCEDURA) VALUES ((SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000303133900000'),'MOVIMP-00000303133900000-00000453255-20171231','00000453255','15_MOVIMP',20171231,NULL,NULL,0,0,NULL,9000,'EUR', 20171231,'MOVIMP',TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDD')),'PDR');
		
		ROWCOUNTS := SQL%ROWCOUNT;			
	
	INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' BONIFICA MOVIMP TITOLI RIGHE MOVIMENTO INSERITE: ' || ROWCOUNTS);

	COMMIT;	
	
	UPDATE MOVIMENTO SET QTA = 70000 WHERE IDRAPPORTO =(SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000303137800000') AND NUMREG='MOVIMP-00000303137800000-00000393465-20171231';
	UPDATE MOVIMENTO SET QTA = 9000 WHERE IDRAPPORTO =(SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000303134100000') AND NUMREG='MOVIMP-00000303134100000-00000453255-20171231';
	UPDATE MOVIMENTO SET QTA = 100467 WHERE IDRAPPORTO =(SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000303123300001') AND NUMREG='MOVIMP-00000303123300001-00000510876-20171231';
	UPDATE MOVIMENTO SET QTA = 3591 WHERE IDRAPPORTO =(SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000221144500001') AND NUMREG='MOVIMP-00000221144500001-00000312836-20171231';
	UPDATE MOVIMENTO SET QTA = 187 WHERE IDRAPPORTO =(SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000077464200000') AND NUMREG='MOVIMP-00000077464200000-00016100277-20171231';
	UPDATE MOVIMENTO SET QTA = 133.76 WHERE IDRAPPORTO =(SELECT ID FROM RAPPORTO WHERE CODICERAPPORTO='00000032249700000') AND NUMREG='MOVIMP-00000032249700000-00000493628-20171231';

	ROWCOUNTS := SQL%ROWCOUNT;			

	INSERT INTO OUTPUT_PRINT_TABLE VALUES (TO_NUMBER(TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')) || ' BONIFICA MOVIMP TITOLI RIGHE MOVIMENTO AGGIORNATE: ' || ROWCOUNTS);
		
	COMMIT;
END;