function randPoint = rnp()

start = random('norm',0,1,3,1);
sizestart = start'*start;
randPoint = start/sqrt(sizestart);