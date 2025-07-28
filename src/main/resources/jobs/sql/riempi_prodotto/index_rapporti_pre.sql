DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name = 'RAPP_NDG_IDX';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX RAPP_NDG_IDX';
    END IF;
    
    SELECT COUNT(*) INTO i FROM user_indexes WHERE index_name = 'RAPPORTO_IDX';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX RAPPORTO_IDX ';
    END IF;
    
    dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'TEMP_DELTARAPPORTO', degree => 4, estimate_percent=>1); 
    
    dbms_stats.gather_table_stats(ownname => sys_context('USERENV', 'CURRENT_SCHEMA'), tabname => 'RAPPORTO', degree => 4, estimate_percent=>1); 
END;
