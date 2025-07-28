DECLARE

count_deleted 	NUMBER(38,0):=0;
	

BEGIN

--Cancello squadrature rientrate
	DELETE FROM squadrature_2018
	WHERE dataagg IS NOT NULL
	AND TRUNC(sysdate) - TRUNC(dataagg) >= 1;
	
	count_deleted := count_deleted +  SQL%rowcount;
		
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' Squadrature QTA 2018. Squadrature eliminate: ' || count_deleted);
		COMMIT;

END;