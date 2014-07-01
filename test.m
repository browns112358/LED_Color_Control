f = @(x,y)x.^3-2*y-5;
x = fminbnd(f, 0, 2)