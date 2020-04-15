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
 
SELECT DISTINCT
  iFV.RSS_NO as VE_REF,
  NULL as VE_FLT,
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
  CAST( iFV.RETURN_DATE_TIME AS TIME) as FT_LTIME 
  
FROM dbo.F_VOYAGE iFV		  
	inner join F_ACTIVITY iFA    
	on iFA.VOYAGE_ID = iFV.VOYAGE_ID and  YEAR(ACTIVITY_DATE ) between 2019 and  2019 
    inner join dbo.D_VESSEL iDV 
    on  iFV.RSS_NO = iDV.RSS_NO and iDV.COUNTRY_CODE like 'GB%' and  
 						CONVERT(  DATE, CONVERT(VARCHAR(10), iFV.DEPARTURE_DATE_TIME, 112) )  						
						 between CONVERT(  DATE, CONVERT(VARCHAR(10), iDV.VALID_FROM_DATE, 112) )  
						 and CONVERT(  DATE, CONVERT(VARCHAR(10),  iDV.VALID_TO_DATE , 112) )    

	left join dbo.D_PORT iDPD on iFV.DEPARTURE_PORT_CODE = iDPD.PORT_CODE
left join dbo.D_PORT iDPL on iFV.LANDING_PORT_CODE = iDPL.PORT_CODE
