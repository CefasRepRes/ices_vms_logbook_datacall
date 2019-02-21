/* Query unique VOYAGES ID's for the required time period */

with voyages as ( 
	select distinct iFV.voyage_id, year(iFV.DEPARTURE_DATE_TIME) year_departure, year(iFV.return_DATE_TIME) year_return,iFV.DEPARTURE_DATE_TIME, iFV.RETURN_DATE_TIME, iFA.ACTIVITY_ID
	-- Tables used and joined
	from f_voyage iFV
	inner join f_activity iFA on iFV.voyage_id = iFA.voyage_id and iFA.ACTIVITY_DATE between'01-JAN-2018' and '31-DEC-2018'
	inner join f_catch  iFC on iFA.activity_id = iFC.activity_id 
	inner join d_vessel iDV on iFV.rss_no = iDV.rss_no  and iFA.ACTIVITY_DATE between iDV.VALID_FROM_DATE and iDV.VALID_TO_DATE
	where iDV.COUNTRY_CODE like 'GB%'
	and iFC.SPECIES_CODE not in ('LVR','ROE','UKN','ZZB')

)
, 
b as ( 
	select ROW_NUMBER() OVER( ORDER BY voyage_id ) id, * , DATEDIFF(DAY,DEPARTURE_DATE_TIME,RETURN_DATE_TIME  ) voyage_days   
	from voyages  
) 

select id, b.voyage_id, year_Departure, year_return,  c.* 
from  ( 
	select  voyage_id , count(distinct ACTIVITY_ID) number_log_events 
	from voyages
	group by voyage_id
) as c 
left join b 
on b.voyage_id = c.voyage_id

order by voyage_days ;
