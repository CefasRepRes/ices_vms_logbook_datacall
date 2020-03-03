 
  
 ------- 2nd script to create metiers within SQL database --------
 /* This script creates and update the table voyage_target_taxa that identify the  TARGETED ASSAMBLAGE  by fishing TRIP */
 

 --- Dependencies : 
 
	--  TABLE: eflalo_metiers.voyage_taxa_stats
	-- Contain the trip id, dcf gear code , division and the target assemblage taxa to be filled; 
	 

	drop  table if exists eflalo_metiers.voyage_target_taxa ;

	create table eflalo_metiers.voyage_target_taxa as   
		select distinct ft_ref, dcf_gearcode ,le_div ,null as target_taxa 
		from eflalo_metiers.voyage_taxa_stats;
  
	----  UPDATE: Update target assemblage taxa as NA for gears  Not set and Misc . 
		--  Roi update: I have included the RG and SV gear codes in the list of MISCELANEA , since these dont appears in dcf_codes metadata table. 

		
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'NA'
	from	(  	 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ( 'NOG', 'OTH', 'MISC', 'HF', 'NK')  --or  le_gear IN ( 'RG', 'SV' ) 
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode 
		and a.le_div = b.le_div;

		--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 		
		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ;			
	 
		
		
	--------------------------------------------------
	--- DREDGES 
	--- Permitted: MOL    
	--- Conditions: 1.- Trips using  ( 'DRB', 'HMD')  gears
	--------------------------------------------------
	
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'MOL' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div  
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ( 'DRB', 'HMD') 
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode 
		and   a.le_div = b.le_div;
	
		--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ;
	
	---------------------------------------------------------
	--- LINES AND SEINES    
	--- Permitted: DWS and DEF
	--- Conditions: 1.- Trips using ('LLS','GTR','SSC','SDN','SPR')  = 'DEF'
	---				2.- Trips using 'LLS' = 'DWS' when the TOTAL CATCH WEIGHT of 'DWS' > TOTAL CATCH WEIGHT of 'DEF'
	---------------------------------------------------------


	-- Condition 1	

	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('LLS','GTR','SSC','SDN','SPR') 
			) b 
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;
	
	-- Condition 2	

	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS'
			---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select   a.ft_Ref  , a.dcf_gearcode, a.le_div,  lekg_sum_dws,lekg_sum_def  
				from	( 	 
							select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_dws 
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('LLS') 
								and taxa = 'DWS' 
						)a 
				left join ( 
							select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_def 
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('LLS') 
								and taxa = 'DEF' 
						) b 
				on a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
					and a.le_div = b.le_div 
			  -- condition to apply to targeted assemblage 
				where lekg_sum_dws > lekg_sum_def 
			) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;

		--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ;  
	
	
	 
	
	---------------------------------------------------------
	--- HAND AND POLE LINES    
	--- Permitted: DWS and DEF
	--- Conditions: 1.-  Trips using ('LHP')  = 'FIF'  
	---				2.-  Trips using 'LHP' = 'CEP' when the MAX VALUE IS 'CEP'  
	---------------------------------------------------------
	
	-- Condition 1: 
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'FIF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('LHP')  
			) b 
	where a.ft_ref = b.ft_ref 
	and a.dcf_gearcode = b.dcf_gearcode 
	and a.le_div = b.le_div;
	
	-- Condition 2: 
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'CEP' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('LHP') and maxval = 'CEP'
			)b 
	where a.ft_ref = b.ft_ref 
	and a.dcf_gearcode = b.dcf_gearcode 
	and a.le_div = b.le_div; 
	 
	
		--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ;  
	
	
	
 
	---------------------------------------------------------
	--- TROLLING  
	--- Permitted: LTL  
	--- Conditions: 1.- Trips using ('LTL')  = 'LPF'  
	--------------------------------------------------------
	
		-- Condition 1: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'LPF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('LTL')  
			)b 
	where a.ft_ref = b.ft_ref 
	and a.dcf_gearcode = b.dcf_gearcode 
	and a.le_div = b.le_div;	 
	
	
		--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ;  
	
	 
	
	---------------------------------------------------------
	--- BEACH AN BOAT SEINES  
	--- Permitted: FIF  
	--- Conditions: 1.- Trips using ('SB')  = 'LPF'  
	--------------------------------------------------------
	
	-- select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('SB') group by maxwgt;
	-- select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('SB') group by maxval;

	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'FIF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('SB')  
			)b 
	where a.ft_ref = b.ft_ref 
	and a.dcf_gearcode = b.dcf_gearcode 
	and a.le_div = b.le_div;
	

		--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ;  
		
	 
	
	---------------------------------------------------------
	--- FYKE NETS   
	--- Permitted: DEF  
	--- Conditions: 1.- Trips using ('FYK')  = 'DEF'  
	--------------------------------------------------------
	
	
	-- select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('FYK') group by maxwgt;
	-- select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('FYK') group by maxval;

	
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode,le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('FYK')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode 
		and a.le_div = b.le_div;	

	
	  
		--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ;  
	
 	
	---------------------------------------------------------
	--- DRIFT NETS  
	--- Permitted: SPF and DEF 
	--- Conditions: 1.- Trips using ('GND')  = 'SPF'  
	---				2.- Trips using ('GND')  = 'DEF' when the TOTAL CATCH WEIGHT of 'DEF' > TOTAL CATCH WEIGHT of 'SPF'
	--------------------------------------------------------
	
	-- select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('GND') group by maxwgt order by count;
	-- select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('GND') group by maxval order by count;

	--- Condition 1: 
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'SPF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div  
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('GND') 
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode 
		and a.le_div = b.le_div;	 
	
	--- Condition 2: 
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DEF'
			---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select  a.ft_Ref, a.dcf_gearcode, a.le_div,lekg_sum_def,lekg_sum_spf  
				from 	( 
							select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_def 
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('GND') 
								AND taxa = 'DEF' 
						)a 
				left join ( 
							select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_spf
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('GND') 
								AND taxa = 'SPF' 
						)b 
				on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
					and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				where lekg_sum_def > lekg_sum_spf 
			) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode 
		and a.le_div = b.le_div;
	
	
	
	--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ;  
	
	
 	
	---------------------------------------------------------
	--- DRIFT LONG LINERS 
	--- Permitted: LPF ,SPF, DWS and DEF 
	--- Conditions: 1.- Trips using ('LLD')  = 'DEF'  
	---				2.- Trips using ('LLD')  = 'LPF' when the TOTAL CATCH WEIGHT of 'LPF' > TOTAL CATCH WEIGHT of 'DEF'
	---				3.- Trips using ('LLD')  = 'SPF' when the TOTAL CATCH WEIGHT of 'SPF' > HALF of TOTAL CATCH WEIGHT of 'DEF'
	---				4.- Trips using ('LLD')  = 'DWS' when the TOTAL CATCH WEIGHT of 'DWS' > HALF of TOTAL CATCH WEIGHT of 'DEF'
	--------------------------------------------------------
	
	-- select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('LLD') group by maxwgt order by count;
	-- select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('LLD') group by maxval order by count;

	--- Condition 1: 
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DEF' 
	from	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('LLD')  
			)b 
	where a.ft_ref = b.ft_ref 
	and a.dcf_gearcode = b.dcf_gearcode 
	and a.le_div = b.le_div;	 
	
	--- Condition 2: 
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'LPF'
			---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select   a.ft_Ref  , a.dcf_gearcode,a.le_div,  lekg_sum_def,lekg_sum_lpf  
				from 	( 
							select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_lpf
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('LLD') 
								and taxa = 'LPF' 
						)a 
				left join ( 
							select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_def
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('LLD') 
								and taxa = 'DEF' 
						)b 
				on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
					and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				where lekg_sum_lpf > lekg_sum_def 
			) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div;
	
	--- Condition 3: 
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'SPF'
			---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
					select  a.ft_Ref , a.dcf_gearcode , a.le_div,  lekg_sum_def,lekg_sum_spf  
					from 	( 
								select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_spf
								from eflalo_metiers.voyage_taxa_stats 
								where dcf_gearcode IN ('LLD') 
									and taxa = 'SPF' 
							)a 
				    left join ( 
								select distinct ft_Ref, dcf_gearcode,le_div,lekg_sum*0.5 lekg_sum_def 
								from eflalo_metiers.voyage_taxa_stats 
								where dcf_gearcode IN ('LLD') 
									and taxa = 'DEF' 
								)b 
				    on  a.ft_ref = b.ft_ref 
						and a.dcf_gearcode = b.dcf_gearcode 
						and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				    where lekg_sum_spf > lekg_sum_def 
			) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode 
			and a.le_div = b.le_div;


	--- Condition 4: 

	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS'
			---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select  a.ft_Ref , a.dcf_gearcode , a.le_div,  lekg_sum_def,lekg_sum_dws  
				from ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('LLD') 
						and taxa = 'DWS' 
				)a 
				left join ( 
						select distinct ft_Ref, dcf_gearcode,le_div,lekg_sum*0.5 lekg_sum_def 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('LLD') 
						and taxa = 'DEF' 
				)b 
				on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
					and a.le_div = b.le_div
				-- condition to apply to targeted assemblage 
				where lekg_sum_dws > lekg_sum_def 
			) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode 
		and a.le_div = b.le_div;
	
	
	
	

	--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ;  	
	
  	
	---------------------------------------------------------
	--- MID WATER OTTERS 
	--- Permitted: SPF and  DEF (It has additional UK metier by species) 
	--- Conditions: 1.- Trips using ('OTM')  = 'SPF'  
	---				2.- Trips using ('OTM')  = 'DEF' when the TOTAL CATCH WEIGHT of 'DEF' > HALF of TOTAL CATCH WEIGHT  
	--------------------------------------------------------
	
	-- select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('OTM') group by maxwgt order by count;
	-- select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('OTM') group by maxval order by count;

	--- Condition 1:
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'SPF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode , le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTM')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;	 
	
	--- Condition 2:

	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DEF'
			---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select   a.ft_Ref , a.dcf_gearcode , a.le_div,  lekg_sum_def,halftotwgt  
				from ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_def 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('OTM') 
							and taxa = 'DEF' 
					)a 
				left join ( 
						select distinct ft_Ref, dcf_gearcode,le_div,  halftotwgt halftotwgt
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('OTM') 
					)b 
				on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode  
					and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				where lekg_sum_def > halftotwgt 
			) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	
	
	--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ; 



 
	---------------------------------------------------------
	--- MID WATER PAIR and PURSE SEINE  
	--- Permitted: SPF and  LPF   
	--- Conditions: 1.- Trips using ('PRM', 'PS')  = 'SPF'  
	---				2.- Trips using ('PRM', 'PS')  = 'LPF' when the TOTAL CATCH WEIGHT of 'LPF' >   TOTAL CATCH WEIGHT   of 'SPF'
	--------------------------------------------------------
	
	
	-- select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('PTM','PS') group by maxwgt order by count;
	-- select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('PTM', 'PS') group by maxval order by count;

	-- Condition 1: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'SPF' 
	from 	(
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('PTM', 'PS')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	-- Condition 2: 

	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'LPF'
			---- Creates two subsets with the taxa categories to compare their weights 
	from (  	select   a.ft_Ref , a.dcf_gearcode ,a.le_div,   lekg_sum_lpf,lekg_sum_spf  
				from 	( 
							select distinct ft_Ref, dcf_gearcode,le_div,  lekg_sum lekg_sum_lpf 
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('PTM', 'PS') 
							and taxa = 'LPF' 
						)a 
				left join ( 
							select distinct ft_Ref, dcf_gearcode,le_div,  lekg_sum lekg_sum_spf
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('PTM', 'PS')  AND taxa = 'SPF'
						)b 
				on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
					and a.le_div = b.le_div   
				  -- condition to apply to targeted assemblage 
				where lekg_sum_lpf > lekg_sum_spf ) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	
	
--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ; 	
	


 	---------------------------------------------------------
	--- POTS and TRAPS 
	--- Permitted: CRU, MOL and  FIF  
	--- Conditions: 1.- Trips using ('FPO')  = 'FIF' 
	---				2.- Trips using ('FPO')  = 'CRU' when the MAXIMUM CATCH VALUE IN  ('CRU','CRUDWS')
	---				3.- Trips using ('FPO')  = 'MOL' when the MAXIMUM CATCH VALUE IN  ('MOL')	
	---				4.- Trips using ('FPO')  = 'MOL' when the TOTAL CATCH VALUE of ('CRU,'MOL') >=  HALF of TOTAL CATCH VALUE 
	---												and TOTAL CATCH VALUE of ('MOL') >= TOTAL CATCH VALUE of ('CRU') 
	---				5.- Trips using ('FPO')  = 'CRU' when the TOTAL CATCH VALUE of ('CRU,'MOL') >=  HALF of TOTAL CATCH VALUE 
	---												and TOTAL CATCH VALUE of ('MOL') < TOTAL CATCH VALUE of ('CRU') 	
	--------------------------------------------------------
	--select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('FPO') group by maxwgt order by count;
	--select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('FPO') group by maxval order by count;

	 -- Condition 1: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'FIF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('FPO')  
			) b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
 	-- Condition 2: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'CRU' 
	from 	( 
				select distinct  ft_Ref, dcf_gearcode, le_div  
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('FPO') 
					and maxval IN ('CRU','CRUDWS')  
				)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;

	-- Condition 3:
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'MOL' 
	from 	(
				select distinct  ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('FPO') 
					and maxval IN ('MOL')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;

	-- Condition 4:	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'MOL'
			---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select   a.ft_Ref  , a.dcf_gearcode, a.le_div,  leeuro_sum_mol_cru,halftotval , leeuro_sum_mol, leeuro_sum_cru
				from 	( 
							select distinct ft_Ref, dcf_gearcode, le_div,sum(leeuro_sum) leeuro_sum_mol_cru 
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('FPO') 
							AND taxa IN ('MOL' , 'CRU' )
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
							where dcf_gearcode IN ('FPO')   
								and taxa = 'MOL'
						) c  
				on  b.ft_ref = c.ft_ref and b.dcf_gearcode = c.dcf_gearcode
				left join ( 
							select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_cru  
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('FPO')   AND taxa = 'CRU'
						) d 
				on  c.ft_ref = d.ft_ref 
					and c.dcf_gearcode = d.dcf_gearcode
				  -- condition to apply to targeted assemblage 
				 where leeuro_sum_mol_cru  >= halftotval AND leeuro_sum_mol >= leeuro_sum_cru 
			) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;

	-- Condition 5:	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'CRU'
			---- Creates two subsets with the taxa categories to compare their weights 
	from (  	
				select   a.ft_Ref , a.dcf_gearcode , a.le_div, leeuro_sum_mol_cru,halftotval , leeuro_sum_mol, leeuro_sum_cru
				from 	( 
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
				on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
					and a.le_div = b.le_div
				left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_mol  
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('FPO')   AND taxa = 'MOL'
				) c  
				on  b.ft_ref = c.ft_ref 
					and b.dcf_gearcode = c.dcf_gearcode
				left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_cru  
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('FPO')   AND taxa = 'CRU'
				) d 
				on  c.ft_ref = d.ft_ref 
				and c.dcf_gearcode = d.dcf_gearcode
				  -- condition to apply to targeted assemblage 
				where leeuro_sum_mol_cru  >= halftotval 
					and leeuro_sum_mol < leeuro_sum_cru ) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	
	

		--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ; 	
	
	
	
	
	


 	---------------------------------------------------------
	--- BOTTOM PAIR TRAWLERS
	--- Permitted: DEF, CRU and  SPF  
	--- Conditions: 1.- Trips using ('PTB')  = 'CRU' 
	---				2.- Trips using ('PTB')  = 'DEF' when the MAXIMUM CATCH WEIGHT IN  ('DEF')
	---				3.- Trips using ('PTB')  = 'SPF' when the MAXIMUM CATCH WEIGHT IN  ('SPF')	
	---				4.- Trips using ('PTB')  = 'DEF' when the MAXIMUM CATCH VALUE IN  ('DEF')
	--------------------------------------------------------
 	
	-- select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('PTB') group by maxwgt order by count;
	-- select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('PTB') group by maxval order by count;

	--- Condition 1: 	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'CRU' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('PTB')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode 
		and a.le_div = b.le_div;
	
 	--- Condition 2:
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DEF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('PTB') AND maxwgt IN ('DEF')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	--- Condition 3:
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'SPF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('PTB') AND maxwgt IN ('SPF')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	--- Condition 4:
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DEF' 
	from ( 
			select distinct ft_Ref, dcf_gearcode, le_div 
			from eflalo_metiers.voyage_taxa_stats 
			where dcf_gearcode IN ('PTB') AND maxval IN ('DEF')  
		)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	

		--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ; 	
	
 

 
 	--------------------------------------------------------------------------------------------------------------------------------------------
	--- BSET GILL NETS 
	--- Permitted: DEF, CRU, DWS and  SPF  
	--- Conditions: 1.- Trips using ('GNS')  = 'CRU' 
	---				2.- Trips using ('GNS')  = 'DEF' when the MAXIMUM CATCH WEIGHT IN  ('DEF')
	---				3.- Trips using ('GNS')  = 'SPF' when the MAXIMUM CATCH WEIGHT IN  ('SPF')	
	---				4.- Trips using ('GNS')  = 'DWS' when the MAXIMUM CATCH WEIGHT IN  ('DWS')
	---				5.- Trips using ('GNS')  = 'DWS' when the MAXIMUM CATCH WEIGHT IN  ('DWS') > HALF of MAXIMUM CATCH WEIGHT IN  ('DEF') 
	---												 and trip using GNS already defined as DEF in Condition 1		
	---				6.- Trips using ('GNS')  = 'DWS' when the MAXIMUM CATCH VALUE IN  ('DWS') > HALF of MAXIMUM CATCH VALUE IN  ('DEF') 
	---												 and trip using GNS already defined as DEF in Condition 1	
	---				7.- Trips using ('GNS')  = 'DWS' when the MAXIMUM CATCH VALUE IN  ('DWS') > HALF of MAXIMUM CATCH VALUE IN  ('CRU') 
	---												 and trip using GNS already defined as DEF in Condition 1)
	---				8.- Trips using ('GNS')  = 'DWS' when the MAXIMUM CATCH WEIGHT IN  ('DWS') > HALF of MAXIMUM CATCH VALUE IN  ('SPF', 'LPF') 
	---												 and trip using GNS already defined as DEF in Condition 1)
	--------------------------------------------------------------------------------------------------------------------------------------------
	
	-- select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('GNS') group by maxwgt order by count;
	-- select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('GNS') group by maxval order by count;
 
	--- Condition 1: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'CRU' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('GNS')  
			)b 
	where a.ft_ref = b.ft_ref 
	and a.dcf_gearcode = b.dcf_gearcode 
	and a.le_div = b.le_div;
	
 	--- Condition 2: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DEF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('GNS') AND maxwgt IN ('DEF')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	--- Condition 3: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'SPF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('GNS') AND maxwgt IN ('SPF')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	--- Condition 4: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('GNS') AND maxwgt IN ('DWS')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	--- Condition 5: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS'
			---- Creates two subsets with the taxa categories to compare their weights 
	from 	( 
				select   a.ft_Ref  , b.dcf_gearcode, a.le_div,   lekg_sum_def,lekg_sum_dws  
				from ( 
						select distinct ft_Ref, dcf_gearcode, le_div,lekg_sum lekg_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS') 
							and taxa = 'DWS' 
					)a 
				left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,lekg_sum lekg_sum_def
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS')  
							and taxa = 'DEF'
				)b 
				on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				where lekg_sum_dws > lekg_sum_def*0.5 
					and a.ft_ref IN ( 
										select ft_ref 
										from eflalo_metiers.voyage_target_taxa 
										where target_taxa = 'DEF'
									)
			) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	--- Condition 6: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS'
			---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select   a.ft_Ref , a.dcf_gearcode , a.le_div, leeuro_sum_def,leeuro_sum_dws  
				from 	( 
							select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_dws
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('GNS') 
								and taxa = 'DWS' 
						)a 
				left join ( 
							select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_def
							from eflalo_metiers.voyage_taxa_stats 
							where dcf_gearcode IN ('GNS')  
								and taxa = 'DEF'
						)b 
				on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
						and a.le_div = b.le_div
					  -- condition to apply to targeted assemblage 
				where leeuro_sum_dws > leeuro_sum_def*0.5 
					AND a.ft_ref IN ( 
										select ft_ref 
										from eflalo_metiers.voyage_target_taxa 
										where target_taxa = 'DEF'
									)
			) b
	where a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode  and a.le_div = b.le_div;
	
	--- Condition 7: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS'
		---- Creates two subsets with the taxa categories to compare their weights 
	from (  	select   a.ft_Ref , a.dcf_gearcode   ,a.le_div, leeuro_sum_cru,leeuro_sum_dws  
				from ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS') 
							and taxa = 'DWS' 
					)a 
				left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_cru
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS')  
							and taxa = 'CRU'
					)b 
				on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
					and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				where leeuro_sum_dws > leeuro_sum_cru*0.5
					and a.ft_ref IN ( 
										select ft_ref 
										from eflalo_metiers.voyage_target_taxa 
										where target_taxa = 'CRU'
									)
			 ) b
   where a.ft_ref = b.ft_ref 
	and a.dcf_gearcode = b.dcf_gearcode  
	and a.le_div = b.le_div;
   
   
   --- Condition 8: 
   	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS'
		---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select   a.ft_Ref , a.dcf_gearcode   ,a.le_div,  lekg_sum_dws,lekg_sum_spf_lpf  
				from 	( 
						select distinct ft_Ref, dcf_gearcode, le_div,lekg_sum lekg_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS') 
							and taxa = 'DWS' 
						)a 
				left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div,sum(lekg_sum) lekg_sum_spf_lpf
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('GNS')  
							and taxa IN ('SPF', 'LPF')
						group by ft_Ref, dcf_gearcode, le_div
				)b 
				on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
					and a.le_div = b.le_div

			  -- condition to apply to targeted assemblage 
				where lekg_sum_dws > lekg_sum_spf_lpf*0.5 
					AND a.ft_ref IN ( 
										select ft_ref 
										from eflalo_metiers.voyage_target_taxa 
										where target_taxa = 'SPF'
									)
			) b
   where a.ft_ref = b.ft_ref 
	and a.dcf_gearcode = b.dcf_gearcode  
	and a.le_div = b.le_div;
	
	
	

	--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ; 	
	
 

 	---------------------------------------------------------
	--- BEAM TRAWLERS
	--- Permitted: DEF and  CRU   
	--- Conditions: - Trips using ('TBB' )  = 'DEF'  
	---				- Trips using ('TBB' )  = 'CRU' when the MAXIMUM CATCH VALUE of ('CRU', 'CRUDW')    
	--------------------------------------------------------
		
	-- select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('TBB') group by maxwgt order by count;
	-- select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('TBB') group by maxval order by count;

	-- Condition 1: 
	update eflalo_metiers.voyage_target_taxa a set target_taxa = 'DEF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('TBB')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
			and a.le_div = b.le_div;
			
	
	 	
	-- Condition 2: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'CRU' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('TBB') 
					AND maxval IN ('CRU', 'CRUDW')  
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;

	--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ; 	
	

 

 	--------------------------------------------------------------------------------------------------------------------------------------------
	--- BOTTOM OTTER and MULTI RIG OTTER TRAWLS
	--- Permitted: CRU, MOL 
	--- Conditions: 1.- Trips using ('OTB', 'OTT')  = 'CRU' when the MAXIMUM CATCH VALUE IN  ('CRU', 'CRUDW') 
	---				2.- Trips using ('OTB', 'OTT')  = 'MOL' when the MAXIMUM CATCH VALUE IN  ('MOL', 'CEP') 
	---				3.- Trips using ('OTB', 'OTT')  = 'DEF' when the MAXIMUM CATCH WEIGHT IN  ('DEF') 
	---				4.- Trips using ('OTB', 'OTT')  = 'SPF' when the MAXIMUM CATCH WEIGHT IN   ('SPF','LPF')
	---				5.- Trips using ('OTB', 'OTT')  = 'DEF' when the MAXIMUM CATCH VALUE IN   ('DEF')
	---				6.- Trips using ('OTB', 'OTT')  = 'SPF' when the MAXIMUM CATCH VALUE IN   ('SPF','LPF')

	 
	---				7.- Trips using ('OTB', 'OTT')  = 'DWS' when the TOTAL CATCH WEIGHT IN  ('DWS') > HALF of TOTAL CATCH WEIGHT IN  ('DEF') 
	---												 and trip using ('OTB', 'OTT') already defined as DEF in Condition 3 and 5		
	---				8.- Trips using ('OTB', 'OTT')  = 'DWS' when the TOTAL CATCH VALUE IN  ('DWS') > HALF of TOTAL CATCH VALUE IN  ('DEF') 
	---												 and trip using ('OTB', 'OTT') already defined as DEF in Condition 3 and 5	
	---				9.- Trips using ('OTB', 'OTT')  = 'DWS' when the TOTAL CATCH VALUE IN  ('DWS') > HALF of TOTAL CATCH VALUE IN  ('CRU') 
	---												 and trip using ('OTB', 'OTT') already defined as CRU in Condition 1	
	---				10.- Trips using ('OTB', 'OTT')  = 'DWS' when the TOTAL CATCH WEIGHT IN  ('DWS') > HALF of TOTAL CATCH WEIGHT IN  ('SPF','LPF') 
	---												 and trip using ('OTB', 'OTT') already defined as SPF in Condition 4 and 6	
	---				11.- Trips using ('OTB', 'OTT')  = 'SPF' when the MAXIMUM CATCH WEIGHT IN    ('SPF','LPF') 
	---												 and trip using ('OTB', 'OTT') and not defined target taxa (NULL)   	   
	--------------------------------------------------------------------------------------------------------------------------------------------

	
	-- select count(*), maxwgt from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('OTB', 'OTT') group by maxwgt order by count;
	-- select count(*), maxval from eflalo_metiers.voyage_taxa_stats where dcf_gearcode IN ('OTB', 'OTT') group by maxval order by count;

 
	--- Condition 1: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'CRU' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') 
					AND maxval IN ('CRU', 'CRUDW') 
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
			
	--- Condition 2: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'MOL' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') 
					AND maxval IN ('MOL', 'CEP') 
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	 	
 
	--- Condition 2: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') 
					AND maxwgt IN ('DWS')
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
			
	--- Condition 3: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DEF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') 
					AND  maxwgt IN ('DEF')
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
			
			
	--- Condition 4: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'SPF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') 
					AND  maxwgt IN ('SPF','LPF')
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;		
 
	
	--- Condition 5: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DEF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') 
					AND  maxval IN ('DEF') 
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;		
 
	--- Condition 6: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'SPF' 
	from 	( 
				select distinct ft_Ref, dcf_gearcode, le_div 
				from eflalo_metiers.voyage_taxa_stats 
				where dcf_gearcode IN ('OTB', 'OTT') 
					AND  maxval IN ('SPF') 
			)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div; 
 
	
 
	--- Condition 7: 
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS'
	---- Creates two subsets with the taxa categories to compare their weights 
	from ( 
			select   a.ft_Ref  , a.dcf_gearcode, a.le_div,  lekg_sum_dws,lekg_sum_def  
			from 	( 
						select distinct ft_Ref, dcf_gearcode, le_div,lekg_sum lekg_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('OTB', 'OTT') 
							AND taxa = 'DWS' 
					)a 
			left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div, lekg_sum  lekg_sum_def
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('OTB', 'OTT')  
							AND taxa IN ('DEF')
				 
					)b 
			using (ft_ref)
		  -- condition to apply to targeted assemblage 
			where lekg_sum_dws > lekg_sum_def*0.5 
				AND a.ft_ref IN ( 
								select ft_ref 
								from eflalo_metiers.voyage_target_taxa 
								where target_taxa = 'DEF'
								)
		 ) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	
	
	--- Condition 8: 
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS'
	---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select   a.ft_Ref  , b.dcf_gearcode ,a.le_div,   leeuro_sum_dws,leeuro_sum_def  
				from ( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('OTB', 'OTT') 
							AND taxa = 'DWS' 
					)a 
				left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div, leeuro_sum  leeuro_sum_def
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('OTB', 'OTT')  
							AND taxa IN ('DEF')
				 
				)b 
				 on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
					and a.le_div = b.le_div

		  -- condition to apply to targeted assemblage 
			 where leeuro_sum_dws > leeuro_sum_def*0.5 
				AND a.ft_ref IN ( 
								select ft_ref 
								from eflalo_metiers.voyage_target_taxa 
								where target_taxa = 'DEF'
								)
		 ) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	--- Condition 9:
	
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS'
	---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select  a.ft_Ref  , b.dcf_gearcode,a.le_div,  leeuro_sum_dws,leeuro_sum_cru  
				from 	( 
						select distinct ft_Ref, dcf_gearcode, le_div,leeuro_sum leeuro_sum_dws
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('OTB', 'OTT') AND taxa = 'DWS' 
				)a 
				left join ( 
						select distinct ft_Ref, dcf_gearcode, le_div, leeuro_sum  leeuro_sum_cru
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode IN ('OTB', 'OTT')  AND taxa IN ('CRU')
					 
				)b 
				on  a.ft_ref = b.ft_ref 
					and a.dcf_gearcode = b.dcf_gearcode 
					and a.le_div = b.le_div

			  -- condition to apply to targeted assemblage 
				 where leeuro_sum_dws > leeuro_sum_cru*0.5 
					AND a.ft_ref IN ( 
										select ft_ref 
										from eflalo_metiers.voyage_target_taxa 
										where target_taxa = 'CRU'
									)
		 ) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode 
		and a.le_div = b.le_div;
	
	--- Condition 10: 
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'DWS'
	---- Creates two subsets with the taxa categories to compare their weights 
	from 	(  
				select   a.ft_Ref  ,a.dcf_gearcode, a.le_div,   lekg_sum_dws,lekg_sum_spf_lpf  
				from ( 
					select distinct ft_Ref, dcf_gearcode, le_div,lekg_sum lekg_sum_dws
					from eflalo_metiers.voyage_taxa_stats 
					where dcf_gearcode IN ('OTB', 'OTT') 
						AND taxa = 'DWS' 
				)a 
				left join ( 
					select distinct ft_Ref, dcf_gearcode, le_div, sum(lekg_sum)  lekg_sum_spf_lpf
					from eflalo_metiers.voyage_taxa_stats 
					where dcf_gearcode IN ('OTB', 'OTT')  
						AND taxa IN ('SPF','LPF')
					group by ft_Ref, dcf_gearcode, le_div				 
				)b 
				  on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div

			  -- condition to apply to targeted assemblage 
				 where lekg_sum_dws > lekg_sum_spf_lpf*0.5 
					AND a.ft_ref IN ( 
										select ft_ref 
										from eflalo_metiers.voyage_target_taxa 
										where target_taxa = 'SPF'
									)
			) b
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	
	
	--- Condition 11:
	update eflalo_metiers.voyage_target_taxa a 
	set target_taxa = 'SPF' 
	from ( 
			select distinct ft_Ref, dcf_gearcode, le_div 
			from eflalo_metiers.voyage_taxa_stats 
			where dcf_gearcode IN ('OTB', 'OTT') 
				AND maxval IN ('SPF','LPF') 
				AND ft_ref IN 	( 	
									select ft_ref 
									from eflalo_metiers.voyage_target_taxa 
									where target_taxa IS NULL
								) 
		)b 
	where a.ft_ref = b.ft_ref 
		and a.dcf_gearcode = b.dcf_gearcode  
		and a.le_div = b.le_div;
	

	--- STATS of ASSIGNED TARGET ASSEMBLAGE TAXAS: 

		select DISTINCT target_taxa, round( count(*) over(PARTITION BY target_taxa) / count(*) over( )::numeric , 2)   prop 
		from eflalo_metiers.voyage_target_taxa ; 	






------------------------------------------------
----- ANALYSE WHAT HAS NOT A METIER ASSIGNED ---
------------------------------------------------
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




	


	 
