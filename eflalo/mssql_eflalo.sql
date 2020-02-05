/* Script  to create EFLALO dataset from IFISH2 SQL server database

 By: Matt Elliot , Roi Martinez 
 Code by:  Matt Elliot, Roi Martinez
 Contact: matt.elliott@marinemanagement.org.uk, roi.martinez@cefas.co.uk 
 
 
 Date: 25/Jan/2017
 Update Date: 29/Jan/2019 , Updated by: Roi Martinez
 Client: ICES */
 
 
/*READ ME 
 The  following script provides the code needed to create a EFLALO dataset from
 IFISH database. The EFLALO format here provided is a modification of the standard 
 EFLALO format , adpating the SPECIES columns  to perform better with SQL queries.
   Instead to have a field for weight and value by species and by log event (LE_ ), it
 has a column for species , one for weight and one for value and LE_ID is repeated 
 for each species captured during that LE_ID . Then the species columns can be easily
 pivoted into EFLALO standard format in R enviroment and then be used with  VMSTools for further analysis

 
 */
 
 

with iFV as  ( 
		select * 
		from dbo.F_VOYAGE 
		where YEAR(DEPARTURE_DATE_TIME) = 2018 or YEAR(RETURN_DATE_TIME) = 2018 
		) , 
	iFA as ( 
		select *
		from dbo.F_ACTIVITY 
		where VOYAGE_ID IN ( select DISTINCT VOYAGE_ID from iFV ) 
	), 
	iFC as ( 
		select ACTIVITY_ID, SPECIES_CODE, Sum(LIVE_WEIGHT) as LE_KG, Sum(LANDINGS_VALUE) as LE_EURO 
		from dbo.F_CATCH where ACTIVITY_ID IN (select DISTINCT ACTIVITY_ID from iFA )
		group by  ACTIVITY_ID, SPECIES_CODE
		) 

select DISTINCT

-- VEssel info section
iDV.RSS_NO as VE_REF,
iFA.GEAR_CODE + '_' + cast(iFA.MESH_SIZE as varchar(15)) as VE_FLT,
iDV.COUNTRY_CODE as VE_COU,
iDV.LENGTH as VE_LEN,
iDV.ENGINE_POWER as VE_KW,
iDV.TONNAGE as VE_TON,

-- Fishing Trip info section
CAST (iFV.VOYAGE_ID AS BIGINT) as FT_REF,
iDPD.COUNTRY_CODE as FT_DCOU,
iDPD.NAME as FT_DHAR,
CAST ( iFV.DEPARTURE_DATE_TIME AS DATE) as FT_DDAT,
CAST (iFV.DEPARTURE_DATE_TIME AS TIME) as FT_DTIME,
iDPL.COUNTRY_CODE as FT_LCOU,
iDPL.NAME as FT_LHAR,
CAST( iFV.RETURN_DATE_TIME AS DATE) as FT_LDAT,
CAST( iFV.RETURN_DATE_TIME AS TIME) as FT_LTIME,


-- Logbook Event info section
iFA.ACTIVITY_ID as LE_ID, -- Need to back track this to FT_REF + counter within FT_REF
iFA.ACTIVITY_DATE as LE_CDAT,
null as LE_STIME,
null as LE_ETIME,
--MAX(rr.NominalLatitude) as LE_SLAT,
--MAX(rr.NominalLongitude) as LE_SLON,
--MAX(rr.NominalLatitude) as LE_ELAT,
--MAX(rr.NominalLongitude) as LE_ELON,
null as LE_SLAT,
null as LE_SLON,
null as LE_ELAT,
null as LE_ELON,
iFA.GEAR_CODE as LE_GEAR,
iFA.MESH_SIZE as LE_MSZ,
iFA.RECTANGLE_CODE as LE_RECT,
iFA.FAO_FISHING_AREA_CODE as LE_DIV,
--iDE.EFLALO2_AREA as LE_DIV,
null as LE_MET,
iFC.species_code  LE_SPE,
LE_KG, 
LE_EURO

from 
-- IFISH basic joins
iFV inner join  iFA on iFV.VOYAGE_ID = iFA.VOYAGE_ID  
inner join  iFC 	on iFA.ACTIVITY_ID = iFC.ACTIVITY_ID	
left join dbo.D_VESSEL iDV on iFV.RSS_NO = iDV.RSS_NO and   
 						CONVERT(  DATE, CONVERT(VARCHAR(10), iFV.DEPARTURE_DATE_TIME, 112) ) 
						 between CONVERT(  DATE, CONVERT(VARCHAR(10), iDV.VALID_FROM_DATE, 112) )  
						 and CONVERT(  DATE, CONVERT(VARCHAR(10),  iDV.VALID_TO_DATE , 112) )    

-- Need a couple of port nationalities
left join dbo.D_PORT iDPD on iFV.DEPARTURE_PORT_CODE = iDPD.PORT_CODE
left join dbo.D_PORT iDPL on iFV.LANDING_PORT_CODE = iDPL.PORT_CODE
-- inner join dbo.GBPToEuroConversionMultiplier iMp on Year(iFV.RETURN_DATE_TIME) = iMp.YearValid

--inner join iFish2Dev.dbo.D_EFLALO2_AREA iDE on iFA.FAO_FISHING_AREA_CODE = iDE.FAO_FISHING_AREA

--inner join RegionRectangle rr on iFA.RECTANGLE_CODE = rr.Rectangle


--Deal with some things that dont fit joins very well
where  iDV.COUNTRY_CODE like 'GB%'
--and iFA.ACTIVITY_DATE between rq.DateFrom and rq.DateTo
