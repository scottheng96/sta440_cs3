library(brms)
library(dplyr)
library(tidyr)

voters <- readRDS("./data/ncvoter_Statewide_small.rds")
his <- readRDS("./data/ncvhis_Statewide_small.rds")
voters$voter_reg_num <- as.character(voters$voter_reg_num)
voters$voter_reg_num <- as.integer(voters$voter_reg_num)
voters_history <- merge(voters, his, by=c("voter_reg_num", "county_id")) 
voters_history <- voters_history %>% mutate(
  year_at_election = as.numeric(format(as.Date(election_lbl, "%m/%d/%Y"), "%Y"))
)
voters_history <- voters_history %>% mutate(
  age_at_election = year_at_election - birth_year
)
# Create age group variable w/ census categories
voters_history <- voters_history %>% mutate(
  age_group = case_when(
    age_at_election  <= 24 ~ "18-24",
    (age_at_election > 24) & (age_at_election <=44) ~ "25-44",
    (age_at_election > 44) & (age_at_election <= 64) ~ "45-64",
    age_at_election >= 65 ~ "65+"
  )
)
voters_history_condensed <- voters_history %>% 
  group_by(race_code, gender_code, ethnic_code, age_group, county_desc.x, election_lbl) %>% summarise(n = n())
voters_expanded = voters
voters_expanded$election_lbl = unique(voters_history$election_lbl)[1]
for (election in unique(voters_history$election_lbl)[2:length(unique(voters_history$election_lbl))]){
  temp = voters
  temp$election_lbl = election
  voters_expanded = rbind(voters_expanded, temp)
}
voters_expanded <- voters_expanded %>% mutate(
  year_at_election = as.numeric(format(as.Date(election_lbl, "%m/%d/%Y"), "%Y"))
)
voters_expanded <- voters_expanded %>% mutate(
  age_at_election = year_at_election - birth_year
)
# Create age group variable w/ census categories
voters_expanded <- voters_expanded %>% mutate(
  age_group = case_when(
    age_at_election  <= 24 ~ "18-24",
    (age_at_election > 24) & (age_at_election <=44) ~ "25-44",
    (age_at_election > 44) & (age_at_election <= 64) ~ "45-64",
    age_at_election >= 65 ~ "65+"
  )
)
# Create totals of voters registered 
registered_voters <- voters_expanded %>% group_by(race_code, gender_code, ethnic_code, election_lbl, age_group, county_desc) %>% summarise(n_registered = n())
voters_history_condensed <- voters_history_condensed %>% rename(county_desc = county_desc.x)
modeling_data <- inner_join(voters_history_condensed, registered_voters, by = c("race_code", "gender_code", "ethnic_code","age_group", "election_lbl", "county_desc"))
# Creating a model
adm1 <-
  brm(data = modeling_data, family = binomial,
      n | trials(n_registered) ~ 1 + race_code + gender_code + ethnic_code + election_lbl + age_group + race_code * gender_code + race_code * ethnic_code + race_code * election_lbl + race_code * age_group + gender_code * ethnic_code + gender_code * election_lbl + gender_code * age_group +ethnic_code * election_lbl + ethnic_code * age_group + election_lbl * age_group +  (1|county_desc),
      prior = c(prior(normal(0, 1), class = Intercept),
                prior(normal(0, 1), class = b),
                prior(normal(0, 1), class = sd)),
      iter = 5000, warmup = 500, cores = 2, chains = 2,
      seed = 10, file = "whovotes_model.rda")
summary(adm1)
