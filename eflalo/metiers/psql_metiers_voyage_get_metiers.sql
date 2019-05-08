 ------- 3rd script to create metiers within SQL database --------
 /* This script creates the final LEVEL 6 metier    */
 

 --- Dependencies : 
 
	--  TABLE: eflalo_metiers.voyage_taxa_stats;
	--  TABLE:  fish_metadata.statistical_area_codes ('areaCodes' table  supplied with Alaister Pout  R script  ) 
	--  TABLE: eflalo_metiers.metiers_tables_fao_areas_2019 (created in this script ) 

	select * from eflalo.eflalo_2018 limit 10 ; 

	select distinct "LE_DIV" from  eflalo.eflalo_2018  limit 100; 

	select * from fish_metadata.statistical_area_codes;



				
--- CREATE THE TABLE WITH METIERS DEFINED BY NORTH ATLANTIC REGIONS BY EU  REGIONAL GROUPS . 

--- the table will get the componetns of the RG groups table and split in the components : gera, target , and mesh size. 
-- Then the region column is homogenized with the FAO areas layer downloaded form FAO sites. 

drop  table eflalo_metiers.metiers_tables_fao_areas_2019; 
create table eflalo_metiers.metiers_tables_fao_areas_2019  as 

with a1 as ( 
	select *, split_part( metier_lvl6, '_',1) gear , split_part( metier_lvl6, '_', 2) target_taxa, 
	    split_part( split_part(  metier_lvl6  , '_', 3 ) , '-', 1  )  mesh_size_1, 
	    split_part( split_part(  metier_lvl6  , '_', 3 ) , '-', 2  )  mesh_size_2
	    from eflalo_metiers.metiers_tables_2019  
 ) , 
a as (  
	 select *,  
	 case 
		WHEN    position ( '>='  in mesh_size_1 ) > 0  THEN replace (  replace ( mesh_size_1  , '>' , '' ) , '=', '' ) 
		WHEN    position ( '>'  in mesh_size_1 ) > 0  THEN   (  replace ( mesh_size_1  , '>' , '' )::numeric + 1 )::varchar(50) 
		WHEN    position ( '<='  in mesh_size_1 ) > 0  THEN    '0' 
		WHEN    position ( '<'  in mesh_size_1 ) > 0  THEN   '0' 		
		ELSE  mesh_size_1 END as  min_mesh_size 
	  ,  
	 CASE 		
		WHEN position ( '<='  in mesh_size_1 ) > 0 THEN replace ( mesh_size_1  , '<=' , '' )  
		WHEN position ( '<'  in mesh_size_1 ) > 0 THEN replace ( mesh_size_1  , '<' , '' )  
		WHEN  mesh_size_1 = '0'  THEN   '0' 
		ELSE mesh_size_2 END as max_mesh_size
	 from a1
	  ) , b as ( 


select DISTINCT    le_div  ,"RDB" , "ICES",     "FAO", "REG" region , "Metier" metier from 
	 fish_metadata.statistical_area_codes right join (Select DISTINCT "AreaCode" le_div from a  ) b
	 ON	  "COST" = le_div OR "RDB" = le_div  OR
	 "ICES" = le_div OR
	 "FAO" =  le_div OR 
	 "REG" = le_div  OR 
	 "Metier" =   le_div
) , 
c as ( 
select * from  a left join b on le_div =  "AreaCode"   )  

select DISTINCT c.id, "AreaCode" as area_code , metier_lvl6, gear, target_taxa, min_mesh_Size, 
CASE WHEN  max_mesh_size = '' THEN '999'  ELSE max_mesh_size END as max_mesh_size , le_div,"RDB" rdb, "ICES" ices, "FAO" as fao , 
region ,metier, fid id_fao , f_Code, f_level, f_status, ocean, subocean , f_Area, f_subdivis,  f_subunit, name_en , surface 
from c left join  marine_regions.fao_divisions on le_div = f_code; 

---- FPO always starts with MESH SIZE 0 m INDEPENDENTLY THE METIERS SAYS >0 : 

update eflalo_metiers.metiers_tables_fao_areas_2019 set min_mesh_size =  0  where gear = 'FPO' ; 

