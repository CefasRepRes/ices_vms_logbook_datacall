update fish_metadata.ifishspptab IFC set eflalo_ifishcode =  case 
when iFC."iFishCode" in ('CLH','CLS','CLV','CLX','CMM','COC','MUS','OYC','OYF','OYG','OYX','RAZ','SSD') then 'CLX'
when iFC."iFishCode" in ('ANT','ATP','BAZ','BER','BIB','BLP','BLU','BRB','BSF','CAX','CBC','CEO','CES','CMO','COX',
'CUS','CYH','DEL','EEO','ELP','EPI','FIL','FLX','GPD','GRM','GRN','GRO','GRX','GUU','GUX','HKP','HPR','IOO','KCP','LUM',
'LYY','MUL','NEC','NOT','OIL','OSG','PGO','PHO','PLA','POA','RCT','RED','RIB','ROL','RSE','SAN','SAO','SBA','SBG','SOS',
'STU','TJX','TOP','TRA','TRI','USB','WEG','WRA','YEL','ZGP') then 'GRO'
when iFC."iFishCode" in  ('AMB','AMX','BIL','BLM','BOG','CJM','DCO','DOL','FRZ','GAR','LEE','LTA','MAS','MOP',
'POX','SAA','SAE','SHD','SME','TUX') then 'PEL'
when iFC."iFishCode" in  ('JAD','JDP','RJA','RJB','RJC','RJE','RJF','RJG','RJH','RJI','RJM','RJN','RJO','RJR',
'RJU','RJY','SKA','TTO','TTR') then 'RAJ'
when iFC."iFishCode" in  ('AGN','APQ','BSK','CFB','CWZ','CYO','CYP','DGH','DGS','DGX','ETR','FAL','GAG','GAM',
'GSK','GUP','GUQ','HXC','LMA','MAK','OXN','POR','PTH','SBL','SHO','SPL','SPN','SPV','SPZ','SYC','SYR','SYT','SYX','THR') then 'SKH'
when iFC."iFishCode" in ('CRG','CRR','KCS','KCX','KEF','LIO','LOQ') then 'CRA'
when iFC."iFishCode" in ('CPR','CRW','PEN','TGS') then 'CRU'
when iFC."iFishCode" in ('GIS','ILL','SQA','SQP') then 'SQC'
when iFC."iFishCode" in ('PER','WHE') then 'GAS'
when iFC."iFishCode" in ('AJQ','COL','CUX','LFO','STF','URC') then 'ZZA'
when iFC."iFishCode" like 'SQE' then 'SQU'
when iFC."iFishCode" like 'OCM' then 'OCT'
else iFC."iFishCode" 
end;
