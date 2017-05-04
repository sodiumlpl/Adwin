function voltage = ana_out_16(value)

%-----Calibration data 27/07/2016-----%
volt = [4 4.5 5 5.5 5.6 5.7 5.8 5.9 6 6.1 6.2 6.3 6.4 6.5 6.6 ...
    6.7 6.8 6.9 7 7.1 7.2 7.3 7.4 7.5 7.6 7.7];
amp = [0.021 0.0225 0.0368 0.230 0.362 0.577 0.908 1.42 2.16 3.28 ...
    4.78 6.83 9.60 13.1 17.6 23.2 29.3 35.3 40.4 44.7 48.9 51.8 53.7 54.4 55 55.2]/55.2;

%-----Spline interpolation-----%
pp = spline(amp,volt);
v = ppval(pp,value);

%-----Output value-----%
voltage = (4<=v & v<=7.7)*v + (v>7.7)*7.7; % Keeps the voltage in the range [4 V; 7.7 V]

end