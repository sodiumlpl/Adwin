function voltage = ana_out_8(value)

% \\TIBO-HP\Users\tibo\Documents\Measurements\2015\02\05_EOM_Zeeman_driver_calibration

slope = 25.2717;
y_intercept = -40.0403;

if value<-y_intercept/slope
    
    value = -y_intercept/slope;
    
elseif value > (5.5-y_intercept)/slope
    
    value = (5.5-y_intercept)/slope;
    
end

voltage = slope*value+y_intercept;

end