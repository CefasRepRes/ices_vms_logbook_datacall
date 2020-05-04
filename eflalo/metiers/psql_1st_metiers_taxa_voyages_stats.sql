 ------- 1st script to create metiers within SQL database --------

 /* This script create the table voyage_taxa_stats that sum the catch and value by DCF target assemblage and
  calculate extra fields to support the identification of the TRIP tTARGETED ASSAMBLAGE   */


 --- Dependencies : 
 
	-- Eflalo dataset
	-- fish_metadata.ifishspptab   // This table has a extra field caled eflalo_ifishcode that match the species with speceis 
							--// aggregation done when eflalo dataset was created 
	-- fish_metadata.ifishgeartab


  
 
 --- CREATE TABLE eflalo_metiers.voyage_taxa_stats  WITH LANDING STATISTICS BY VOYAGE, GEAR TYPE AND ICES DIVISION : 
 

drop table eflalo_metiers.voyage_taxa_stats;
create table eflalo_metiers.voyage_taxa_stats as   

with eflalo as ( 
	select ft_Ref, le_gear, le_div , le_spe ,  le_kg, le_euro
	from   eflalo2.eflalo_ft a
	left join eflalo2.eflalo_le b   
	on ft_year = 2019  and a.ft_Ref = b.eflalo_ft_ft_Ref
	left join eflalo2.eflalo_spe c
	on b.le_id = c.eflalo_le_le_id
) , 
daf as ( 
	select  ft_ref,  le_gear,   le_div,  b.taxa  ,      le_kg,   le_euro  , le_spe 
	from 
	 eflalo  a --     where "FT_REF" = '610266236'
	left join fish_metadata.ifishspptab b 
    on a.le_spe = b."eflalo_ifishcode"
    	
) , 

daf_agg as (
	 select DISTINCT ft_ref, 
	 case 
	 when le_gear IN ('GN', 'GNC', 'GEN' ) THEN 'GNS' 
	 when le_gear IN ('LL', 'LX' ) THEN 'LLS'
	 when le_gear IN ('TB', 'TBN') THEN 'OTB'
	 when le_Gear IN ('MIS', 'NK', 'HF', 'RG', 'DRH') THEN 'MIS'
	 when le_gear = 'SV' THEN 'SSC'
	 when le_gear = 'LHM' THEN 'LHP'
	 when le_gear = 'FIX' THEN 'FPO'
	  when le_gear = 'TM' THEN 'OTM'
	 ELSE le_gear 
	 end as le_gear, 
	 le_div,	
	 taxa, le_kg, le_euro  
	 from daf 
), 

daf_agg_dcf as ( 
	select ft_Ref,  le_Gear,  c."DCFcode" dcf_gearcode, le_div, taxa, le_kg, le_euro 
	from daf_agg a 	
	left join  fish_metadata.ifishgeartab c
	on le_Gear = "iFishCode" 
)  

  
select a.*, sum(lekg_sum) over ( partition by ft_ref)*0.5 halfTotWgt, sum(leeuro_sum) over(partition by ft_ref)*0.5 halfTotVal,
	b.halfDEFWT, last_value(taxa) over wnd_kg as maxwgt, last_value(taxa) over wnd_val as maxval
from ( 
	select ft_Ref, dcf_gearcode,  le_div,taxa as taxa,  sum(le_kg) lekg_sum, sum(le_euro) leeuro_sum  
	from daf_agg_dcf 
	group by ft_ref, dcf_gearcode,   le_div,taxa 
 	) a 
left join (
	select ft_Ref , dcf_gearcode,   le_div, sum(le_kg)*0.5 halfDEFWT   
	from daf_agg_dcf 
	where taxa = 'DEF' 
	group by ft_ref, dcf_gearcode  , le_div
	) b
 using (ft_Ref,   dcf_gearcode, le_div) 

 WINDOW wnd_kg as( 
 	PARTITION BY ft_ref, dcf_gearcode,   le_div  ORDER BY lekg_sum
  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
 ),   wnd_val as( 
 	PARTITION BY ft_ref, dcf_gearcode,   le_div ORDER BY leeuro_sum
   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
 )

 
