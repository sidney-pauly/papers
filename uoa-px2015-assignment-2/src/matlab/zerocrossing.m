function zcarr = zerocrossing(xarr,yarr)

% xarr - array of x_i = x_1, x_2, ... x_n 
% xarr - array of y_i = y(x_i) 
% zcarr - array of zero crossings 
% z_j = z_1, z_2, ... x_m
% such that y(z_j) = 0 and m < n 
% NB. x_1 <= z_j <= x_n but 
% z_j may not be a subset of x_i 

sarr = sign(yarr);
zarr0 = find(sarr == 0);

darr = diff(sarr);
zarr1 = find(darr == 2);
zarr2 = find(darr == -2);

length0 = length(zarr0);
length1 = length(zarr1);
length2 = length(zarr2);

zcarr = zeros(1,length0+length1+length2);

if length0 == 0 
    k=0;
else
    for k = 1:length0
        zcarr(k) = xarr(zarr0(k));
    end 
end

for i = [zarr1 zarr2]
    k = k + 1;
    dx = xarr(i + 1) - xarr(i);
    zcarr(k) = xarr(i) + abs(yarr(i)/(yarr(i+1)-yarr(i)))*dx;
end

zcarr = sort(zcarr);


