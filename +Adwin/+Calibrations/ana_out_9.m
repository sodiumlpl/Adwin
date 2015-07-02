function voltage = ana_out_9(value)
    % AOM @ 1.7 GHz diffraction efficiency calibration
    
    %-----Calibration data-----%
    x = [0.37 0.40 0.44 0.65 1.03 1.65 2.68 3.80 4.84 5.22 5.77 5.80 6.15 6.18 6.31 6.37];
    x = x/max(x); % To have an efficiency <=1
    y = [3 3.5 4 4.25 4.5 4.75 5 5.25 5.5 5.75 6 6.25 6.5 6.75 7 7.5];
    
    %-----Interpolation of the data-----%
    pp = griddedInterpolant(x,y,'pchip');
    
    %-----Restrict the input value between min(x) and max(x)-----%
    value = (min(x)<=value & value<=max(x))*value + (value<min(x))*min(x) + (max(x)<value)*max(x);
    
    if (value == 0)
        voltage = 0;
    else
        voltage = pp(value);
    end
    
end