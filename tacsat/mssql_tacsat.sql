
select distinct 
Sat.RSSNo as VE_REF,
Sat.Latitude as SI_LATI,
Sat.Longitude as SI_LONG,
CAST (Sat.SightingDate as DATE ) as SI_DATE,
CAST (Sat.SightingDate as TIME ) as SI_TIME,
Sat.SightingDate as SI_DATIM, 
Sat.Speed as SI_SP,
Sat.Course as SI_HE,
null as SI_HARB,
null as SI_STATE,
CAST( isnull(iFV.VOYAGE_ID,0) AS BIGINT ) as SI_FT

FROM dbo.F_VOYAGE as iFV
--- select vessel details  ----
inner join dbo.D_VESSEL iDV 
on iFV.RSS_NO = iDV.RSS_NO and iDV.COUNTRY_CODE like 'GB%' 
  and iFV.DEPARTURE_DATE_TIME between iDV.VALID_FROM_DATE and iDV.VALID_TO_DATE	
inner join F_ACTIVITY iFA    
	on iFA.VOYAGE_ID = iFV.VOYAGE_ID and  YEAR(ACTIVITY_DATE ) between 2019 and  2019 
-- select VMS points from selected fishing voyages ---
inner outer  join  dbo.SatSighting Sat 
on Sat.SightingDate between  iFV.DEPARTURE_DATE_TIME and iFV.RETURN_DATE_TIME 
and Sat.RSSNo = iFV.RSS_NO

-- filter fields with no voyage_id or no vessel  
where iFV.VOYAGE_ID IS NOT NULL and Sat.VessReg is not null
Order by  VE_REF,SI_FT,  SI_DATE, SI_TIME  
