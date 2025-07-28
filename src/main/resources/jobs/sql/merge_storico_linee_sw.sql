declare

cursor popola_storico_linee_sw is 
with cerca_data_sr as (	select /*+ PARALLEL(8) */	
                        distinct 	r.id as idrapporto,
                        			LPAD(trim(tmp.numero_polizza),12,'0') as codicerapporto,
                        			tmp.numero_polizza,
                        			b.codicetitolo as codicetitolo_old,
                        			nvl(min(sr.data),0) as data_da,
                                    tmp.data_nav
						from tmp_pfmov_swprivate tmp
						inner join tbl_bridge b
							on tmp.cod_linea = b.cod_linea
							and tmp.cod_universo = b.cod_universo
							and tmp.tipo_movimento = 'Fondo Precedente'
						inner join rapporto r
							on r.codicerapporto = LPAD(trim(tmp.numero_polizza),12,'0')
							and r.tipo = '13'
						inner join saldo_rend sr
							on r.idptf = sr.idptf
							and b.codicetitolo = sr.codicetitolo
							--and sr.data <= tmp.data_nav
						where tmp.cod_linea is not null
						group by r.id, LPAD(trim(tmp.numero_polizza),12,'0'), tmp.numero_polizza, b.codicetitolo, tmp.data_nav
						),
cerca_titolo_nuovo as (
                        select 	tmp_sw.numero_polizza,
    								b1.codicetitolo as codicetitolo_new,
    								tmp_sw.data_nav as data_new --ho messo la data nav
                        from tmp_pfmov_swprivate tmp_sw
                            inner join tbl_bridge b1
                                on tmp_sw.cod_linea = b1.cod_linea
                                and tmp_sw.cod_universo = b1.cod_universo
                                and tmp_sw.tipo_movimento = 'Fondo Nuovo'
                            inner join rapporto r
							on r.codicerapporto = LPAD(trim(tmp_sw.numero_polizza),12,'0')
							and r.tipo = '13'
                            inner join saldo_rend sr1
                                on r.idptf = sr1.idptf
                                and b1.codicetitolo = sr1.codicetitolo
                                --and sr1.data >= tmp_sw.data_nav
                            where tmp_sw.cod_linea is not null
                          group by LPAD(trim(tmp_sw.numero_polizza),12,'0'), tmp_sw.numero_polizza, b1.codicetitolo, tmp_sw.data_nav
                        ),
cerca_storico as (                         
	select 	/*+ PARALLEL(8) */
			cerca.idrapporto												    as idrapporto,
			cerca.numero_polizza							                    as codicerapporto,
			cerca.codicetitolo_old											    as codicetitolo_old,
			cerca_new.codicetitolo_new										    as codicetitolo_new,
    		to_char(cerca.data_da)	            		                        as data_da,
			to_char(to_date(cerca.data_nav, 'YYYYMMDD')-1, 'YYYYMMDD')        	as data_a,		
            cerca.data_nav														as data_nav,
			sysdate												    			as tmstp,
            row_number() over (partition by idrapporto order by idrapporto, cerca.data_nav asc) row_num
	from cerca_data_sr cerca
    inner join cerca_titolo_nuovo cerca_new
        on cerca.numero_polizza = cerca_new.numero_polizza
        and cerca.data_nav= cerca_new.data_new
    where cerca.codicetitolo_old != cerca_new.codicetitolo_new
    order by row_num)
select  s.idrapporto, 
        s.codicerapporto,
        s.codicetitolo_old, 
        s.codicetitolo_new, 
        s.data_da, 
        s.data_a, 
        s.data_nav, 
        s.tmstp,
        to_char(to_date(cs.data_a, 'YYYYMMDD')+1, 'YYYYMMDD') as new_data_da
from cerca_storico s
left join cerca_storico cs
    on s.idrapporto = cs.idrapporto
    and s.codicerapporto = cs.codicerapporto
    and cs.row_num = s.row_num-1
order by s.data_nav;

I 					NUMBER(38,0):=0;
data_a_corretta 	VARCHAR(8);
data_da_corretta 	VARCHAR(8);
max_data_old		timestamp;
check_last_switch 	NUMBER;

    
	
