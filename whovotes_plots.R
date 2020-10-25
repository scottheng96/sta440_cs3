library(brms)
real_model = readRDS("whovotes_model_01var.rda.rds")
param_names = parnames(real_model)[1:10]
for (name in param_names){
  png(filename = paste("./plots/diagplot_", name), type = "cairo")
  plot(real_model, pars = c(name), ask = FALSE)
  dev.off()
}
