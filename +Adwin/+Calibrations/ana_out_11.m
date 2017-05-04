function voltage = ana_out_11(value)
%     %-----Calibration data-----%
%     x_vec = [-0.045 0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.60 0.70 0.80 0.85 1 1.5 2 2.5 3];
%     y_vec = [0 0.9 2.0 3.1 4.2 5.3 6.4 7.5 8.6 9.7 10.8 11.8 14.0 16.2 18.4 19.5 23 33.9 44.9 55.8 65.2];
% 
%     %-----Interpolation of the data-----%
%     pp = griddedInterpolant(y_vec,x_vec,'pchip'); % pp is a function
% 
%     %-----Restrict the input value between 0 and 1-----%
%     value = (0<=value & value<=max(y_vec))*value + (value<0)*0 + (max(y_vec)<value)*max(y_vec);
% 
%     %-----Return value-----%
%     voltage = pp(value);

    %%% Test contrôle Alim 3 avec switch 3 
%     %-----Calibration data-----%
%     x_vec = [0 0.05 0.1 0.2 0.3 0.4 0.5 1 1.5 2 2.5 3];
%     y_vec = [1.0 2.0 3.1 5.1 7.2 9.3 11.3 21.6 31.5 41.5 51.4 61.4];
% 
%     %-----Interpolation of the data-----%
%     pp = griddedInterpolant(y_vec,x_vec,'pchip'); % pp is a function
% 
%     %-----Restrict the input value between 0 and 1-----%
%     value = (0<=value & value<=max(y_vec))*value + (value<0)*0 + (max(y_vec)<value)*max(y_vec);
% 
%     %-----Return value-----%
%     voltage = pp(value);

voltage = (0<=value & value<=112.4).*(value/112.4*(10+0.06)-0.06) + (value<0)*-0.06 + (value>112.4)*10;

end