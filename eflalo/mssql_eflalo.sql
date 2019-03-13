/*code to create eflalo dataset from IFISH2 SQL server */

select DISTINCT

-- VEssel info section
iDV.RSS_NO as VE_REF,
iFA.GEAR_CODE + '_' + cast(iFA.MESH_SIZE as varchar(5)) as VE_FLT,
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
case 
when iFC.species_code in ('CLH','CLS','CLV','CLX','CMM','COC','MUS','OYC','OYF','OYG','OYX','RAZ','SSD') then 'CLX'
when iFC.species_code in ('ANT','ATP','BAZ','BER','BIB','BLP','BLU','BRB','BSF','CAX','CBC','CEO','CES','CMO','COX',
'CUS','CYH','DEL','EEO','ELP','EPI','FIL','FLX','GPD','GRM','GRN','GRO','GRX','GUU','GUX','HKP','HPR','IOO','KCP','LUM',
'LYY','MUL','NEC','NOT','OIL','OSG','PGO','PHO','PLA','POA','RCT','RED','RIB','ROL','RSE','SAN','SAO','SBA','SBG','SOS',
'STU','TJX','TOP','TRA','TRI','USB','WEG','WRA','YEL','ZGP') then 'GRO'
when iFC.species_code in  ('AMB','AMX','BIL','BLM','BOG','CJM','DCO','DOL','FRZ','GAR','LEE','LTA','MAS','MOP',
'POX','SAA','SAE','SHD','SME','TUX') then 'PEL'
when iFC.species_code in  ('JAD','JDP','RJA','RJB','RJC','RJE','RJF','RJG','RJH','RJI','RJM','RJN','RJO','RJR',
'RJU','RJY','SKA','TTO','TTR') then 'RAJ'
when iFC.species_code in  ('AGN','APQ','BSK','CFB','CWZ','CYO','CYP','DGH','DGS','DGX','ETR','FAL','GAG','GAM',
'GSK','GUP','GUQ','HXC','LMA','MAK','OXN','POR','PTH','SBL','SHO','SPL','SPN','SPV','SPZ','SYC','SYR','SYT','SYX','THR') then 'SKH'
when iFC.SPECIES_CODE in ('CRG','CRR','KCS','KCX','KEF','LIO','LOQ') then 'CRA'
when iFC.SPECIES_CODE in ('CPR','CRW','PEN','TGS') then 'CRU'
when iFC.species_code in ('GIS','ILL','SQA','SQP') then 'SQC'
when iFC.species_code in ('PER','WHE') then 'GAS'
when iFC.species_code in ('AJQ','COL','CUX','LFO','STF','URC') then 'ZZA'
when iFC.species_code like 'SQE' then 'SQU'
when iFC.species_code like 'OCM' then 'OCT'
else iFC.species_code 
end as LE_SPE,
Sum(iFC.LIVE_WEIGHT) as LE_KG,
Sum(iFC.LANDINGS_VALUE) as LE_EURO
--Sum(iFC.LANDINGS_VALUE*iMp.GBPToEuroConversionMultiplier) as LE_EURO

from 
-- IFISH basic joins
dbo.F_VOYAGE iFV 
inner join dbo.F_ACTIVITY iFA on iFV.VOYAGE_ID = iFA.VOYAGE_ID and iFA.ACTIVITY_DATE between'01-JAN-2018' and '31-DEC-2018'
inner join dbo.F_CATCH iFC 	on iFA.ACTIVITY_ID = iFC.ACTIVITY_ID	
inner join dbo.D_VESSEL iDV on iFV.RSS_NO = iDV.RSS_NO and iFV.RETURN_DATE_TIME between iDV.VALID_FROM_DATE and iDV.VALID_TO_DATE
 

