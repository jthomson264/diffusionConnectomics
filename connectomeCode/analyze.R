dirr = "p1s1"
source("~/code/wam2nbyk.R")

listfiles = paste("~/data/", dirr, "/csvlist", sep="")

print(listfiles)

listOfCSVs = read.table(listfiles, header=FALSE)
listOfCSVs = t(listOfCSVs)
listOfCSVs = paste("~/data/", dirr, "/", listOfCSVs, sep="")

print(listOfCSVs)

ogfile = read.csv("~/data/p1s1/data.src.gz.odf6.f3.gqi.1.2.fib.gz.trk.big.trk.bw_matrix.csv", header=FALSE)

print(dim(ogfile))

ognbyk = matrix2vector(ogfile)

allNbyKs = ognbyk

for (csvname in listOfCSVs)
{

cur_bwm <- read.csv(csvname, header=FALSE)

print(dim(cur_bwm))

cur_bwm_nbyk <- matrix2vector(cur_bwm)

allNbyKs = cbind(allNbyKs, cur_bwm_nbyk)

}