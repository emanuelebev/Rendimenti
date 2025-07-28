declare

cursor movimenti_non_esistenti IS		
select  /*+ parallel(8) */ mov.idrapporto, mov.numreg, sls.codicetitolo_old
from storico_linee_sw sls
inner join movimento mov
    on sls.idrapporto = mov.idrapporto
where mov.data >= sls.data_da 
and mov.data <= sls.data_a
and mov.causale not in ('13_SWO','13_SWI')
and mov.codicetitolo = sls.codicetitolo_new;
                
                
I		NUMBER(38, 0):= 0;
  
  
begin
 
  for cur_item in movimenti_non_esistenti

  loop

    I := I + 1;

    update movimento mm
    set mm.codicetitolo = cur_item.codicetitolo_old
    where mm.idrapporto  = cur_item.idrapporto
    and mm.numreg = cur_item.numreg;
  
    commit;
    
    if mod(I, 10000) = 0
    then
      insert into output_print_table values (TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) || ' UPDATE MOVIMENTI MULTIRAMO AFFLUENT VECCHI SU NUOVO CODICETITOLO - COMMIT ON ROW: ' || I);
      commit;
    end if;

  end loop;
 
 end;