-- Need a couple of port nationalities
inner join dbo.D_PORT iDPD on iFV.DEPARTURE_PORT_CODE = iDPD.PORT_CODE
inner join dbo.D_PORT iDPL on iFV.LANDING_PORT_CODE = iDPL.PORT_CODE
-- inner join dbo.GBPToEuroConversionMultiplier iMp on Year(iFV.RETURN_DATE_TIME) = iMp.YearValid

--inner join iFish2Dev.dbo.D_EFLALO2_AREA iDE on iFA.FAO_FISHING_AREA_CODE = iDE.FAO_FISHING_AREA

--inner join RegionRectangle rr on iFA.RECTANGLE_CODE = rr.Rectangle


--Deal with some things that dont fit joins very well
where  iDV.COUNTRY_CODE like 'GB%'
--and iFA.ACTIVITY_DATE between rq.DateFrom and rq.DateTo

group by iDV.COUNTRY_CODE, iDV.RSS_NO, iDV.LENGTH, iDV.ENGINE_POWER, iDV.TONNAGE,
iFV.VOYAGE_ID, iDPD.COUNTRY_CODE, iDPD.NAME,iDPL.NAME, iFV.DEPARTURE_DATE_TIME,
iDPL.COUNTRY_CODE, iFV.LANDING_PORT_CODE, iFV.RETURN_DATE_TIME, iFA.ACTIVITY_ID, iFA.ACTIVITY_DATE,
iFA.GEAR_CODE, iFA.MESH_SIZE, iFA.RECTANGLE_CODE, iFA.FAO_FISHING_AREA_CODE,  
case 
when iFC.species_code in ('CLH','CLS','CLV','CLX','CMM','COC','MUS','OYC','OYF','OYG','OYX','RAZ','SSD') then 'CLX'
when iFC.species_code in ('ANT','ATP','BAZ','BER','BIB','BLP','BLU','BRB','BSF','CAX','CBC','CEO','CES','CMO','COX',
'CUS','CYH','DEL','EEO','ELP','EPI','FIL','FLX','GPD','GRM','GRN','GRO','GRX','GUU','GUX','HKP','HPR','IOO','KCP','LUM',
'LYY','MUL','NEC','NOT','OIL','OSG','PGO','PHO','PLA','POA','RCT','RED','RIB','ROL','RSE','SAN','SAO','SBA','SBG','SOS',
'STU','TJX','TOP','TRA','TRI','USB','WEG','WRA','YEL','ZGP') then 'GRO'
when iFC.species_code in  ('AMB','AMX','BIL','BLM','BOG','CJM','DCO','DOL','FRZ','GAR','LEE','LTA','MAS','MOP',
'POX','SAA','SAE','SHD','SME','TUX') then 'PEL'
when iFC.species_code in  ('JAD','JDP','RJA','RJB','RJC','RJE','RJF','RJG','RJH','RJI','RJM','RJN','RJO','RJR',
'RJU','RJY','SKA','TTO','TTR') then 'RAJ'
when iFC.species_code in  ('AGN','APQ','BSK','CFB','CWZ','CYO','CYP','DGH','DGS','DGX','ETR','FAL','GAG','GAM',
'GSK','GUP','GUQ','HXC','LMA','MAK','OXN','POR','PTH','SBL','SHO','SPL','SPN','SPV','SPZ','SYC','SYR','SYT','SYX','THR') then 'SKH'
when iFC.SPECIES_CODE in ('CRG','CRR','KCS','KCX','KEF','LIO','LOQ') then 'CRA'
when iFC.SPECIES_CODE in ('CPR','CRW','PEN','TGS') then 'CRU'
when iFC.species_code in ('GIS','ILL','SQA','SQP') then 'SQC'
when iFC.species_code in ('PER','WHE') then 'GAS'
when iFC.species_code in ('AJQ','COL','CUX','LFO','STF','URC') then 'ZZA'
when iFC.species_code like 'SQE' then 'SQU'
when iFC.species_code like 'OCM' then 'OCT'
else iFC.species_code 
end

