 ------- 2nd script to create metiers within SQL database --------
 /* This script creates and update the table voyage_target_taxa that identify the  TARGETED ASSAMBLAGE  by fishing TRIP */
 

 --- Dependencies : 
 
	--  TABLE: eflalo_metiers.voyage_taxa_stats
	 

drop  table eflalo_metiers.voyage_target_taxa ;
create table eflalo_metiers.voyage_target_taxa as   
	select distinct ft_ref, dcf_gearcode ,le_div ,null as target_taxa from eflalo_metiers.voyage_taxa_stats;
  
	----  Not set and Misc . 
		--  Roi update: I have included the RG and SV gear codes in the list of MISCELANEA , since these dont appears in dcf_codes metadata table. 

		
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'NA'
	 from ( 
	 
		select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ( 'NOG', 'OTH', 'MISC', 'HF', 'NK')  --or  le_gear IN ( 'RG', 'SV' ) 

		
		)b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;



 
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa ;			
	--select * from  eflalo_metiers.voyage_target_taxa; 
	
	--- DREDGES ( DRB and HMD) . Only MOL permitted
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'MOL' from ( 
		select distinct ft_Ref, dcf_gearcode, le_div  from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ( 'DRB', 'HMD') 
		)b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and   a.le_div = b.le_div;
	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa ;
	
	
	--- LINES AND SEINES   . Only DWS and DEF permitted ----



	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('LLS','GTR','SSC','SDN','SPR') ) b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select   a.ft_Ref  , a.dcf_gearcode, a.le_div,  lekg_sum_dws,lekg_sum_def  
					from ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_dws 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('LLS') AND taxa = 'DWS' 
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_def 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('LLS') AND taxa = 'DEF' 
					) b 
				        on a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div 
				  -- condition to apply to targeted assemblage 
				     where lekg_sum_dws > lekg_sum_def ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;
	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa ; --where  target_taxa = 'MOL'
	
	
	---  HAND AND POLE LINES (LHP)     . Only DWS and DEF permitted ----
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'FIF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('LHP')  ) b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'CEP' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('LHP') and maxval = 'CEP')b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div; 
	 
	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL';
	
	
	---  TROLLING (LTL) . Only LPF  ----
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'LPF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('LTL')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;	 
	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'
	
	----------------------------------------------------
	---  BEACH AN BOAT SEINES  (SB)     . Only FIF  ----
	----------------------------------------------------
	
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('SB') group by maxwgt;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('SB') group by maxval;

	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'FIF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('SB')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;
	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'
	
	------------------------------------------
	---  FYKE NETS  (FYK)     . Only DEF  ----
	------------------------------------------
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('FYK') group by maxwgt;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('FYK') group by maxval;

	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from ( select distinct ft_Ref, dcf_gearcode,le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('FYK')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;	

	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa ;--where  target_taxa = 'MOL'
	
	
	---  DRIFT NETS  (GND)     . Only SPF or DEF depends on weights  ----
	
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('GND') group by maxwgt order by count;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('GND') group by maxval order by count;

	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'SPF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div  from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('GND')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;	 
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select  a.ft_Ref, a.dcf_gearcode, a.le_div,lekg_sum_def,lekg_sum_spf  
					from ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_def 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GND') AND taxa = 'DEF' 
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_spf
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GND') AND taxa = 'SPF' 
					)b 
				       on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				     where lekg_sum_def > lekg_sum_spf ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;
	
	
	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'
	

	
	---  DRIFT LONG LINERS  (LLD)     . Only LPF, DWS or DEF depends on weights ----
	
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('LLD') group by maxwgt order by count;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('LLD') group by maxval order by count;

	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('LLD')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;	 
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'LPF'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select   a.ft_Ref  , a.dcf_gearcode,a.le_div,  lekg_sum_def,lekg_sum_lpf  
					from ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_lpf
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('LLD') AND taxa = 'LPF' 
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_def
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('LLD') AND taxa = 'DEF' 
					)b 
				        on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				     where lekg_sum_lpf > lekg_sum_def ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'SPF'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select  a.ft_Ref , a.dcf_gearcode , a.le_div,  lekg_sum_def,lekg_sum_spf  
					from ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_spf
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('LLD') AND taxa = 'SPF' 
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode,le_div,lekg_sum*0.5 lekg_sum_def 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('LLD') AND taxa = 'DEF' 
					)b 
				        on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				     where lekg_sum_spf > lekg_sum_def ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;



	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select  a.ft_Ref , a.dcf_gearcode , a.le_div,  lekg_sum_def,lekg_sum_dws  
					from ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('LLD') AND taxa = 'DWS' 
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode,le_div,lekg_sum*0.5 lekg_sum_def 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('LLD') AND taxa = 'DEF' 
					)b 
				        on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				     where lekg_sum_dws > lekg_sum_def ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;
	
	
	
	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'
	
	
		---  Mid water otter  (OTM)     . Only SPF or DEF has additional UK metier by species.  SPF unles DEF weight is more than half the total weight  ----
	
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('OTM') group by maxwgt order by count;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('OTM') group by maxval order by count;

	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'SPF' 
	from ( select distinct ft_Ref, dcf_gearcode , le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('OTM')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;	 
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select   a.ft_Ref , a.dcf_gearcode , a.le_div,  lekg_sum_def,halftotwgt  
					from ( 
						select distinct ft_Ref, dcf_gearcode,le_div,  lekg_sum lekg_sum_def 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('OTM') AND taxa = 'DEF' 
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode,le_div,  halftotwgt halftotwgt
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('OTM') 
					)b 
				         on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				     where lekg_sum_def > halftotwgt ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	
	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'




---  Mid water pair and purse seine   (PRM and PS). Only SPF or LPF. These are SPF unles LPFWT is more than SPFWT  ----
	
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('PTM','PS') group by maxwgt order by count;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('PTM', 'PS') group by maxval order by count;

	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'SPF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('PTM', 'PS')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'LPF'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select   a.ft_Ref , a.dcf_gearcode ,a.le_div,   lekg_sum_lpf,lekg_sum_spf  
					from ( 
						select distinct ft_Ref, dcf_gearcode,le_div,  lekg_sum lekg_sum_lpf 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('PTM', 'PS') AND taxa = 'LPF' 
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode,le_div,  lekg_sum lekg_sum_spf
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('PTM', 'PS')  AND taxa = 'SPF'
					)b 
				         on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div   
				  -- condition to apply to targeted assemblage 
				     where lekg_sum_lpf > lekg_sum_spf ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	
	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'
	
	


---  Pots and Traps    (FPO). ** KB had groped Misc (OTH) in with this either CRU MOL or FIF  ----
	
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('FPO') group by maxwgt order by count;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('FPO') group by maxval order by count;

	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'FIF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('FPO')  ) b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
 	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'CRU' 
	from ( select distinct  ft_Ref, dcf_gearcode, le_div  from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('FPO') AND maxval IN ('CRU','CRUDWS')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;

	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'MOL' 
	from ( select distinct  ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('FPO') AND maxval IN ('MOL')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;

	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'MOL'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select   a.ft_Ref  , a.dcf_gearcode, a.le_div,  leeuro_sum_mol_cru,halftotval , leeuro_sum_mol, leeuro_sum_cru
					from ( 
						select distinct ft_Ref, dcf_gearcode, le_div,sum(leeuro_sum) leeuro_sum_mol_cru 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('FPO') AND taxa IN ('MOL' , 'CRU' )
						group by ft_Ref, dcf_gearcode, le_div
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,halftotval  
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('FPO')   
					)b 
				      on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				    left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_mol  
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('FPO')   AND taxa = 'MOL'
					) c  
				    on  b.ft_ref = c.ft_ref and b.dcf_gearcode = c.dcf_gearcode
				   left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_cru  
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('FPO')   AND taxa = 'CRU'
					) d 
				      on  c.ft_ref = d.ft_ref and c.dcf_gearcode = d.dcf_gearcode
				  -- condition to apply to targeted assemblage 
				     where leeuro_sum_mol_cru  >= halftotval AND leeuro_sum_mol >= leeuro_sum_cru ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'CRU'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select   a.ft_Ref , a.dcf_gearcode , a.le_div, leeuro_sum_mol_cru,halftotval , leeuro_sum_mol, leeuro_sum_cru
					from ( 
						select distinct ft_Ref, dcf_gearcode, le_div,sum(leeuro_sum) leeuro_sum_mol_cru 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('FPO') AND taxa IN ('MOL' , 'CRU' )
						group by ft_Ref, dcf_gearcode, le_div
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,halftotval  
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('FPO')   
					)b 
				     on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				    left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_mol  
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('FPO')   AND taxa = 'MOL'
					) c  
				     on  b.ft_ref = c.ft_ref and b.dcf_gearcode = c.dcf_gearcode
				   left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_cru  
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('FPO')   AND taxa = 'CRU'
					) d 
				    on  c.ft_ref = d.ft_ref and c.dcf_gearcode = d.dcf_gearcode
				  -- condition to apply to targeted assemblage 
				     where leeuro_sum_mol_cru  >= halftotval AND leeuro_sum_mol < leeuro_sum_cru ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	
	
	select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'
	
	
	
	