--- Update the metiers table to acept metiers from the logbooks 

	--  insert metier PS target SPF with mesh size > 0  in area 27.7.e

	INSERT  INTO eflalo_metiers.metiers_tables_fao_areas_2019  VALUES  ( 
			197701, '27.7.e','PS_SPF_>0_0_0','PS','SPF','0','999','27.7.e','7e','VIIe','27.7.e','NAL','VIIe',269,'27.7.e','DIVISION',1,'Atlantic','2','27','','','Western English Channel (Division 27.7.e)',56394289620.29712,TRUE
		) 

		--  insert metier PS target SPF with mesh size > 0  in area 27.7.f

	INSERT  INTO eflalo_metiers.metiers_tables_fao_areas_2019  VALUES  ( 
		200681,'27.7.f','PS_SPF_>0_0_0','PS','SPF','0','999','27.7.f','7f','VIIf','27.7.f','NAL','VIIfgh',251,'27.7.f','DIVISION',1,'Atlantic','2','27','','','Bristol Channel (Division 27.7.f)',18973204582.244514, TRUE
		) 

			--  insert metier LLD target DEF with not defined mesh size(mesh size  = 0 )   inmultiple areas
			
INSERT  INTO eflalo_metiers.metiers_tables_fao_areas_2019  VALUES  ( 
999999,'27.1','LLD_0_0_0','LLD','DEF','0','0','27.1','1','I','27.1','NSEA','I..II',111,'27.1','SUBAREA',1,'Atlantic','2','27','','','Barents Sea (Subarea 27.1)',1623998509070.897, TRUE  ) , 
(999999,'27.2','LLD_0_0_0','LLD','DEF','0','0','27.2','2','I','27.2','NSEA','I..II',110,'27.1','SUBAREA',1,'Atlantic','2','27','','','Norwegian Sea, Spitzbergen, and Bear Island (Subarea 27.2)',2558079356750.975, TRUE  ) ,
(999999,'27.4','LLD_0_0_0','LLD','DEF','0','0','27.4','4','I','27.4','NSEA','I..II',110,'27.4','SUBAREA',1,'Atlantic','2','27','','','North Sea (Subarea 27.4)',615587341198.7509, TRUE),
(999999,'27.2.b','LLD_0_0_0','LLD','DEF','0','0','27.2.b','2.b','IIb','27.4','NSEA','I..II',266,'27.2.b','DIVISION',1,'Atlantic','2','27','','','Spitzbergen and Bear Island (Division 27.2.b)',1125175347881.7651, TRUE),
(999999,'27.2.a','LLD_0_0_0','LLD','DEF','0','0','27.2.a','2.a','IIa','27.2','NSEA','I..II',265,'27.2.a','DIVISION',1,'Atlantic','2','27','','','Norwegian Sea (Division 27.2.a)',1432904008869.2078, TRUE),
(999999,'27.4.b','LLD_0_0_0','LLD','DEF','0','0','27.4.b','4.b','IVb','27.4','NSEA','IV..VIId',265,'27.4.b','DIVISION',1,'Atlantic','2','27','','','Central North Sea (Division 27.4.b)',1432904008869.2078, TRUE),
(999999,'27.4.c','LLD_0_0_0','LLD','DEF','0','0','27.4.c','4.c','IVc','27.4','NSEA','IV..VIId',265,'27.4.c','DIVISION',1,'Atlantic','2','27','','','Southern North Sea (Division 27.4.c)',1432904008869.2078, TRUE),
(999999,'27.4.a','LLD_0_0_0','LLD','DEF','0','0','27.4.a','4.a','IVa','27.4','NSEA','IV..VIId',265,'27.4.a','DIVISION',1,'Atlantic','2','27','','','Northern North Sea (Division 27.4.a)',1432904008869.2078, TRUE),
(999999,'27.3.a','LLD_0_0_0','LLD','DEF','0','0','27.3.a','3.a','IIIa','27.3','NSEA','IIIa',265,'27.3.a','DIVISION',1,'Atlantic','2','27','','','Skagerrak and Kattegat (Division 27.3.a)',54944008753.23328 , TRUE),
(999999,'27.7.d','LLD_0_0_0','LLD','DEF','0','0','27.7.d','7.d','VIId','27.7','NSEA','IV..VIId',270,'27.7.d','DIVISION',1,'Atlantic','2','27','','','Eastern English Channel (Division 27.7.d)',33233427661.78289 , TRUE)

			--  insert metier GND target SPF with not defined mesh size actegories (mesh size  = 70-80 and 30-40 )   in  areas 27.7.e

