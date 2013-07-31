function ssr = signalRatio(x, R, Dv, b)

u = R*x;
    
ssr = exp(-b*u'*Dv*u);