---  bottom pair PTB   # DEF CRU  or SPF  ----
	
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('PTB') group by maxwgt order by count;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('PTB') group by maxval order by count;

	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'CRU' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('PTB')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
 	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('PTB') AND maxwgt IN ('DEF')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'SPF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('PTB') AND maxwgt IN ('SPF')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('PTB') AND maxval IN ('DEF')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	

select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'
 
 
 

---------------------------------------------------------
---  bset gill nets GNS # DEF CRU DWS or SPF   ----
---------------------------------------------------------

	
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('GNS') group by maxwgt order by count;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('GNS') group by maxval order by count;

	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'CRU' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('GNS')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
 	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('GNS') AND maxwgt IN ('DEF')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'SPF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('GNS') AND maxwgt IN ('SPF')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('GNS') AND maxwgt IN ('DWS')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select   a.ft_Ref  , b.dcf_gearcode, a.le_div,   lekg_sum_def,lekg_sum_dws  
					from ( 
						select distinct ft_Ref, dcf_gearcode, le_div,lekg_sum lekg_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS') AND taxa = 'DWS' 
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,lekg_sum lekg_sum_def
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS')  AND taxa = 'DEF'
					)b 
				           on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				     where lekg_sum_dws > lekg_sum_def*0.5 AND a.ft_ref IN ( 
				     select ft_ref from eflalo_metiers.voyage_target_taxa 
				     where target_taxa = 'DEF'
				     )
				 ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
		update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS'
			---- Creates two subsets with the taxa categories to compare their weights 
			from (  select   a.ft_Ref , a.dcf_gearcode , a.le_div, leeuro_sum_def,leeuro_sum_dws  
					from ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS') AND taxa = 'DWS' 
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_def
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS')  AND taxa = 'DEF'
					)b 
				           on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				     where leeuro_sum_dws > leeuro_sum_def*0.5 AND a.ft_ref IN ( select ft_ref from eflalo_metiers.voyage_target_taxa where target_taxa = 'DEF')
				 ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS'
		---- Creates two subsets with the taxa categories to compare their weights 
		from (  select   a.ft_Ref , a.dcf_gearcode   ,a.le_div, leeuro_sum_cru,leeuro_sum_dws  
					from ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS') AND taxa = 'DWS' 
					)a 
					left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_cru
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS')  AND taxa = 'CRU'
					)b 
						 on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
					 where leeuro_sum_dws > leeuro_sum_cru*0.5
						    AND a.ft_ref IN ( 
											select ft_ref 
											from eflalo_metiers.voyage_target_taxa 
											where target_taxa = 'CRU'
										)
			 ) b
   where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
   
   	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS'
		---- Creates two subsets with the taxa categories to compare their weights 
		from (  select   a.ft_Ref , a.dcf_gearcode   ,a.le_div,  lekg_sum_dws,lekf_sum_spf_lpf  
				from ( 
					select distinct ft_Ref, dcf_gearcode, le_div,lekg_sum lekg_sum_dws
					from eflalo_metiers.voyage_taxa_stats 
					where dcf_gearcode IN ('GNS') AND taxa = 'DWS' 
				)a 
				left join ( 
					select distinct ft_Ref, dcf_gearcode, le_div,sum(lekg_sum) lekf_sum_spf_lpf
					from eflalo_metiers.voyage_taxa_stats 
					where dcf_gearcode IN ('GNS')  AND taxa IN ('SPF', 'LPF')
					group by ft_Ref, dcf_gearcode, le_div
				)b 
					 on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div

			  -- condition to apply to targeted assemblage 
				 where lekg_sum_dws > lekf_sum_spf_lpf*0.5 AND a.ft_ref IN ( select ft_ref from eflalo_metiers.voyage_target_taxa where target_taxa = 'SPF')
			 ) b
   where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	
	

