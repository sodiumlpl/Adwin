function voltage = ana_out_1(value)

%-----Calibration data 04/07/2016-----%
volt = 0:0.5:10;
freq = [129.57 134.65 141.91 148.39 154.22 159.70 165.04 170.30 175.52 ...
    180.87 186.54 192.45 198.37 204.10 210.15 216.71 223.28 229.67 235.63 241.21 247.43];

%-----Spline interpolation-----%
pp = spline(freq,volt);
v = ppval(pp,value);

%-----Output value-----%
voltage = (0<=v & v<=10)*v + (v>10)*10; % Keeps the voltage in the range [0 V; 10 V]

end