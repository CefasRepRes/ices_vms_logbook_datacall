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
 select DISTINCT 
-- Logbook Event info section
iFA.ACTIVITY_ID as LE_ID, -- Need to back track this to FT_REF + counter within FT_REF 
iFC.species_code  LE_SPE,
Sum(LIVE_WEIGHT) as LE_KG, 
Sum(LANDINGS_VALUE) as LE_EURO , 
-- Fishing Trip info section
CAST (iFA.VOYAGE_ID AS BIGINT) as   eflalo_ft_ft_ref

FROM dbo.F_VOYAGE iFV		  
	inner join F_ACTIVITY iFA    
	on iFA.VOYAGE_ID = iFV.VOYAGE_ID and  YEAR(ACTIVITY_DATE ) between 2019 and  2019 
    inner join dbo.D_VESSEL iDV 
    on  iFV.RSS_NO = iDV.RSS_NO and iDV.COUNTRY_CODE like 'GB%' and  
 						CONVERT(  DATE, CONVERT(VARCHAR(10), iFV.DEPARTURE_DATE_TIME, 112) )  						
						 between CONVERT(  DATE, CONVERT(VARCHAR(10), iDV.VALID_FROM_DATE, 112) )  
						 and CONVERT(  DATE, CONVERT(VARCHAR(10),  iDV.VALID_TO_DATE , 112) )  
  inner join dbo.F_CATCH iFC
  on iFC.ACTIVITY_ID = iFA.ACTIVITY_ID

group by  iFA.ACTIVITY_ID, SPECIES_CODE, iFA.VOYAGE_ID
