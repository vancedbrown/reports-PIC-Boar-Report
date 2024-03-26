library(tidyverse)
library(knitr)
library(dplyr)
library(lubridate)
library(stringr)
library(writexl)
library(here)
library(kableExtra)
library(writexl)
library(writexl)
library(openxlsx)
library(readxl)

source('C:/Users/vance/Documents/myR/functions/getSQL.r')

query1<-"SELECT a.[StudID] AS 'STUD'
      ,a.[BoarID] AS 'BOARID'
      ,a.[Name] AS 'NAME'
      ,a.[Status] AS 'STATUS'
      ,a.[Date_Studout] AS 'DATE_STUDOUT'
	  ,c.[DESCR] AS 'SPG_REASON'
  FROM [Intranet].[dbo].[Boar_Pig] a
  left join [Intranet].[dbo].[Boar_LookUp] c on a.[StudID] = c.[StudID] and a.[Dispose_Code]=c.[ID]
  WHERE a.[StudID] in ('MB 7081','MB 7082','SPGVA', 'MB 7093') 
  and a.[Breed] in ('PICL02', 'PICL03','PIC800','PICL92')
  and a.[Date_Arrival]>'2020-01-01'"

inv1<-getSQL('Intranet', query = query1)

inv1$SPG_REASON<-str_trim(inv1$SPG_REASON, "right")

inv2<-read_csv('transfercodekey.csv')

inv3<-left_join(x = inv1,y = inv2,by=c("SPG_REASON"="SPG_REASON"))

write_csv(x = inv3, file = 'picinventory.csv')

### MAKE SURE TO FIX BOAR 58023, CORRECT NAME IS PIC2085491765 ###

