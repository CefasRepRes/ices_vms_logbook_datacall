/* Query unique VOYAGES ID's for the required time period */

with voyages as ( 
	select distinct f_voyage.voyage_id  
	-- Tables used and joined
	from f_voyage 
	join f_activity on f_voyage.voyage_id = f_activity.voyage_id 
	join f_catch  on f_activity.activity_id = f_catch.activity_id 
	join d_vessel on f_voyage.rss_no = d_vessel.rss_no
	where D_VESSEL.COUNTRY_CODE like 'GB%'
	and f_voyage.DEPARTURE_DATE_TIME between'01-JAN-2018' and '31-DEC-2018'
)

select ROW_NUMBER() OVER( ORDER BY voyage_id ) id, voyage_id into RM12.ft_ref_uq_2019 from voyages ;