/*  UPDATE AUXILIARY TABLES WITH DATA IN EFLALO   */

--------------------------------------------------------
--- SPECIES TABLE : fish_metadata.ifishspptab----
--------------------------------------------------------

 ---- Add the colum with the majority taxa group that the aggregated species column built in eflalo  belongs to.
 --- Issue:  was that when we have aggregated severla species in more general cateroiers ( e.g. RAJ  )  some of them belong to different taxas . 
 --- Solution:  select with is the most repeatd taxa categories in the nerw cratated species aggregation and select as the txa_group .
		 
		alter table fish_metadata.ifishspptab  add column eflalo_taxa_aggregated varchar ( 10 ) ; 

		with a as ( 
		 select count(*) count_t, eflalo_ifishcode , taxa from fish_metadata.ifishspptab  
		  group by eflalo_ifishcode, taxa 
		 order by eflalo_ifishcode, taxa ,count_t DESC 
		 ) , 
		 b as (  select DISTINCT first_value(taxa) over(  partition  by eflalo_ifishcode order by count_t DESC ) taxa_group   ,  eflalo_ifishcode from a  ) 
		 
		 update fish_metadata.ifishspptab aa set eflalo_taxa_aggregated = taxa_group from b where aa.eflalo_ifishcode = b.eflalo_ifishcode; 


		select * from  fish_metadata.ifishspptab where "iFishCode" IN(  'BSS', 'HKE', 'BSH' , 'SWO') 

	 --- SPECIES IN EFLALO NOT PRESENT IN IFISHSPPTAB AUXILIARY TABLE 
		 
		with a as( 
		select DISTINCT "LE_SPE" le_spe from eflalo.eflalo_2018 
		EXCEPT
		select DISTINCT "eflalo_ifishcode" from  fish_metadata.ifishspptab 
		) , 
		b as ( select   *  from fish_metadata.species_code_fao where code_3a IN ( select * from a )  ) ,
		c as ( 
		select count(*) , "LE_SPE" from eflalo.eflalo_2018 where "LE_SPE" IN ( select code_3a from b )  group by "LE_SPE" 
		) 

		select * from b right join c on "LE_SPE" = code_3a 



		--- INSERT SPECIES IN EFLALO NOT PRESENT IN IFISHSPPTAB AUXILIARY TABLE 

		INSERT INTO fish_metadata.ifishspptab     
		select 'OCC' , 'Common Octopus',   'Common Octopus',  1,'Octopus vulgaris ', 'Mollusc', 0,  NULL, 'OCC' , 'Common Octopus',    140605 ,   'Octopus vulgaris ' , 'CEP', 'OCC'

		
		INSERT INTO fish_metadata.ifishspptab     
		select 'TBR' , 'Goldsinny-wrasse',  'Goldsinny-wrasse', 1,  'Ctenolabrus rupestris' , 'Demersal', 0,  NULL, 'TBR' , 'Goldsinny-wrasse',   126964  ,   'Ctenolabrus rupestris' , 'DEF', 'TBR'


		INSERT INTO fish_metadata.ifishspptab     
		select 'ENX' ,  'Rock cook',  'Rock cook' , 1, 'Centrolabrus exoletus' , 'Demersal', 0,  NULL, 'ENX' , 'Rock cook',   126961    ,   'Ctenolabrus exoletus' , 'DEF', 'ENX'


		INSERT INTO fish_metadata.ifishspptab     
		select 'YFM' , 'Corkwing wrasse', 'Corkwing wrasse' , 1,  'Symphodus melops' , 'Demersal', 0,  NULL, 'YFM' , 'Corkwing wrasse',   273571    ,   'Symphodus melops' , 'DEF', 'YFM'





--------------------------------------------------------
--- SPECIES TABLE : fish_metadata.ifishgeartab----
--------------------------------------------------------



