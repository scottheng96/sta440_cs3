library(brms)
var1 <- readRDS("whovotes_model_01var.rda.rds")
var001<- readRDS("whovotes_model_strongest.rda.rds")
brms::kfold(var1, var001, K = 10)