function voltage = ana_out_5(value)

%-----Calibration data 04/07/2016-----%

% volt = [4 5 5.5 5.6 5.7 5.8 5.9 6 6.1 6.2 6.3 6.4 6.5 6.6];
% amp = [328e-3 545e-3 3.59 5.62 8.69 13.2 19.5 27.8 37.9 49.2 59.8 69 74.7 75.7]/75.7;

volt = [5.3 5.5 5.6 5.7 5.8 5.9 6 6.1 6.2 6.3 6.4 6.6];
amp = [0 3.59 5.62 8.69 13.2 19.5 27.8 37.9 49.2 59.8 69 75.7]/75.7;

%-----Spline interpolation-----%
pp = spline(amp,volt);
v = ppval(pp,value);

%-----Output value-----%
voltage = (4<=v & v<=6.6)*v + (v>6.6)*6.6; % Keeps the voltage in the range [6.5 V; 10 V]

%voltage = value;

end