#
# fuzzer-mod.R, 21 Sep 18
#
# Data from:
# Comparative Language Fuzz Testing: Programming Languages vs. Fat Fingers
# Diomidis Spinellis and Vassilios Karakoidas and Panos Louridas
#
# Example from:
# Evidence-based Software Engineering: based on the publicly available data
# Derek M. Jones
#
# TAG fuzzing testing


source("ESEUR_config.r")

library("plyr")


prog_len=function(df)
{
df$prog_len=prog_lang_len[unique(df$program), unique(df$language)]
return(df)
}


fuzz=read.csv(paste0(ESEUR_dir, "reliability/fuzzer/fuzzer.csv.xz"), as.is=TRUE)
prog_lang_len=read.csv(paste0(ESEUR_dir, "reliability/fuzzer/prog_len.csv.xz"),
			as.is=TRUE, row.names=1)

fuzz=ddply(fuzz, .(program, language), prog_len)

comp_fuzz=subset(fuzz, fuzz_status == "OK")

y=cbind(comp_fuzz$comp_status == "OK", comp_fuzz$comp_status != "OK")

# sl=glm(comp_status == "OK" ~ log(prog_len), data=comp_fuzz)

comp_mod=glm(y ~ language+operation+log(prog_len)
				+language:prog_len,
				data=comp_fuzz,
				family=binomial)
# Number of lines has the largest impact in C#
# c_comp_fuzz=subset(comp_fuzz, language == "cs")
# c_y=cbind(c_comp_fuzz$comp_status == "OK", c_comp_fuzz$comp_status != "OK")
# comp_lmod=glm(c_y ~ log(prog_len),
# 				data=c_comp_fuzz,
# 				family=binomial)
# summary(comp_lmod)

comp_mod=glm(y ~ language + operation + log(prog_len)
				+program:language 
    				+operation:(program+log(prog_len)),
				data=comp_fuzz,
				family=binomial)

# comp_mod=glm(y ~ (program+language+operation+log(prog_len))^2
# 				-program:log(prog_len)-program,
# 				data=comp_fuzz,
# 				family=binomial)
# comp_mod=glm(y ~ program+language+operation, data=comp_fuzz,
# 				family=binomial)


summary(comp_mod)


run_fuzz=subset(fuzz, comp_status == "OK")

y=cbind(run_fuzz$run_status == "OK", run_fuzz$run_status != "OK")

run_mod=glm(y ~ language + operation + log(prog_len)
				+program:language 
    				+operation:(program+log(prog_len)),
				data=run_fuzz,
				family=binomial)
# run_mod=glm(y ~ (program+language+operation+log(prog_len))^2
# 				-program:log(prog_len)-program,
# 				data=run_fuzz,
# 				family=binomial)
# min_mod=stepAIC(run_mod)

summary(run_mod)

# run_mod=glm(run_status ~ language+operation+prog_len:language, data=run_fuzz,
# 				family=binomial)

exe_fuzz=subset(fuzz, run_status == "OK")

y=cbind(exe_fuzz$out_status == "OK", exe_fuzz$out_status != "OK")

exe_mod=glm(y ~ language + operation + log(prog_len)
				+program:language 
    				+operation:(program+log(prog_len)),
				data=exe_fuzz,
				family=binomial)
#exe_mod=glm(y ~ (program+language+operation+log(prog_len))^2
#				-program:log(prog_len)-program,
#				data=exe_fuzz,
#				family=binomial)
#min_mod=stepAIC(exe_mod)

summary(exe_mod)


library("car")

Anova(exe_mod)

