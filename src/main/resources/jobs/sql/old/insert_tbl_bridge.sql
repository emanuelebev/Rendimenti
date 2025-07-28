TRUNCATE TABLE TBL_BRIDGE;

INSERT INTO TBL_BRIDGE (COD_UNIVERSO, COD_LINEA, CODICETITOLO)
	select distinct COD_UNIVERSO, COD_LINEA, CODICETITOLO
	from (
		select distinct sf.GMPOL12 as COD_UNIVERSO, 
						case when regexp_like(substr(sf.codicetitolo, 3,1), '\d+(\.\d+)?') then 0||substr(sf.codicetitolo, 3,1)
						else null end as COD_LINEA, 
					sf.codicetitolo as CODICETITOLO
	from strumentofinanziario sf
	where sf.livello_2 like '%MULTIRAMO'
	
	union
	
	select distinct sf.GMPOL11 as COD_UNIVERSO, 
					case when regexp_like(substr(sf.codicetitolo, 3,1), '\d+(\.\d+)?') then 0||substr(sf.codicetitolo, 3,1)
						else null end as COD_LINEA, 
					sf.codicetitolo as CODICETITOLO
	from strumentofinanziario sf
		where sf.livello_2 like '%MULTIRAMO'
	);

INSERT INTO TBL_BRIDGE (COD_UNIVERSO, COD_LINEA, CODICETITOLO) VALUES ('MRU01',null,'MRU01');  --TEMPORANEO
INSERT INTO TBL_BRIDGE (COD_UNIVERSO, COD_LINEA, CODICETITOLO) VALUES ('MRUD1',null,'MRUD1');  --TEMPORANEO

INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' TBL_BRIDGE CREATA');

COMMIT;