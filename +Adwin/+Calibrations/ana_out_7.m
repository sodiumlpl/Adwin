function voltage = ana_out_7(value)

% \\TIBO-HP\Users\tibo\Documents\Measurements\2015\02\04_AOM_1.7GHz_calibration

slope = 24.2168;
y_intercept = -38.7959;

if value<-y_intercept/slope
    
    value = -y_intercept/slope;
    
elseif value > (5.5-y_intercept)/slope
    
    value = (5.5-y_intercept)/slope;
    
end

voltage = slope*value+y_intercept;

end