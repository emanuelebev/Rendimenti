DECLARE 

	maxyearweek 	NUMBER;
	maxyearweeksp 	NUMBER;
	t1sp			NUMBER;
	t1pz			NUMBER;

--Partizioni da tronacre
	CURSOR weeks_retent IS
	      SELECT /*+ PARALLEL(8) */ DISTINCT yearweek +1 AS yearweek
	      FROM saldo_rend_polizze
	      WHERE yearweek < t1pz;
	      
	CURSOR weeks_retent_sott IS
	      SELECT /*+ PARALLEL(8) */ DISTINCT yearweek +1 AS yearweek
	      FROM saldo_rend_sott_pol
	      WHERE yearweek < t1pz;


BEGIN

	SELECT /*+ PARALLEL(8) */ valore 
    INTO maxyearweek
    FROM maxdata_polizze 
    WHERE chiave = 'maxyearweek';
    
    SELECT /*+ PARALLEL(8) */ valore 
    INTO maxyearweeksp
    FROM maxdata_polizze 
    WHERE chiave = 'maxyearweeksp';
    
	SELECT /*+ PARALLEL(8) */ valore
	INTO t1pz
	FROM maxdata_polizze 
    WHERE chiave = 't1pz';
    
    SELECT /*+ PARALLEL(8) */ valore
	INTO t1sp
	FROM maxdata_polizze 
    WHERE chiave = 't1sp';

  
--truncate partizioni 
 
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' TRUNCATE PARTITION maxyearweek ' || maxyearweek);
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' TRUNCATE PARTITION t1pz ' || t1pz);
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' TRUNCATE PARTITION maxyearweeksp ' || maxyearweeksp);
INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' TRUNCATE PARTITION t1sp ' || t1sp);
    
    IF(maxyearweek > t1pz OR maxyearweeksp > t1sp) THEN
    
       FOR cur_item IN weeks_retent
         LOOP
          
          FOR R IN (SELECT /*+ PARALLEL(8) */ partition_name, high_value 
                       FROM all_tab_partitions
                      WHERE table_name = 'SALDO_REND_POLIZZE') 
                      
            LOOP
             EXECUTE IMMEDIATE
                'BEGIN 
                  IF  '|| R.high_value ||' = '||cur_item.yearweek||'
                    THEN 
                    EXECUTE IMMEDIATE '' 
                    ALTER TABLE SALDO_REND_POLIZZE TRUNCATE PARTITION ' || R.partition_name || '''; 
                  END IF;
                END;';
          END LOOP;
          
         END LOOP;
          
          FOR cur_item IN weeks_retent_sott
         	LOOP
          
          FOR R IN (SELECT /*+ PARALLEL(8) */ partition_name, high_value 
                       FROM all_tab_partitions
                      WHERE table_name = 'SALDO_REND_SOTT_POL') 
                      
            LOOP
             EXECUTE IMMEDIATE
                'BEGIN 
                  IF  '|| R.high_value ||' = '||cur_item.yearweek||'
                    THEN 
                    EXECUTE IMMEDIATE '' 
                    ALTER TABLE SALDO_REND_SOTT_POL TRUNCATE PARTITION ' || R.partition_name || '''; 
                  END IF;
                END;';
          END LOOP;
         
          END LOOP;
          
            INSERT INTO output_print_table VALUES (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' TRUNCATE PARTITION');
          COMMIT;
          
          EXECUTE IMMEDIATE'ALTER INDEX RENDIMPC.PK_SALDO_REND_POLIZZE REBUILD';
          EXECUTE IMMEDIATE'ALTER INDEX RENDIMPC.PK_SALDO_REND_SOT_POL REBUILD';

	END IF;

END;