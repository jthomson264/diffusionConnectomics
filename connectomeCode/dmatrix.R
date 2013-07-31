source("~/code/wam2nbyk.R")
library("calibrate")

scans=c("p1s1", "p1s2", "p2s1", "p3s1", "p4s1", "p4s2", "p5s1", "p5s2")
csvNames = paste("~/data/", scans, "/data.nii.src.gz.odf6.f3.gqi.1.2.fib.gz.trk.big.trk.bw_matrix.csv", sep="")
listOfCSVs = csvNames
print(listOfCSVs)

firstCSV = listOfCSVs[1]
listOfCSVs = listOfCSVs[-1]

firstbwm = read.csv(firstCSV, header=FALSE)


allNbyKs = matrix2vector(firstbwm)


for (csvname in listOfCSVs)
{

cur_bwm <- read.csv(csvname, header=FALSE)

print(dim(cur_bwm))

cur_bwm_nbyk <- matrix2vector(cur_bwm)

allNbyKs = cbind(allNbyKs, cur_bwm_nbyk)

}

nScans=dim(allNbyKs)[2]
dmat=array(0,dim=c(nScans,nScans))

for (i in 1:(nScans-1))
{
	for (j in (i+1):(nScans))
	{
		firstVector = allNbyKs[,i]
		secondVector = allNbyKs[,j]
		difference = allNbyKs[,i] - allNbyKs[,j]
		distance = t(difference) %*% difference
		dmat[i,j] = distance
		dmat[j,i] = distance
	}
}

dmat = sqrt(dmat)
dmat2 = 1 / (dmat + 1)
eigenfoo = eigen(dmat2)
xvals = dmat2 %*% eigenfoo$vectors[,1]
yvals = dmat2 %*% eigenfoo$vectors[,2]
library("calibrate")


pdf("projectionOfScanDistances.pdf")
plot(xvals,yvals)
textxy(xvals,yvals,labs=scans)
dev.off()