INSERT  INTO eflalo_metiers.metiers_tables_fao_areas_2019  VALUES 
( 999999,'27.7.e','GND_SPF_70-80_0_0','GND','SPF','71','80','27.7.e','7e','VIIe','27.7.e','NAL','VIIe',269,'27.7.e','DIVISION',1,'Atlantic','2','27','','','Western English Channel (Division 27.7.e)',56394289620.29712,TRUE ) , 
(999999,'27.7.e','GND_SPF_30-40_0_0','GND','SPF','31','40','27.7.e','7e','VIIe','27.7.e','NAL','VIIe',269,'27.7.e','DIVISION',1,'Atlantic','2','27','','','Western English Channel (Division 27.7.e)',56394289620.29712,TRUE ) 
 

INSERT  INTO eflalo_metiers.metiers_tables_fao_areas_2019  VALUES 

(999999,'27.7.e','GND_DEF_70-80_0_0','GND','DEF','71','80','27.7.e','7e','VIIe','27.7.e','NAL','VIIe',269,'27.7.e','DIVISION',1,'Atlantic','2','27','','','Western English Channel (Division 27.7.e)',56394289620.29712,TRUE ), 
(999999,'27.7.e','GND_DEF_30-40_0_0','GND','DEF','31','40','27.7.e','7e','VIIe','27.7.e','NAL','VIIe',269,'27.7.e','DIVISION',1,'Atlantic','2','27','','','Western English Channel (Division 27.7.e)',56394289620.29712,TRUE )



INSERT  INTO eflalo_metiers.metiers_tables_fao_areas_2019  VALUES 

(999999,'27.7.f','GND_SPF_30-50_0_0','GND','SPF','31','49','27.7.f','7f','VIIf','27.7.f','NAL','VIIfgh',251,'27.7.f','DIVISION',1,'Atlantic','2','27','','','Bristol Channel (Division 27.7.f)',18973204582.244514,TRUE),
(999999,'27.4.c','GND_SPF_30-50_0_0','GND','SPF','31','49','27.4.c','4c','IVc','27.4.c','NSEA','IV..VIId',255,'27.4.c','DIVISION',1,'Atlantic','2','27','','','Southern North Sea (Division 27.4.c)',64302562996.37158,TRUE),
(999999,'27.4.c','GND_SPF_70-90_0_0','GND','SPF','71','89','27.4.c','4c','IVc','27.4.c','NSEA','IV..VIId',255,'27.4.c','DIVISION',1,'Atlantic','2','27','','','Southern North Sea (Division 27.4.c)',64302562996.37158,TRUE)

INSERT  INTO eflalo_metiers.metiers_tables_fao_areas_2019  VALUES 

(999999,'27.7.a','GNS_DEF_70-90_0_0','GNS','DEF','71','89','27.7.a','7a','VIIa','27.7.a','NAL','VIIa',273,'27.7.a','DIVISION',1,'Atlantic','2','27','','','Irish Sea (Division 27.7.a)',50225033064.33145,TRUE),
(999999,'27.7.a','GNS_SPF_70-90_0_0','GNS','SPF','71','89','27.7.a','7a','VIIa','27.7.a','NAL','VIIa',273,'27.7.a','DIVISION',1,'Atlantic','2','27','','','Irish Sea (Division 27.7.a)',50225033064.33145,TRUE),
(999999,'27.7.e','GNS_DEF_70-90_0_0','GNS','DEF','71','89','27.7.e','7e','VIIe','27.7.e','NAL','VIIe',269,'27.7.e','DIVISION',1,'Atlantic','2','27','','','Western English Channel (Division 27.7.e)',56394289620.29712,TRUE),
(999999,'27.7.e','GNS_SPF_70-90_0_0','GNS','SPF','71','89','27.7.e','7e','VIIe','27.7.e','NAL','VIIe',269,'27.7.e','DIVISION',1,'Atlantic','2','27','','','Western English Channel (Division 27.7.e)',56394289620.29712,TRUE),
(999999,'27.4.c','GNS_DEF_80-89_0_0','GNS','DEF','80','89','27.4.c','4c','IVc','27.4.c','NSEA','IV..VIId',255,'27.4.c','DIVISION',1,'Atlantic','2','27','','','Southern North Sea (Division 27.4.c)',64302562996.37158,TRUE),
(999999,'27.4.c','GNS_SPF_70-90_0_0','GNS','SPF','71','89','27.4.c','4c','IVc','27.4.c','NSEA','IV..VIId',255,'27.4.c','DIVISION',1,'Atlantic','2','27','','','Southern North Sea (Division 27.4.c)',64302562996.37158,TRUE )


 




		


 


