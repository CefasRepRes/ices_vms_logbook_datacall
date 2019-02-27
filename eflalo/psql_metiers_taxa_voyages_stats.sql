ccreate table eflalo_metiers.voyage_taxa_stats as 
  

with daf as ( 
	select "FT_REF" ft_ref,"LE_GEAR" le_gear,  b.taxa , "LE_KG" le_kg, "LE_EURO" le_euro  
	from 
	( select * from eflalo.eflalo_2018   ) a
	left join fish_metadata.ifishspptab b 
    on a."LE_SPE" = b."eflalo_ifishcode" 
) , 

daf_agg as (
	 select ft_ref, 
	 case 
	 when le_gear IN ('GN', 'GNC' ) THEN 'GNS' 
	 when le_gear IN ('LL', 'LX' ) THEN 'LLS'
	 when le_gear IN ('TB', 'TBN') THEN 'OTB'
	 when le_Gear IN ('MIS', 'NK', 'HF') THEN 'MIS'
	 when le_gear = 'SV' THEN 'SSC'
	 when le_gear = 'LHM' THEN 'LHP'
	 when le_gear = 'FIX' THEN 'FPO'
	 ELSE le_gear 
	 end as le_gear, 	
	 taxa, le_kg, le_euro  
	 from daf 
)
 
 --- Quality Control of gears and taxat groups ------
 
/* , gears_possible as (
 select count(*),  le_gear from daf_agg  where le_gear NOT IN ('NOG','OTH','DRB','HMD','LLS','GTR','SSC','SDN','SPR','LHP',
 'LTL','SB','FYK','GND','LLD','OTM','PTM','PS','GNS','FPO','TBB','PTB','OTT','OTB', 'MIS')
group by le_gear  ), 
taxa_possible ( 
select count(*) , taxa from daf where taxa not in ('DWS','DEF','CEP','CRU','LPF','MOL','SPF' ) group by taxa ) */

select a.*, lekg_sum*0.5 halfTotWgt, leeuro_sum*0.5 halfTotVal, b.halfDEFWT, last_value(taxa) over wnd_kg as maxwgt, last_value(taxa) over wnd_val as maxval
from ( 
	select ft_Ref,le_gear, taxa, sum(le_kg) lekg_sum, sum(le_euro) leeuro_sum  
	from daf 
	group by ft_ref,le_gear,  taxa 
 	) a 
left join (
	select ft_Ref ,le_gear, sum(le_kg)*0.5 halfDEFWT   
	from daf 
	where taxa = 'DEF' 
	group by ft_ref ,le_gear  
	) b
 using (ft_Ref,le_gear)
 
 WINDOW wnd_kg as( 
 	PARTITION BY ft_ref, le_gear ORDER BY lekg_sum
   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
 ),   wnd_val as( 
 	PARTITION BY ft_ref,le_gear ORDER BY leeuro_sum
   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
 )
 
 -- List of gears not in metiers script possible gears:  "GN", "NK" , "RG" , "TB", "TBN","LL","MIS","GNC", "SV", "LX" ,"FIX", "HF", "LHM"
