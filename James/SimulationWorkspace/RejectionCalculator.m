trueRejectFAr = sum(FARice>.5398)/length(FAgauss)
trueRejectFAg = sum(FAgauss>.6247)/length(FAgauss)
trueRejectDg = sum(Dg>17.5348)/length(FAgauss)
trueRejectDr = sum(Dr>11.1244)/length(FAgauss)

x = L1/L2

vals = [x; trueRejectFAr; trueRejectFAg; trueRejectDg; trueRejectDr]