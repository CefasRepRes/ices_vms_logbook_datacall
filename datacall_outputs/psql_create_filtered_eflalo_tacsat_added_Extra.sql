 create schema eflalo_filter ; 

 
drop table tacsat_filter.tacsat_2018; 
create table tacsat_filter.tacsat_2018 as 
           with   a AS ( select distinct  ifish_code from fish_metadata.ifish_gears where ifish_code IN   ( 'GEN', 'GN','GNC','GND','GNF','GNS','GTN','GTR','DRB','DRH','OTB','OTT','OT','PTB','TBB','TBN','TX', 'HMD', 'FPO') ), 
                                              b AS ( select distinct  ifish_code from fish_metadata.ifish_gears where ifish_code NOT IN    ( 'GEN', 'GN','GNC','GND','GNF','GNS','GTN','GTR','DRB','DRH','OTB','OTT','OT','PTB','TBB','TBN','TX', 'HMD', 'FPO') )
                                              
                                              
                                              select a.*, b."LE_GEAR", depth_m  from ( 
                                              SELECT o."VE_REF",o."SI_LATI",o."SI_LONG",o."SI_DATE"::text ,o."SI_TIME",o."SI_SP",o."SI_HE",o."SI_HARB",o."SI_STATE",o."SI_FT",
                                              o."SI_DATIM"::text ,o."INTV",o."gid" , o.geom
                                              FROM tacsat_2018  As o where gid in
                                              (
                                              select DISTINCT gid 
                                              from tacsat.metadata_2018  
                                              where duplicate IS FALSE  and  in_port IS FALSE 
                                              AND in_land IS FALSE AND  f_state = 'f' AND f_state_cond  IS TRUE  AND depth_m < 0 
                                              AND (  depth_m > -2000  
                                              OR  ( depth_m < -2000  AND "LE_GEAR" IN (select * from b ))  
                                              )      
                                              )
                                              ) a left join tacsat.metadata_2018  b on a.gid = b.gid; 



drop table eflalo_filter.eflalo_2018; 

create table eflalo_filter.eflalo_2018  as 

                                             SELECT DISTINCT o."VE_REF",o."VE_FLT",o."VE_COU",o."VE_LEN",o."VE_KW",o."VE_TON",o."FT_REF",o."FT_DCOU",o."FT_DHAR",
                                              o."FT_DDAT"::text,o."FT_DTIME",o."FT_LCOU",o."FT_LHAR",o."FT_LDAT"::text,o."FT_LTIME",o."LE_ID",o."LE_CDAT"::text,o."LE_STIME",o."LE_ETIME",
                                              o."LE_SLAT",o."LE_SLON",o."LE_ELAT",o."LE_ELON",o."LE_GEAR",o."LE_MSZ",o."LE_RECT",o."LE_DIV",o."LE_MET",
                                              total_le_id_kg, total_le_id_eur, total_ft_ref_kg, total_ft_ref_eur, "FT_DDATIM"::text, "FT_LDATIM"::text 
                                              FROM eflalo.eflalo_2018 As o where id IN (
							select id 
							from eflalo.metadata_2018 
							where ft_ref_with_vms IS TRUE AND  duplicate IS FALSE 
                                              ) 



--- we have identified that after clean and filter the fishign activty TACSAT , there are many trips in EFALO with associated VMS however
--- no one VMS poitn was selected as fishing during these trips for several reason.
--- with the following script we are trying to add the most of those VMS points that arent selected as fishign for been out of speed thresholds
--- for a minimum difference. 




--- 1st step is to select the excluded trips 
 

drop table  tacsat_filter.tacsat_2018_added ; 


  create table tacsat_filter.tacsat_2018_added  as 
 
     with a as( 
		-- selcet those trips are in logbook but having associated VMS but they arent selected as fishing 
	       select DISTINCT "FT_REF" from eflalo_filter.eflalo_2018                                               
	      EXCEPT
		   select DISTINCT "SI_FT" from tacsat_filter.tacsat_2018 
	) , 
	b as ( 
			-- select all VMS points between previous speed threshold +-1  for those subselected trips  

	select * from ( select aaa.* , bbb."LE_GEAR", min_speed_f-1 min_sp, max_speed_f+2 max_sp from ( select * from tacsat.tacsat_2018 where  "SI_FT" IN (  select DISTINCT "SI_FT" from excluded_vms )  )  aaa
	 inner join tacsat.metadata_2018 bbb on aaa.gid =bbb.gid )  aa 
	 where   "SI_SP" between  min_sp and max_sp 
	

	)  , 
	c as (  select b.*, in_port, ices_Rect_Real From b  
			inner join tacsat.metadata_2018 using (gid)  )  ,

	d as  (     select distinct c.gid  from c  inner join marine_regions.mmo_landing_ports_2km_buff e
			on st_intersects(c.geom, e.geom )            ) 

	select "gid", "VE_REF","SI_LATI","SI_LONG","SI_DATE","SI_TIME","SI_DATIM",
		"SI_SP","SI_HE","SI_HARB","SI_STATE","SI_FT","INTV","geom"
		 from c   where in_port is false and ices_Rect_Real IS NOT NULL
	union 
	select "gid", "VE_REF","SI_LATI","SI_LONG","SI_DATE","SI_TIME","SI_DATIM",
		"SI_SP","SI_HE","SI_HARB","SI_STATE","SI_FT","INTV","geom"
		from c where in_port is true and gid not in  ( Select distinct gid from d   ) and ices_Rect_Real IS NOT NULL


 
 

                                              


                                              
