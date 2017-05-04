function voltage = ana_out_3(value)

%-----Calibration data 04/07/2016-----%
volt = 0:0.5:10;
freq = [64.57 67.93 71.41 75.00 78.46 81.61 84.54 87.37 90.09 92.91 95.74 ...
    98.57 101.50 104.43 107.48 110.52 113.67 116.83 119.98 123.13 126.28];

%-----Spline interpolation-----%
pp = spline(freq,volt);
v = ppval(pp,value);

%-----Output value-----%
voltage = (0<=v & v<=10)*v + (v>10)*10; % Keeps the voltage in the range [0 V; 10 V]

end