---- 0.a : GET REGION: getregion r script  in correct format . Get the REGION submitted in the logbooks in the correct format to analize the metiers. 


drop table eflalo_metiers.voyage_region;

create table eflalo_metiers.voyage_region as 


with a as (    
select DISTINCT "FT_REF" , "LE_GEAR","LE_DIV", "DCFcode" dcf_gearcode from ( 
			 select DISTINCT "FT_REF", 
				 case 
				 when "LE_GEAR" IN ('GN', 'GNC' ) THEN 'GNS' 
				 when  "LE_GEAR"  IN ('LL', 'LX' ) THEN 'LLS'
				 when  "LE_GEAR"  IN ('TB', 'TBN') THEN 'OTB'
				 when  "LE_GEAR"  IN ('MIS', 'NK', 'HF', 'RG') THEN 'MIS'
				 when  "LE_GEAR"  = 'SV' THEN 'SSC'
				 when  "LE_GEAR"  = 'LHM' THEN 'LHP'
				 when  "LE_GEAR"  = 'FIX' THEN 'FPO'
				 ELSE  "LE_GEAR"  
				 end as "LE_GEAR", 
				 "LE_DIV" from eflalo.eflalo_2018 )  a 
			left join  fish_metadata.ifishgeartab c
			on "LE_GEAR"  = "iFishCode" 
  )  


  

	select DISTINCT "FT_REF", dcf_gearcode,b.le_div ,  f_Code,   fao,   region ,  metier from 
	(select distinct f_code, fao, rdb, ices, region, metier  from eflalo_metiers.metiers_tables_fao_areas_2019 ) b1  right join (Select DISTINCT "FT_REF",dcf_gearcode, "LE_DIV" le_div from   a  ) b
	 ON	 f_code = b.le_div  OR
	   rdb = b.le_div  OR
	 ices = b.le_div  ;	
	-- f_code = b.le_div 	; 
	-- "COST" = le_div OR

	  



		select * from eflalo_metiers.voyage_region where region IS NULL;
	 	select * from eflalo_metiers.voyage_region where "FT_REF" = 610256605 ;
	        select * from fish_metadata.statistical_area_codes

	 	 --- update not matched regions
	 	 
			--2018 :
				select DISTINCT "FT_REF" from  eflalo.eflalo_2018  where "LE_DIV" = '41'
				update eflalo.eflalo_2018  set "LE_DIV"  = '41.1' where "LE_DIV" = '41'





--- 0.b: GET MESH SIZE BY TRIP : get mesh size r script into SQL . Get the mesh size from logbooks. 

drop table eflalo_metiers.voyage_mesh_size;

create table eflalo_metiers.voyage_mesh_size as 
with a as (    
	select DISTINCT "FT_REF" , "LE_GEAR","LE_MSZ", "LE_DIV" le_div, "DCFcode" dcf_gearcode from ( 
				 select DISTINCT "FT_REF", 
					 case 
					 when "LE_GEAR" IN ('GN', 'GNC' ) THEN 'GNS' 
					 when  "LE_GEAR"  IN ('LL', 'LX' ) THEN 'LLS'
					 when  "LE_GEAR"  IN ('TB', 'TBN') THEN 'OTB'
					 when  "LE_GEAR"  IN ('MIS', 'NK', 'HF', 'RG') THEN 'MIS'
					 when  "LE_GEAR"  = 'SV' THEN 'SSC'
					 when  "LE_GEAR"  = 'LHM' THEN 'LHP'
					 when  "LE_GEAR"  = 'FIX' THEN 'FPO'
					 ELSE  "LE_GEAR"  
					 end as "LE_GEAR", 
					 "LE_DIV" , "LE_MSZ" 
					 from eflalo.eflalo_2018 )  a 
				left join  fish_metadata.ifishgeartab c
				on "LE_GEAR"  = "iFishCode" 		 
  ), 
  b as (   
	select DISTINCT "FT_REF" ft_ref , dcf_gearcode,le_div,
	 CASE  WHEN dcf_gearcode IN ( 'DRB','HMD','LHP','LTL','LLD','LLS','FPO','FYK','SB' ) THEN 0 ELSE  "LE_MSZ"  END as le_msz 
	 from a
  )  

