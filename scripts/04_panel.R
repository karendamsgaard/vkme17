setwd("~/GitHub/vkme17")

library(tidyverse)
library(stargazer)
library(multiwayvcov)
library(lmtest)

#eksempel på brug af gather()
df_wide<-data.frame(unit=c("a","b","c"),yt1=c(1,3,6),yt2=c(2,6,7))
df_long<-gather(df_wide,year,outcome,yt1:yt2)

#hent data
lw<-readRDS("data/04_larsen_wide.rds")

#konverter til long form
ll<-lw %>% 
  gather(v,value,hp_1yr.2005:unemprate.2015) %>% 
  separate(v,into=c("var","year"),sep="\\.") %>% 
  arrange(valgstedid) %>% 
  spread(var,value) %>% 
  mutate(yrfac=factor(year),vstedfac=factor(valgstedid))

#baggrund: https://stackoverflow.com/a/24151902/3082968

#pooled OLS
pols<-lm(incsupport~hp_1yr,data=ll)
summary(pols)

#panel model m. LSDV
fe_lsdv<-lm(incsupport~hp_1yr+yrfac+vstedfac,data=ll)
summary(fe_lsdv)

#cluster-robuste se's m multiwayvcov
fe_cvcov<-coeftest(fe_lsdv,vcov=cluster.vcov(fe_lsdv,ll$vstedfac))
fe_cvcovses<-fe_cvcov[,2]

#alle estimater i én tabel
stargazer(pols,fe_lsdv,fe_lsdv,type="text",omit=c("yrfac","vstedfac"),
          se=list(NULL,NULL,fe_cvcovses))

#øvelse: lav en ekstra model med arbejdsløshed som tidsvarierende kovariat

