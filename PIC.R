library(tidyverse)
library(knitr)
library(dplyr)
library(lubridate)
library(stringr)
library(writexl)
library(here)

pigraw<-read_csv("C:/Users/vance/Documents/projects/2019/01JAN/Data Pull/pig.csv", 
                 col_types = cols(Index = col_number()))
collraw<-read_csv("C:/Users/vance/Documents/projects/2019/01JAN/Data Pull/coll.csv")

pigraw$Date_Arrival<-as.Date(pigraw$Date_Arrival)
pigraw$Date_Studout<-as.Date(pigraw$Date_Studout)
collraw$Col_Date<-as.Date(collraw$Col_Date)

pic1<-left_join(x = collraw,y = pigraw, by=c("BoarID"="BoarID"))

pic2<-pic1 %>% 
  filter(`Boar Stud.x`%in%c('SPGVA', 'MB 7081', 'MB 7082'),
         Date_Arrival>'2020-01-01',
         Breed%in%c('PICL02','PICL03'),
         `Collection Status`%in%c('US','TR'),
         !Col_Date=='2020-09-20',
         `Boar Status`=='WORKING')

# pictt<-pic1 %>% 
#   group_by(BoarID) %>% 
#   filter(`Boar Stud.x`%in%c('SPGVA', 'MB 7081', 'MB 7082'),
#          Date_Arrival>'2020-01-01',
#          Breed%in%c('PICL02','PICL03'),
#          `Collection Status`%in%c('NC'),
#          !Col_Date=='2020-09-20',
#          Col_Date==max(Col_Date))

pic3<-pic2 %>% 
  group_by(`Boar Stud.x`,Breed) %>% 
  summarise('Boars Trained'=n_distinct(BoarID))

pic4<-pic2 %>% 
  group_by(`Boar Stud.x`,Breed) %>% 
  filter(`Collection Status`=='US') %>% 
  summarise('Boars Producing'=n_distinct(BoarID))

pic5<-pic2 %>% 
  group_by(`Boar Stud.x`,Breed) %>% 
  filter(`Collection Status`=='US',
         Col_Date>=floor_date(x = today(),unit = "week",week_start = 7)-21) %>% 
  summarise('Doses Per Collection'=mean(Tot_Sperm)/2)

pic6<-pigraw %>% 
  filter(`Boar Stud`%in%c('SPGVA', 'MB 7081', 'MB 7082'),
         Date_Arrival>'2020-01-01',
         Breed%in%c('PICL02','PICL03'),
         `Boar Status`=='WORKING') %>% 
  group_by(`Boar Stud`,Breed) %>% 
  summarise('Total Boars in Stud'=n_distinct(BoarID))

pic7<-left_join(x = pic6,y = pic3,by=c("Boar Stud"="Boar Stud.x","Breed"="Breed"))
pic8<-left_join(x = pic7,y = pic4,by=c("Boar Stud"="Boar Stud.x","Breed"="Breed"))
pic9<-left_join(x = pic8,y = pic5,by=c("Boar Stud"="Boar Stud.x","Breed"="Breed"))

pic9$`Untrained Boars`<-pic9$`Total Boars in Stud`-pic9$`Boars Trained`

pic9<-pic9[c(1,2,4,3,7,5,6)]

write_csv(x = pic9,path = here::here("PIC_Update.csv"))

pic10<-pic2 %>% 
  group_by(`Boar Stud.x`,Breed, Date_Arrival) %>% 
  summarise('Boars Trained'=n_distinct(BoarID))

pic11<-pigraw %>% 
  filter(`Boar Stud`%in%c('SPGVA', 'MB 7081', 'MB 7082'),
         Date_Arrival>'2020-01-01',
         Breed%in%c('PICL02','PICL03')) %>%  
  group_by(`Boar Stud`,Breed, Date_Arrival) %>% 
  summarise('Total Boars Entered'=n_distinct(BoarID))

pic12<-pigraw %>% 
  filter(`Boar Stud`%in%c('SPGVA', 'MB 7081', 'MB 7082'),
         Date_Arrival>'2020-01-01',
         Breed%in%c('PICL02','PICL03'),
         `Boar Status`=='WORKING') %>% 
  group_by(`Boar Stud`,Breed, Date_Arrival) %>% 
  summarise('Working Boars'=n_distinct(BoarID))


pic13<-left_join(x = pic11,y = pic12,by=c("Boar Stud"="Boar Stud","Date_Arrival"="Date_Arrival", "Breed"="Breed"))
pic14<-left_join(x = pic13,y = pic10,by=c("Boar Stud"="Boar Stud.x","Date_Arrival"="Date_Arrival", "Breed"="Breed"))