select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'

 

---  Beam trawls TBB # for beam trawls its either DEF or CRU depending on value  ----
	
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('TBB') group by maxwgt order by count;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('TBB') group by maxval order by count;

	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('TBB')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	 	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'CRU' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('TBB') AND maxval IN ('CRU', 'CRUDW')  )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;

select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'


--------------------------------------------------------------------------------------------------------------------------
---  bottom otter, and multi rig otter trawls  OTM OTT # Its CRU or MOL if these are the most valuble   ----
--------------------------------------------------------------------------------------------------------------------------
	
	select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('OTB', 'OTT') group by maxwgt order by count;
	select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('OTB', 'OTT') group by maxval order by count;

 

	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'CRU' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('OTB', 'OTT') AND maxval IN ('CRU', 'CRUDW') )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	 	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'MOL' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('OTB', 'OTT') AND maxval IN ('MOL', 'CEP') )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('OTB', 'OTT') AND maxwgt IN ('DWS') )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('OTB', 'OTT') AND maxwgt IN ('DEF') )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'SPF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('OTB', 'OTT') AND maxwgt IN ('SPF','LPF') )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('OTB', 'OTT') AND maxval IN ('DEF') )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'SPF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('OTB', 'OTT') AND maxval IN ('SPF') )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS'
	---- Creates two subsets with the taxa categories to compare their weights 
	from (  select   a.ft_Ref  , a.dcf_gearcode, a.le_div,  lekg_sum_dws,lekg_sum_def  
			from ( 
				select distinct ft_Ref, dcf_gearcode, le_div,lekg_sum lekg_sum_dws
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') AND taxa = 'DWS' 
			)a 
			left join ( 
				select distinct ft_Ref, dcf_gearcode, le_div, lekg_sum  lekg_sum_def
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT')  AND taxa IN ('DEF')
				 
			)b 
				using (ft_ref)
		  -- condition to apply to targeted assemblage 
			 where lekg_sum_dws > lekg_sum_def*0.5 AND a.ft_ref IN ( select ft_ref from eflalo_metiers.voyage_target_taxa where target_taxa = 'DEF')
		 ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
		update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS'
	---- Creates two subsets with the taxa categories to compare their weights 
	from (  select   a.ft_Ref  , b.dcf_gearcode ,a.le_div,   leeuro_sum_dws,leeuro_sum_def  
			from ( 
				select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_dws
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') AND taxa = 'DWS' 
			)a 
			left join ( 
				select distinct ft_Ref, dcf_gearcode, le_div, leeuro_sum  leeuro_sum_def
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT')  AND taxa IN ('DEF')
				 
			)b 
				 on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div

		  -- condition to apply to targeted assemblage 
			 where leeuro_sum_dws > leeuro_sum_def*0.5 AND a.ft_ref IN ( select ft_ref from eflalo_metiers.voyage_target_taxa where target_taxa = 'DEF')
		 ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS'
	---- Creates two subsets with the taxa categories to compare their weights 
	from (  select  a.ft_Ref  , b.dcf_gearcode,a.le_div,  leeuro_sum_dws,leeuro_sum_cru  
			from ( 
				select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_dws
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') AND taxa = 'DWS' 
			)a 
			left join ( 
				select distinct ft_Ref, dcf_gearcode, le_div, leeuro_sum  leeuro_sum_cru
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT')  AND taxa IN ('CRU')
				 
			)b 
			 on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div

		  -- condition to apply to targeted assemblage 
			 where leeuro_sum_dws > leeuro_sum_cru*0.5 AND a.ft_ref IN ( select ft_ref from eflalo_metiers.voyage_target_taxa where target_taxa = 'CRU')
		 ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DWS'
	---- Creates two subsets with the taxa categories to compare their weights 
	from (  select   a.ft_Ref  ,a.dcf_gearcode, a.le_div,   leeuro_sum_dws,lekg_sum_spf_lpf  
			from ( 
				select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_dws
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') AND taxa = 'DWS' 
			)a 
			left join ( 
				select distinct ft_Ref, dcf_gearcode, le_div, sum(lekg_sum)  lekg_sum_spf_lpf
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT')  AND taxa IN ('SPF','LPF')
				group by ft_Ref, dcf_gearcode, le_div				 
			)b 
			  on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div

		  -- condition to apply to targeted assemblage 
			 where lekg_sum_dws > lekg_sum_spf_lpf*0.5 AND a.ft_ref IN ( 
					select ft_ref from eflalo_metiers.voyage_target_taxa where target_taxa = 'SPF'
					)
		 ) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'SPF' 
	from ( select distinct ft_Ref, dcf_gearcode, le_div from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode IN ('OTB', 'OTT') AND maxval IN ('SPF','LPF') AND ft_ref IN ( select ft_ref from eflalo_metiers.voyage_target_taxa where target_taxa IS NULL) )b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	

select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop from eflalo_metiers.voyage_target_taxa; --where  target_taxa = 'MOL'


	----- ANALYSE WHAT HAS NOT A METIER ASSIGNED 

	with a as ( select DISTINCT ft_ref from  eflalo_metiers.voyage_target_taxa  where target_taxa  IS NULL) 
	select count(*) n_rows , dcf_gearcode, taxa 
	from  (select * , count(*)  over( ) total from eflalo_metiers.voyage_taxa_stats   where ft_ref in ( select * from a ) ) b 
	 group by dcf_gearcode, taxa order by dcf_gearcode, n_rows DESC, taxa

 

	select  DISTINCT * from eflalo_metiers.voyage_taxa_stats 
	where dcf_gearcode in ('OTB') and ft_Ref in  (  
		select DISTINCT ft_Ref  from  eflalo_metiers.voyage_target_taxa  where target_taxa  IS NULL   
		 )  
		 order by ft_Ref

	

	----- ANALYSE WHAT HAS A METIER ASSIGNED 
	
	with a as ( select DISTINCT ft_ref from  eflalo_metiers.voyage_target_taxa  where target_taxa  IS NOT NULL) 
	select count(*) n_rows , dcf_gearcode, taxa 
	from  (select * ,  count(*)  over( ) total from eflalo_metiers.voyage_taxa_stats   where ft_ref in ( select * from a ) ) b 
	 group by dcf_gearcode, taxa order by dcf_gearcode, n_rows DESC, taxa 
	 

	----- ANALYSE ALL GEARS

	 select count(*) n_rows , dcf_gearcode, taxa 
	from  (select * , count(*)  over( ) total from eflalo_metiers.voyage_taxa_stats   ) b 
	 group by dcf_gearcode, taxa order by dcf_gearcode, n_rows DESC, taxa

	 select a.*, b."DCFcode" from eflalo_metiers.voyage_taxa_stats a left join fish_metadata.ifishgeartab b on a.dcf_gearcode = b."DCFcode"  

	 alter table  eflalo_metiers.voyage_taxa_stats add column dcf_gearcode varchar ( 15 ) ;   
	update eflalo_metiers.voyage_taxa_stats set  dcf_gearcode = "DCFcode" from  fish_metadata.ifishgeartab b where le_gear = b."iFishCode"  

	

	--- Gears in EFLALO not in METIERS gear metadata table 
	
	select distinct "LE_GEAR" from eflalo.eflalo_2018   
	EXCEPT
	select  DISTINCT "iFishCode" from fish_metadata.ifishgeartab 

	-- "SV" "RG"



	 with a as ( 
		select DISTINCT "FT_REF" ,"LE_MET" from eflalo_metiers.voyage_taxa_stats
	  ) , 
	  aa as ( select * ,   row_number() over ( partition by "FT_REF") rnum from a  ),
	  b as (  select * from aa where rnum > 1) 
	  
	  
	  select * from aa where "FT_REF" in ( select DISTINCT "FT_REF" from b)
	  order by  "FT_REF" ,"LE_MET", rnum 




	


	 


	 
