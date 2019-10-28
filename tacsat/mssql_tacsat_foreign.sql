
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

select *  
--select the VMS points from foreign vessels 
FROM   ( Select * from dbo.SatSighting   where  VessNat  NOT LIKE 'GB%'  and   YEAR( SightingDate ) = 2018) Sat left join dbo.D_VESSEL iDV
on     SightingDate between VALID_FROM_DATE and VALID_TO_DATE
and Sat.VessReg = iDV.PORT_LETTER_AND_NO  

--- select vessel details  ----
left outer join  F_VOYAGE iFV on  SightingDate  between  iFV.DEPARTURE_DATE_TIME and iFV.RETURN_DATE_TIME and iFV.RSS_NO = iDV.RSS_NO

-- filter fields with no voyage_id or no vessel  

Order by  VE_REF,SI_FT,  SI_DATE, SI_TIME
