function voltage = ana_out_6(value)

% \\TIBO-HP\Users\tibo\Documents\Measurements\2014\10\31_EOM_MOT_calibration

slope = 25.2955;
y_intercept = -40.5824;

if value<-y_intercept/slope
    
    value = -y_intercept/slope;
    
elseif value > (5-y_intercept)/slope
    
    value = (5-y_intercept)/slope;
    
end

voltage = slope*value+y_intercept;

end