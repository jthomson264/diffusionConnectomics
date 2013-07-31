source("~/code/wam2nbyk.R")
library("calibrate")

bootScans = "~/data/p1s1/csvlist"
bootCSVs = read.table(bootScans, header=FALSE)
bootCSVs = t(listOfCSVs)
print("BootCSVs is ")
print(bootCSVs)
print("That was bootcsvs")
#bootCSVs = paste("~/data/p1s1/", bootCSVs, sep="")


paramScans = "/media/data2/randomParameters/listcsvs.txt"
paramCSVs = read.table(paramScans, header=FALSE)
paramCSVs = t(paramCSVs)
paramCSVs = paste("/media/data2/randomParameters/", paramCSVs, sep="")
print(paramCSVs)
print("That was paramcsvs")


scans=c("p0s1", "p1s1", "p1s2", "p2s1", "p3s1", "p4s1", "p4s2", "p5s1", "p5s2")
csvNames = paste("~/data/", scans, "/data.nii.src.gz.odf6.f3.gqi.1.2.fib.gz.trk.big.trk.bw_matrix.csv", sep="")
listOfCSVs = csvNames
print(listOfCSVs)
print("that was list")


bootNames = paste("b", 1:length(bootCSVs), sep="")
paramNames = paste("p", 1:length(paramCSVs), sep="")

bootColors = rep("blue", length(bootNames))
paramColors = rep("green", length(paramNames))
scanColors = rep("red", length(scans))

bootPCH = rep(1, length(bootNames))
paramPCH = rep(1, length(paramNames))
scanPCH = c(6, 1, 1, 2, 3, 4, 4, 5, 5)

scans = c(scans, bootNames, paramNames)
listOfCSVs = c(csvNames, bootCSVs, paramCSVs)
print(listOfCSVs)
print("that was lissst of csvs")


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
stD = mean(sd(dmat))
dmat2 = exp(-dmat / (2 * stD))
eigenfoo = eigen(dmat2)
xvals = dmat2 %*% eigenfoo$vectors[,1]
yvals = dmat2 %*% eigenfoo$vectors[,2]
library("calibrate")


pdf("projectionOfScanDistances.pdf")
plot(xvals,yvals, main = " ", xlab="", ylab="", col = c(scanColors, bootColors, paramColors), pch = c(scanPCH, bootPCH, paramPCH))
textxy(xvals,yvals,labs=scans)
dev.off()