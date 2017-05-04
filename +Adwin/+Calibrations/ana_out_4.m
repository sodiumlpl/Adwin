function voltage = ana_out_4(value)

%-----Calibration data 04/07/2016-----%

% volt = [5 5.5 6 6.5 6.6 6.7 6.8 6.9 7 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 ...
%     8 8.1 8.2 8.5 9 9.5 10];
% amp = [0.17e-3 2.64e-3 34.3e-3 302e-3 450e-3 638e-3 862e-3 1.16 1.48 1.89 ...
%     2.34 2.82 3.29 3.82 4.36 4.82 5.34 5.72 6.16 6.53 6.74 7.55 8.21 8.42 8.45]/8.45;

volt = [6.5 6.6 6.7 6.8 6.9 7 7.1 7.2 7.3 7.4 7.5 7.6 7.7 7.8 7.9 ...
    8 8.5 10];
amp = [302e-3 450e-3 638e-3 862e-3 1.16 1.48 1.89 ...
    2.34 2.82 3.29 3.82 4.36 4.82 5.34 5.72 6.16 7.55 8.45]/8.45;

%-----Spline interpolation-----%
pp = spline(amp,volt);
v = ppval(pp,value);

%-----Output value-----%
voltage = (6.5<=v & v<=10)*v + (v>10)*10; % Keeps the voltage in the range [6.5 V; 10 V]

end