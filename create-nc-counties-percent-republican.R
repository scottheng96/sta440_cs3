library(dplyr)

setwd('/Users/huntergregory/OneDrive - Duke University/Documents/Duke/7th semester/case studies/sta440_cs3/')

# other_county_names = toupper(unique(full_counties$county_name))
# county_names = unique(voter_history$county_desc)
# other_county_names[! other_county_names %in% county_names]
# county_names[! county_names %in% other_county_names]

create_percent_republican_counties = function(year, filename) {
  voter_history = readRDS('data/ncvhis_Statewide_small.rds')
  vh_main_parties = voter_history %>% 
    filter(
      election_lbl == year,
      voted_party_desc %in% c('REPUBLICAN', 'DEMOCRATIC')
    )
  
  ## creating csv with % republican, county name, and id (ids + names based on "full_counties")
  
  convert_name = function(county_name) {
    county_name = toupper(county_name)
    ifelse(grepl('-', county_name), 
           substr(county_name, 1, nchar(county_name)-2), 
           county_name)
  }
  
  republican_percentages = c()
  for (county_name in full_counties$county_name) { # works because this is unique
    vh_by_county = vh_main_parties[vh_main_parties$county_desc == convert_name(county_name),]
    p = mean(vh_by_county$voted_party_desc == 'REPUBLICAN')
    republican_percentages = c(republican_percentages, p)
  }
  
  # if we do % republican by demographic, we should introduce 0.5 (50%) for counties without any history
  updated_full_counties = full_counties %>% mutate(Republican.percentage = republican_percentages)
  write.csv2(updated_full_counties, filename)
}

create_percent_republican_counties('11/08/2016', 'NC-counties-percent-republican-2016.csv')
create_percent_republican_counties('11/06/2018', 'NC-counties-percent-republican-2018.csv')