BEGIN
				
	FOR cur_item IN popola_storico_linee_sw
    	LOOP
        I := I+1;
        
        data_a_corretta := cur_item.data_a;
        
        if(cur_item.data_a < cur_item.data_da)
         then 
         
            DBMS_OUTPUT.PUT_LINE('Data_da calcolata vale: '|| cur_item.data_da || ' Data a vale: ' || cur_item.data_a);
        
       
            select to_char(to_date((min(srsr.data)), 'YYYY-MM-DD')-1, 'YYYYMMDD')
        	into data_a_corretta
        	from saldo_rend srsr
        	where idptf = cur_item.idrapporto
        	and codicetitolo = cur_item.codicetitolo_new
        	and srsr.data >= cur_item.data_nav
        	and srsr.data >= cur_item.data_da;
            
            DBMS_OUTPUT.PUT_LINE('Data a corretta vale: '|| data_a_corretta); 
                	
        end if;
        
        max_data_old :=null;
        
        select max(trunc(sto.tmstp))
		into max_data_old
		from storico_linee_sw sto
		where sto.idrapporto = cur_item.idrapporto
		and sto.codicerapporto = cur_item.codicerapporto
		and sto.codicetitolo_new = cur_item.codicetitolo_old;
		
		check_last_switch:= 0;
		
		if (max_data_old is not null)
			then
			
             	select count(*)
		        into check_last_switch
		        from storico_linee_sw sto
		        where sto.idrapporto = cur_item.idrapporto
		        and sto.codicerapporto = cur_item.codicerapporto
		        and sto.codicetitolo_new = cur_item.codicetitolo_old
		        and trunc(cur_item.tmstp) > max_data_old;
		end if;
							        
        if(check_last_switch != 0)
        
	        then 
	        		select to_char(to_date(sto1.data_a, 'YYYYMMDD')+1, 'YYYYMMDD')
		        	into data_da_corretta
		         	from storico_linee_sw sto1
		         	where sto1.idrapporto = cur_item.idrapporto
		        	and sto1.codicerapporto = cur_item.codicerapporto
		        	and sto1.codicetitolo_new = cur_item.codicetitolo_old;
        end if;
         
        

		merge into storico_linee_sw slsw
		  using (select cur_item.idrapporto			            as 	idrapporto,
						cur_item.codicerapporto		            as  codicerapporto,
						cur_item.codicetitolo_old	            as 	codicetitolo_old,
						cur_item.codicetitolo_new	            as 	codicetitolo_new,
						case
							when (cur_item.new_data_da is null and check_last_switch = 0)
								then cur_item.data_da
							when (cur_item.new_data_da is null and check_last_switch = 1)
								then data_da_corretta
							else 
								cur_item.new_data_da
						end										as 	data_da,
						data_a_corretta                	        as  data_a,	
						cur_item.tmstp				            as  tmstp
			from dual
			) tomerge
		  on (slsw.idrapporto = tomerge.idrapporto
		  		and slsw.data_da = tomerge.data_da
		  		and slsw.data_a = tomerge.data_a
		  		)
		when matched then update
		  set		slsw.codicerapporto		= tomerge.codicerapporto,
					slsw.codicetitolo_old	= tomerge.codicetitolo_old,
					slsw.codicetitolo_new	= tomerge.codicetitolo_new,
					slsw.tmstp				= tomerge.tmstp
	when not matched then 
			insert (idrapporto,		
					codicerapporto,	
					codicetitolo_old,
					codicetitolo_new,
					data_da,			
					data_a,			
					tmstp
					)
  			values (tomerge.idrapporto,		
					tomerge.codicerapporto,	
					tomerge.codicetitolo_old,
					tomerge.codicetitolo_new,
					tomerge.data_da,			
					tomerge.data_a,			
					tomerge.tmstp
				);
	
	
	if MOD(I,10000) = 0 then
		    insert into output_print_table values (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE STORICO_LINEE_SW - COMMIT ON ROW: '|| I);
		commit;
	end if;
		
	end loop;
		insert into output_print_table values (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE MERGE STORICO_LINEE_SW - COMMIT ON ROW: ' || I);
	commit;
end;