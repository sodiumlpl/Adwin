function voltage = ana_out_11(value)
    %-----Calibration data-----%
    x_vec = [-0.045 0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.60 0.70 0.80 0.85];
    y_vec = [0 0.9 2.0 3.1 4.2 5.3 6.4 7.5 8.6 9.7 10.8 11.8 14.0 16.2 18.4 19.5];

    %-----Interpolation of the data-----%
    pp = griddedInterpolant(y_vec,x_vec,'pchip'); % pp is a function

    %-----Restrict the input value between 0 and 1-----%
    value = (0<=value & value<=max(y_vec))*value + (value<0)*0 + (max(y_vec)<value)*max(y_vec);

    %-----Return value-----%
    voltage = pp(value);
end