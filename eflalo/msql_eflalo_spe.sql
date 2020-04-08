/* Script  to create EFLALO SPECIES LANDINGS DETAIL TABLE dataset from IFISH2 SQL server database
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
 
 

with iFA as ( 
		select ACTIVITY_ID, VOYAGE_ID
		from dbo.F_ACTIVITY 
		where YEAR(ACTIVITY_DATE ) between 2009 or YEAR(ACTIVITY_DATE) = 2019 
	), 
	iFC as ( 
		select ACTIVITY_ID, SPECIES_CODE, Sum(LIVE_WEIGHT) as LE_KG, Sum(LANDINGS_VALUE) as LE_EURO 
		from dbo.F_CATCH where ACTIVITY_ID IN (select DISTINCT ACTIVITY_ID from iFA )
		group by  ACTIVITY_ID, SPECIES_CODE
		) 

select DISTINCT
-- Fishing Trip info section
CAST (iFA.VOYAGE_ID AS BIGINT) as FT_REF,
 
-- Logbook Event info section
iFA.ACTIVITY_ID as LE_ID, -- Need to back track this to FT_REF + counter within FT_REF 
iFC.species_code  LE_SPE,
LE_KG, 
LE_EURO

from 
-- IFISH basic joins
select * from iFA inner join  iFC on iFA.ACTIVITY_ID = iFC.ACTIVITY_ID	
inner join dbo.D_VESSEL iDV on iFV.RSS_NO = iDV.RSS_NO and  iDV.COUNTRY_CODE like 'GB%'  
 	    