select ft_Ref, dcf_gearcode, le_div , avg( le_msz) le_msz_avg  from b 
group by ft_Ref, dcf_gearcode, le_div;




	 



--- CREATE FINAL METIERS ------------
-- Dependencies: 
	-- eflalo_metiers.voyage_mesh_size ( created in 3rd script) 
	-- eflalo_metiers.voyage_target_taxa ( created in 2nd script)  
	-- eflalo_metiers.voyage_region ( created in 3rd script) 
	-- eflalo_metiers.metiers_table ('metiers' table  supplied with Alaister Pout  R script  ) 


 --- 1. create UK METIERS 
	drop table eflalo_metiers.uk_metiers_2018;
	create table eflalo_metiers.uk_metiers_2018  as 
  
	with a as ( 

		select a.ft_Ref, a.dcf_gearcode , target_taxa, le_msz_avg::integer,  a.le_div,  f_code, region, metier as  metier_area  from 
		eflalo_metiers.voyage_target_taxa a 
		inner join 
		eflalo_metiers.voyage_mesh_size b
		on a.ft_REf = b.ft_ref  and  a.dcf_gearcode = b.dcf_gearcode	and a.le_div = b.le_div
		inner join 
		eflalo_metiers.voyage_region c
		on  a.ft_Ref = c."FT_REF" and a.dcf_gearcode = c.dcf_gearcode  and a.le_div = c.le_div
	 ) 

	select DISTINCT  ft_Ref, dcf_gearcode, target_taxa, 
	case when le_msz_avg >999 then 999 else le_msz_avg end as le_msz_avg ,  le_div,  f_Code, 
	 region, metier_area,  dcf_gearcode || '_' || le_msz_avg || '_' || region || '_' ||  target_taxa || '_' ||  metier_area metier_a 
	 from a ;


 
 


 ---207669  unique ft_Ref, gear_code, le_div
 -- 208757 unique ft_Ref, gear_code, le_div, le_msz

--- 2. look up equivalence between UK METIERS and DCF_METIERS in eflalo_metiers.metiers_table TABLE

drop table eflalo_metiers.dcf_metiers_2018;
create table eflalo_metiers.dcf_metiers_2018  as 
with a as ( 
	select * from eflalo_metiers.uk_metiers_2018 
	) , b as ( 

	select  DISTINCT a.*, b.metier_lvl6  , min_mesh_size, max_mesh_size
	from (Select distinct *from eflalo_metiers.metiers_tables_fao_areas_2019 where f_level  IN (  'DIVISION' , 'SUBAREA' )    )  b right join a   
	on dcf_gearcode = gear  and a.target_taxa = b.target_taxa  
		and (   le_msz_avg between min_mesh_size::numeric and max_mesh_size::numeric
		and a.le_div = b.le_div  ) 
		)  , 
	c as (  
	select ft_Ref from ( 
		select row_number () over ( partition by ft_ref, dcf_gearcode,    le_div    ) rid , *  from b
		) foo  where rid > 1
	), 
	d as  (
		select row_number() over() id,  * 
		from b
		where ft_Ref in ( select * from  c ) and metier_area != 'X'
	) , 
	e as ( 

		select first_value(id )  over ( partition by ft_ref, dcf_gearcode,    le_div order by min_mesh_size)   from d
	) , f as  ( 
	
		select * from d where id in ( select * from e ) order by id  

	) 

	select 1 as id, * from  b where ft_Ref NOT IN  ( select * from c ) 
	UNION 
	select * from f; 

	alter table eflalo_metiers.dcf_metiers_2018  drop column id ; 

 
		

		 

