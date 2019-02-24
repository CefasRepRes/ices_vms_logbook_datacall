
select distinct 
Sat.RSSNo as VE_REF,
Sat.Latitude as SI_LATI,
Sat.Longitude as SI_LONG,
CAST (Sat.SightingDate as DATE ) as SI_DATE,
CAST (Sat.SightingDate as TIME ) as SI_TIME,
Sat.Speed as SI_SP,
Sat.Course as SI_HE,
null as SI_HARB,
null as SI_STATE,
CAST( isnull(iFV.VOYAGE_ID,0) AS BIGINT ) as SI_FT

FROM (select * from dbo.F_VOYAGE  where VOYAGE_ID in (select ft_ref from rm12.ft_ref_uq_2018) )as iFV

-- select VMS points from selected fishing voyages ---
left outer  join  dbo.SatSighting Sat 
on Sat.SightingDate between  iFV.DEPARTURE_DATE_TIME and iFV.RETURN_DATE_TIME 
and Sat.RSSNo = iFV.RSS_NO

--- select vessel details  ----
left outer join dbo.D_VESSEL iDV 
on iFV.RSS_NO = iDV.RSS_NO and iFV.DEPARTURE_DATE_TIME between iDV.VALID_FROM_DATE and iDV.VALID_TO_DATE	

-- filter fields with no voyage_id or no vessel  
where iFV.VOYAGE_ID IS NOT NULL and Sat.VessReg is not null
Order by  VE_REF,SI_FT,  SI_DATE, SI_TIME  
