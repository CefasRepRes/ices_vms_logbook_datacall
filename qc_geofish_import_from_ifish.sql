-- Get the total landings reported in IFISH ( to be run in IFISH/CEDER DB  ) 

with a as( 



select iFV.* from ( 

select * , year ([LANDING_DATE]  ) as ft_year 
from [dbo].[F_VOYAGE] 
where year ( [LANDING_DATE]  ) between 2012 and 2022 ) iFV 

 inner join dbo.D_VESSEL iDV 
    on  iFV.RSS_NO = iDV.RSS_NO and iDV.COUNTRY_CODE like 'GB%' and  
 						CONVERT(  DATE, CONVERT(VARCHAR(10), iFV.DEPARTURE_DATE_TIME, 112) )  						
						 between CONVERT(  DATE, CONVERT(VARCHAR(10), iDV.VALID_FROM_DATE, 112) )  
						 and CONVERT(  DATE, CONVERT(VARCHAR(10),  iDV.VALID_TO_DATE , 112) )    





) , d as ( 


select  c.*, ft_year from F_CATCH c inner join  ( 

select a.*,b.ACTIVITY_ID  from F_ACTIVITY b inner join a 
on a.VOYAGE_ID = b.VOYAGE_ID ) foo 

on c.ACTIVITY_ID = foo.ACTIVITY_ID ) 


select sum ( LIVE_WEIGHT ) , ft_year  from d 
group by ft_year 
order by ft_year




-- Get the total landings exported in GeoFISH  ( to be run in GeoFISH  DB  ) 

  -- Consider that IFISH is udpated regualrly even past records , so it is expected a difference on a range from 100 K to > 1 M




with a as( 
	 select *  
	from eflalo.eflalo_ft  
	where extract (year from  FT_DDATIM  )  between 2012 and 2022  
)  
, d as ( 


	select  c.* , foo.ft_year 
	from eflalo.eflalo_spe c 
	inner join  ( 

		select a.*,b.le_id  
		from eflalo.eflalo_le b 
		inner join a 
		on a.ft_ref = b.eflalo_ft_ft_ref
	) foo 

	on c.eflalo_le_le_id = foo.le_id 

) 


select sum ( le_kg ) , ft_year  from d 
group by ft_year 
order by ft_year