---THE  AIM IS TO GET UNIQUE METIER BY FT_REF< GEAR CODE AND DIVISION -----------
--- check if there is more than 1 METIER by ft_ref, gear code and divisions (it shoudn't  ) . 


with a as ( 
select row_number () over ( partition by ft_ref, dcf_gearcode,    le_div    ) rid , *  from eflalo_metiers.dcf_metiers_2018
) , b as ( 

	select ft_Ref from a where rid > 1 
  ) , c as ( 
	select row_number() over() id,  * 
	from eflalo_metiers.dcf_metiers_2018 
	where ft_Ref in ( select * from  b ) and metier_area != 'X' order by ft_ref , min_mesh_Size DESC , max_mesh_Size   
) , d as ( 

select first_value(id )  over ( partition by ft_ref, dcf_gearcode,    le_div order by min_mesh_size)   from c 

 ) 

select * from c where id in ( select * from d ) order by id ; 



/* ANALYSIS OF NOT MATCHED METIERS */



----- ANALYSE WHAT ARE THE METIERS OTHERS THAN GEAR CODE 'OTH'(others ) WITH NOT ASSIGNED METIER
	select  *   from eflalo_metiers.dcf_metiers_2018 where metier_lvl6 IS NULL  and dcf_gearcode != 'OTH'	 
	order by  dcf_gearcode , region , metier_area

	
---- RESULT ANALYSIS FOR 2018 EFLALO . I HAVE CREATED THE MISSED METIERS IN THE   eflalo_metiers.metiers_tables_fao_areas_2019  TABLE AT BEGGINING OF THSI SCRIPT -----
-- GND 
	'SPF';40;'27.7.f', 'NAL'
	'DEF';60;'27.7.d', 'NSEA' --only one trip  ( MIS) 
	'SPF';45;'27.4.c', 'NSEA' --several trips 
	'SPF';80;'27.4.c' 
	'SPF';45;'27.4.c'
	'DEF';55;'27.4.c' --- few trips  (MIS ) 

--- GNS 
	-- NAL 
'GNS';'SPF';89;'27.7.a' --52 rows
'GNS';'DEF';80;'27.7.a' -- 95 rows
'GNS';'CRU';80;'27.7.a' -- 3 rows (MIS) 

'GNS';'SPF';80;'27.7.e' -- 68 rows
'GNS';'CRU';80;'27.7.e' -- 13 rows ( MIS) 
'GNS';'DEF';80;'27.7.e' --137 


--NSEA
 
'DEF';50;'27.7.d' -- 40 rows  ( MIS )  
'DWS';220;'27.7.d' -- 51 rows  (MISC) 

'GNS';'DEF';80;'27.4.c' -- 168 rows 
'GNS';'DEF';20;'27.4.c'  -- MISC 
'GNS';'SPF';80;'27.4.c' -- 45 rows 

--- OTB 

'OTB';'MOL'30;'27.4.b';'27.4.b';'NSEA' -- MISC 



--- ISOLATE THE METIERS NOT ASSIGNED FOR A GIVEN GEAR AND TARGET TAXA AND AREA

	select  *   from eflalo_metiers.dcf_metiers_2018 
	where  dcf_gearcode = 'OTB' and target_taxa = 'DEF' and le_div = '27.1' and  metier_lvl6 IS NULL 

--- FIND OUT WHAT ARE THE METIERS EXISTING FOR THE SAME GEAR AND AREA 
----  IDENTIFY WHAT ARE THE METIERS MESH SIZE RANGE MISSING (often is missing a mesh size category ) 
---- COPY A ROW AND MODIFY TO INSERT AS A NEW CEFAS CREATED METIER IN eflalo_metiers.metiers_tables_fao_areas_2019 TABLE
 
		select  * from   eflalo_metiers.metiers_tables_fao_areas_2019 
		where  	gear = 'OTB' and target_taxa = 'DEF'  and region = 'NSEA'
		and area_code = '27.1'

	 

	 

	
 ----- 3. ASSIGN THE MISC METIERS FOR THOSE METIERS WITHOUT ASSGINED METIER (AFTER THE ANLYSIS OF NTO ASSIGNED METIERS) 

update eflalo_metiers.dcf_metiers_2018 set metier_lvl6 =  'MIS_MIS_0_0_0' where metier_lvl6 IS NULL; 

---- 4.a UPDATE EFLALO TABLE WITH THE NEW CALCUALTED METIERS 

with a as ( 
	select ft_ref, dcf_gearcode, le_div , metier_lvl6  from eflalo_metiers.dcf_metiers_2018  
) 

update eflalo.eflalo_2018 b  set "LE_MET" = metier_lvl6 from a  where "FT_REF" = ft_Ref  and "LE_GEAR" = dcf_gearcode and "LE_DIV" = le_div ; 

----4.b update metiers column with aggregated gears ; 

with daf as ( 
	select "FT_REF" ft_ref, "LE_GEAR" le_gear, "LE_DIV" le_div 
	from 
	( select * from eflalo.eflalo_2018  WHERE "LE_GEAR"  IN  (  'GN', 'GNC',  'LL', 'LX', 'TB', 'TBN','MIS', 'NK', 'HF', 'RG' , 'SV', 'LHM' , 'FIX')    ) a -- where "FT_REF" = '900010510373' 
	
) , 

daf_agg as (
 
	 select DISTINCT ft_ref, 
	 le_gear,
	 case 
	 when le_gear IN ('GN', 'GNC' ) THEN 'GNS' 
	 when le_gear IN ('LL', 'LX' ) THEN 'LLS'
	 when le_gear IN ('TB', 'TBN') THEN 'OTB'
	 when le_Gear IN ('MIS', 'NK', 'HF', 'RG') THEN 'MIS'
	 when le_gear = 'SV' THEN 'SSC'
	 when le_gear = 'LHM' THEN 'LHP'
	 when le_gear = 'FIX' THEN 'FPO'
	 ELSE le_gear 
	 end as le_gear_agg, 
	 le_div	 
	 from daf  
), 
dcf_metiers as ( 
	select ft_ref, dcf_gearcode, le_div , metier_lvl6  from eflalo_metiers.dcf_metiers_2018  
) , 
metiers_original_gear as  (

select a.*,  b.le_gear from ( 
	select a.*, gear2."iFishCode" 
	 from dcf_metiers a 
	 inner join  fish_metadata.ifishgeartab gear2	
	 on  a.dcf_gearcode = "DCFcode" 
	 )  a  inner join daf_agg b on a. ft_ref   = b.ft_Ref and a."iFishCode" = b.le_gear_agg and a.le_div = b.le_div 


) 

update eflalo.eflalo_2018 b  set "LE_MET" = metier_lvl6 from metiers_original_gear  where "FT_REF" = ft_Ref  and "LE_GEAR" = le_gear  and "LE_DIV" = le_div ; 



--- check how many trips havent metier. The aim is that all of them get a associated metier ( even if it is MISC metiers ) .
select * from eflalo.eflalo_2018 where "LE_MET" IS NULL;













	


/*  ANALYSIS OF THE TARGET SPECIES ASSEMBLAGE CALCUALTION IN 1st SCRIPT OF METIERS CALCULATION*/

with a as (

select DISTINCT a.ft_ref
					from ( 
						select distinct ft_Ref, dcf_gearcode,le_div, lekg_sum lekg_sum_spf
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode LIKE '%LL%' AND taxa = 'LPF' 
					)a 
				    left join ( 
						select distinct ft_Ref, dcf_gearcode,le_div,lekg_sum*0.5 lekg_sum_def 
						from eflalo_metiers.voyage_taxa_stats 
						where dcf_gearcode LIKE '%LL%'  AND taxa = 'DEF' 
					)b 
				        on  a.ft_ref = b.ft_ref and a.dcf_gearcode = b.dcf_gearcode and a.le_div = b.le_div
				  -- condition to apply to targeted assemblage 
				     where lekg_sum_spf > lekg_sum_def 


) 
select * from   eflalo_metiers.voyage_taxa_stats where ft_Ref  IN ( select * from a ) 

 order  by "VE_REF"; 


	 



------- number of trips with more than one metier
	  


	 with a as ( 
		select DISTINCT "FT_REF" ,"LE_MET" from eflalo.eflalo_2017
	  ) , 
	  aa as ( select * ,   row_number() over ( partition by "FT_REF") rnum from a  ),
	  b as (  select * from aa where rnum > 1) 
	  
	  
	  select * from aa where "FT_REF" in ( select DISTINCT "FT_REF" from b)
	  order by  "FT_REF" ,"LE_MET", rnum 
	  
	  ------- number of trips with more than one gear
	  
	  with a as ( 
		select DISTINCT "FT_REF" ,"LE_GEAR" from eflalo.eflalo_2018
	  ) , 
	  aa as ( select * ,   row_number() over ( partition by "FT_REF") rnum from a  ),
	  b as (  select * from aa where rnum > 1) 
