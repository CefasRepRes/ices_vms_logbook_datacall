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
		select iFV.* 
		from dbo.F_VOYAGE 	iFV	 
		inner  join dbo.D_VESSEL iDV on YEAR(RETURN_DATE_TIME) between 2009 and 2019  and 
				iFV.RSS_NO = iDV.RSS_NO and iDV.COUNTRY_CODE like 'GB%' and   
 						CONVERT(  DATE, CONVERT(VARCHAR(10), iFV.DEPARTURE_DATE_TIME, 112) )  						
						 between CONVERT(  DATE, CONVERT(VARCHAR(10), iDV.VALID_FROM_DATE, 112) )  
						 and CONVERT(  DATE, CONVERT(VARCHAR(10),  iDV.VALID_TO_DATE , 112) ) 
		) , 
	iFA as ( 
		select *
		from dbo.F_ACTIVITY 
		where VOYAGE_ID IN ( select DISTINCT VOYAGE_ID from iFV ) 
     
	)

select DISTINCT
 


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
null as LE_MET

from 
-- IFISH basic joins
iFV inner join  iFA on iFV.VOYAGE_ID = iFA.VOYAGE_ID  

-- Need a couple of port nationalities
left join dbo.D_PORT iDPD on iFV.DEPARTURE_PORT_CODE = iDPD.PORT_CODE
left join dbo.D_PORT iDPL on iFV.LANDING_PORT_CODE = iDPL.PORT_CODE
-- inner join dbo.GBPToEuroConversionMultiplier iMp on Year(iFV.RETURN_DATE_TIME) = iMp.YearValid
order by LE_CDAT DESC
--inner join iFish2Dev.dbo.D_EFLALO2_AREA iDE on iFA.FAO_FISHING_AREA_CODE = iDE.FAO_FISHING_AREA

--inner join RegionRectangle rr on iFA.RECTANGLE_CODE = rr.Rectangle


--Deal with some things that dont fit joins very well

--and iFA.ACTIVITY_DATE between rq.DateFrom and rq.DateTo
