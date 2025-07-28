declare 
cursor popola_mov_switch_affluent is 
with dati_mov as 	(	select 	/*+ parallel(8) */	  
								
								r.id																							as idrapporto, 
								tmp_sw.numero_polizza||'_'||tmp_sw.fondo||'_'||tmp_sw.data_nav 
								||'_'|| tmp_sw.cod_universo ||'_'|| tmp_sw.cod_linea											as numreg,
								tmp_sw.numero_polizza																			as numero_polizza,
								b.codicetitolo																					as codicetitolo, 
								tmp_sw.data_nav																					as data_nav,
                                tmp_sw.data_nav                                             								    as data,
								case 
									when tmp_sw.tipo_movimento ='Fondo Precedente'
										then '13_SWO'
									when tmp_sw.tipo_movimento ='Fondo Nuovo'
										then '13_SWI'
								end 																							as causale,
								nav																								as prezzo,
								quote																							as qta,
                                '1'                                                                                             as cambio,
                                'EUR'                                                                                           as divisa
						from tmp_pfmov_swprivate tmp_sw
						inner join rapporto r
							on r.codicerapporto = LPAD(trim(tmp_sw.numero_polizza),12,'0')
							and r.tipo = '13'
						inner join tbl_bridge b
							on tmp_sw.cod_linea = b.cod_linea 
							and tmp_sw.cod_universo = b.cod_universo
						where tmp_sw.cod_linea is not null
					),
	cerca_ctv_sr as	(	select /*+ parallel(8) */	
								sr.id_rapporto, sr.codicetitolo, sr.data, nvl(sr.ctv, 0) as ctv, cerca.data_nav, cerca.numero_polizza
						from saldo_rend sr
                        inner join (
									select sr.id_rapporto, max(sr.data) as max_data, data_nav, numero_polizza
									from dati_mov dati
									inner join saldo_rend sr
										on dati.idrapporto = sr.id_rapporto
									
									where sr.data <= dati.data_nav
									group by sr.id_rapporto, dati.data_nav, numero_polizza, data_nav
									) cerca
                        on sr.id_rapporto = cerca.id_rapporto
                     
                        and sr.data = cerca.max_data
						order by  cerca.data_nav,numero_polizza
						 )                       
         select distinct dati.idrapporto as idrapporto,
                dati.numreg, 
                dati.numero_polizza,
                dati.codicetitolo, 
                dati.data as data_nav, 
                dati.causale, 
                dati.prezzo,
                dati.qta,
                cerca.ctv as ctv_sr, 
                cerca.ctv as ctv_divisa,
                dati.cambio, 
                dati.divisa,
                cerca.data as data_sr
         from dati_mov dati 
         inner join cerca_ctv_sr cerca
            on dati.idrapporto = cerca.id_rapporto
            and dati.numero_polizza = cerca.numero_polizza
            and dati.data_nav = cerca.data_nav;
     
         
I 		NUMBER(38,0):=0;
ctv float;

begin 
	
	for cur_item in popola_mov_switch_affluent
    	loop
        
        ctv :=0;
        
        select nvl(sum(ctv),0)
        into ctv
        from movimento mov
        where mov.idrapporto = cur_item.idrapporto
        and mov.data > cur_item.data_sr and mov.data <= cur_item.data_nav
        and mov.causale not in ('13_SWO', '13_SWI');
        
               
        DBMS_OUTPUT.PUT_LINE('Ctv: '|| ctv ||' per numreg: ' || cur_item.numreg); 
        
        ctv:= cur_item.ctv_sr + ctv;
        
        DBMS_OUTPUT.PUT_LINE('New Ctv: '|| ctv ||' per numreg: ' || cur_item.numreg); 
        
        
        I := I+1;
	
		merge into movimento mov
		  using (select cur_item.idrapporto           			as idrapporto,
						cur_item.numreg           				as numreg,
						cur_item.numero_polizza           		as numero_polizza,
						cur_item.codicetitolo           		as codicetitolo,
						cur_item.data_nav          				as data,
						cur_item.causale           				as causale,
						cur_item.prezzo           				as prezzo,
						cur_item.qta           					as qta,
                        case 
                            when cur_item.causale = '13_SWO'
                                then (ctv)* -1
                            when cur_item.causale = '13_SWI'
                                then ctv
                            end as ctv,
                        case 
                            when cur_item.causale = '13_SWO'
                                then (ctv)* -1
                            when cur_item.causale = '13_SWI'
                                    then ctv
                        end as ctv_divisa,
						cur_item.cambio							as cambio, 
						cur_item.divisa							as divisa
			from dual
			) tomerge
		  on (mov.idrapporto = tomerge.idrapporto
		  	 and mov.numreg = tomerge.numreg)
		   
	when matched then update
		  set
				mov.numero_polizza = tomerge.numero_polizza,
				mov.codicetitolo = tomerge.codicetitolo,
				mov.data = tomerge.data,
				mov.causale = tomerge.causale,
				mov.prezzo = tomerge.prezzo,
				mov.qta = tomerge.qta,
				mov.ctv = tomerge.ctv,
				mov.ctvdivisa = tomerge.ctv_divisa,
				mov.cambio = tomerge.cambio,
				mov.divisa = tomerge.divisa
	when not matched then 
			insert (	idrapporto,
						numreg,
						numero_polizza,
						codicetitolo,
						data,
						causale,
						prezzo,
						qta,
						ctv,
						ctvdivisa,
						cambio,
						divisa
					)
	  		values (	tomerge.idrapporto,
						tomerge.numreg,
						tomerge.numero_polizza,
						tomerge.codicetitolo,
						tomerge.data,
						tomerge.causale,
						tomerge.prezzo,
						tomerge.qta,
						tomerge.ctv,
						tomerge.ctv_divisa,
						tomerge.cambio,
						tomerge.divisa
				);
	
	if MOD(I,10000) = 0 then
		    insert into output_print_table values (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_SWPRIVATE (SWITCH AFFLUENT) - COMMIT ON ROW: '|| I);
		commit;
	end if;

	end loop;
		insert into output_print_table values (to_number(to_char(sysdate,'YYYYMMDDHH24MISS')) || ' MERGE TMP_PFMOV_SWPRIVATE (SWITCH AFFLUENT) - COMMIT ON ROW: ' || I);
	commit;
    
end;