---- MAJOR ISSUE: in the gear table supplied with Alastair Pout r script the Long Liners Drifters are with the code LLS insteafd of LLD . 
--- And the otehr way around with the LLD are in the DCFCode columns as LLS.
--UPDATE: Change DCFCode column LLD to LLS and the LLS to LLD. 

update fish_metadata.ifishgeartab set "DCFcode" = 'LLS' where "DCFcode" = 'LLD' and "iFishCode" = 'LL' and "desc" = '''m Set Longlines''' and "region" = 'all'; --line 11
update fish_metadata.ifishgeartab set "DCFcode" = 'LLD' where"DCFcode" = 'LLS' and "iFishCode" = 'LLD' and "desc" = '''l Drifting Longlines''' and region = 'NAL'; -- line 12 
update fish_metadata.ifishgeartab set "DCFcode" = 'LLS' where"DCFcode" = 'LLD' and "iFishCode" = 'LLS' and "desc" = '''m Set Longlines''' and region = 'all'; -- line 38
update fish_metadata.ifishgeartab set "DCFcode" = 'LLS' where "iFishCode" = 'LX' and "desc" = '''m Set Longlines''' and region = 'all'; -- line 45 
  
update fish_metadata.ifishgeartab set "desc" ='''l Drifting Longlines''' where "DCFcode" = 'LLD'  and  "desc" ='''m Set Longlines''' ;
update fish_metadata.ifishgeartab set "desc" ='''m Set Longlines''' where "DCFcode" = 'LLS'   and "desc" ='''l Drifting Longlines''' ;

select * from eflalo_metiers.voyage_taxa_stats where ft_Ref = 900010754078;


	
		--- others testing queries

		select * from fish_metadata.species_code_fao  where code_3a LIKE 'OC%'
		select * from  fish_metadata.ifishspptab  where    "eflalo_ifishcode"  LIKE 'OC%' 

		select * from   fish_metadata.ifishspptab  where "FAOname" LIKE '%nglerfis%'
		 

		select DISTINCT "LE_SPE" , "LE_GEAR" from eflalo.eflalo_2018 where "LE_SPE" IN ( 'YFM', 'TBR', 'ENX' ) 
		ORDER BY "LE_SPE", "LE_GEAR"


		select distinct "taxa" from fish_metadata.ifishspptab

		select * from   fish_metadata.ifishspptab where taxa = 'DEF'

 


  

 --- Quality Control of gears and taxat groups ------
 
/* , gears_possible as (
 select count(*),  le_gear from daf_agg  where le_gear NOT IN ('NOG','OTH','DRB','HMD','LLS','GTR','SSC','SDN','SPR','LHP',
 'LTL','SB','FYK','GND','LLD','OTM','PTM','PS','GNS','FPO','TBB','PTB','OTT','OTB', 'MIS')
group by le_gear  ), 
taxa_possible ( 
select count(*) , taxa from daf where taxa not in ('DWS','DEF','CEP','CRU','LPF','MOL','SPF' ) group by taxa ) */

 
 
 -- List of gears not in metiers script possible gears:  "GN", "NK" , "RG" , "TB", "TBN","LL","MIS","GNC", "SV", "LX" ,"FIX", "HF", "LHM"
 
 /* PIVOT TABLE 
 SELECT * FROM 
 crosstab ('select ft_ref, le_gear,  taxa, lekg_sum from eflalo_metiers.voyage_taxa_stats a where taxa IS NOT NULL order by 1, 2', 
		   'select distinct taxa from eflalo_metiers.voyage_taxa_stats where taxa IS NOT NULL'		                 		  
		  ) 
 AS final_result(ft_Ref bigint, le_gear varchar (20) , "CRUDWS" numeric, "CRU" numeric, "CEP" numeric, "NK" numeric , 
				 "SPF" numeric, "LPF" numeric, "MOL" numeric, "DWS" numeric, "SPFDWS" numeric , "DEF" numeric ) ;   
  
 */
