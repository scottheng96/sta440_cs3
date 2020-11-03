library(lme4)
library(tidyverse)
modeling_data <- read_csv("./data/whovotes_train_data_final.csv")
dupe_counties <- modeling_data %>% filter(county_desc %in% c("CATAWBA", "CHATHAM", "FORSYTH", "HARNETT", "IREDELL", "LEE", "MECKLENBURG", "MOORE", "PITT", "RUTHERFORD", "VANCE", "WAKE"))
dupe_counties <- dupe_counties %>% mutate(
  n = round(n/2),
  n_registered = round(n_registered/2)
)
dupe_counties <- dupe_counties %>% mutate(
  county_desc = paste(county_desc, "_2", sep = "")
)
modeling_data_split <- modeling_data %>% mutate(
  n = case_when(
    county_desc %in% c("CATAWBA", "CHATHAM", "FORSYTH", "HARNETT", "IREDELL", "LEE", "MECKLENBURG", "MOORE", "PITT", "RUTHERFORD", "VANCE", "WAKE") ~ round(n/2),
    !(county_desc %in% c("CATAWBA", "CHATHAM", "FORSYTH", "HARNETT", "IREDELL", "LEE", "MECKLENBURG", "MOORE", "PITT", "RUTHERFORD", "VANCE", "WAKE")) ~ n
  ),
  n_registered = case_when(
    county_desc %in% c("CATAWBA", "CHATHAM", "FORSYTH", "HARNETT", "IREDELL", "LEE", "MECKLENBURG", "MOORE", "PITT", "RUTHERFORD", "VANCE", "WAKE") ~ round(n_registered/2),
    !(county_desc %in% c("CATAWBA", "CHATHAM", "FORSYTH", "HARNETT", "IREDELL", "LEE", "MECKLENBURG", "MOORE", "PITT", "RUTHERFORD", "VANCE", "WAKE")) ~ n_registered
  )
)
modeling_data_split = rbind(modeling_data_split, dupe_counties)
# Coding congressional districts
modeling_data_split <- modeling_data_split %>% mutate(
  congressional_dist = case_when(
    county_desc %in% c("BERTIE", "EDGECOMBE", "GATES", "GREENE", "HALIFAX", "HERTFORD", "MARTIN", "NASH", "NORTHAMPTON", "PITT", "VANCE", "WARREN", "WASHINGTON", "WAYNE", "WILSON") ~ 1,
    county_desc %in% c("WAKE") ~ 2,
    county_desc %in% c("BEAUFORT", "CAMDEN", "CARTERET", "CHOWAN", "CRAVEN", "CURRITUCK", "DARE", "DUPLIN", "HYDE", "JONES", "LENOIR", "ONSLOW", "PAMLICO", "PASQUOTANK", "PERQUIMANS", "PITT_2", "TYRRELL") ~ 3,
    county_desc %in% c("CHATHAM", "DURHAM", "FRANKLIN", "GRANVILLE", "ORANGE", "VANCE_2", "WAKE_2") ~ 4,
    county_desc %in% c("ALEXANDER", "ALLEGHANY", "ASHE", "BURKE", "CALDWELL", "CATAWBA", "CLEVELAND", "GASTON", "RUTHERFORD", "WATAUGA", "WILKES") ~ 5,
    county_desc %in% c("FORSYTH", "GUILFORD") ~ 6,
    county_desc %in% c("BLADEN", "BRUNSWICK", "COLUMBUS", "HARNETT", "JOHNSTON", "NEW HANOVER", "PENDER", "SAMPSON") ~ 7,
    county_desc %in% c("CABARRUS", "CUMBERLAND", "HARNETT_2", "LEE", "MONTGOMERY", "MOORE", "STANLY") ~ 8,
    county_desc %in% c("ANSON", "HOKE", "MECKLENBURG", "MOORE_2", "RICHMOND", "ROBESON", "SCOTLAND", "UNION") ~ 9,
    county_desc %in% c("CATAWBA_2", "FORSYTH_2", "IREDELL", "LINCOLN", "ROCKINGHAM", "STOKES", "SURRY", "YADKIN") ~ 10,
    county_desc %in% c("AVERY", "BUNCOMBE", "CHEROKEE", "CLAY", "GRAHAM", "HAYWOOD", "HENDERSON", "JACKSON", "MACON", "MADISON", "MCDOWELL", "MITCHELL", "POLK", "RUTHERFORD_2", "SWAIN", "TRANSYLVANIA", "YANCEY") ~ 11,
    county_desc %in% c("MECKLENBURG_2") ~ 12,
    county_desc %in% c("ALAMANCE", "CASWELL", "CHATHAM_2", "DAVIDSON", "DAVIE", "IREDELL_2", "LEE_2", "PERSON", "RANDOLPH", "ROWAN") ~ 13
  )
)
# Change election_lbl to be binary presidential or not
modeling_data_split <- modeling_data_split %>% mutate(
  presidential = case_when(
    election_lbl == "11/06/2018" ~ 0,
    election_lbl == "11/08/2016" ~ 1
  )
)
validation_data <- validation_data %>% mutate(
  presidential = case_when(
    election_lbl == "11/04/2014" ~ 0,
    election_lbl == "11/06/2012" ~ 1
  )
)
# Need to group it by cong dist
modeling_data_split <- modeling_data_split %>% group_by(race_code, sex_code, ethnic_code, age_group, party_cd, gender_code, congressional_dist, presidential) %>% summarise(n = sum(n), n_registered = sum(n_registered))
modeling_data_sample <- modeling_data_split[sample(nrow(modeling_data_split), 5000),]

freq.fit <- glmer(n/n_registered ~ 1 + race_code + gender_code + ethnic_code + age_group + party_cd + presidential + race_code:gender_code + race_code:ethnic_code + race_code:age_group + gender_code:ethnic_code + gender_code:age_group + ethnic_code:age_group + (1 + race_code + gender_code + ethnic_code + age_group + party_cd + presidential + race_code:gender_code + race_code:ethnic_code + race_code:age_group + gender_code:ethnic_code + gender_code:age_group + ethnic_code:age_group||congressional_dist),
                      data = modeling_data_sample, weights = n_registered,
                      family = "binomial", control = glmerControl(optimizer="bobyqa", optCtrl=list(maxfun=2e5)))

saveRDS(freq.fit, "frequentist_whovotes_cluster.rds")
