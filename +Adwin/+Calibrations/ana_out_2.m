function voltage = ana_out_2(value)

%-----Calibration data 04/07/2016-----%
volt = 0:0.5:10;
freq = [65.39 68.22 71.5 74.83 78.35 81.48 84.43 87.28 90.13 93.00 95.91 ...
    98.87 101.94 105.09 108.30 111.61 115.00 118.39 121.87 125.35 128.83];

%-----Spline interpolation-----%
pp = spline(freq,volt);
v = ppval(pp,value);

%-----Output value-----%
voltage = (0<=v & v<=10)*v + (v>10)*10; % Keeps the voltage in the range [0 V; 10 V]

end