function voltage = ana_out_10(value)
    % EOM Zeeman amplitude calibration
    
    %-----Calibration data-----%
    ampctrl  = [1.5 2. 2.5 3 3.5 4 4.5 4.6 4.7 4.8 4.9 5 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 6.0];
    Portamp = [1141 1140 1120 1110 1090 1089 1050 1020 1000 984 976 968 944 943 936 912 904 896.4 896.3 896.2 896.1 896];
    Portampmax = 1160;

    SBpourcent = (1-Portamp/Portampmax)/2; % divided by 2 because there are two sidebands

    %-----Renormalise the values between 0 and 1-----%
    SBmin      = min(SBpourcent);
    SBmax      = max(SBpourcent);
    SBpourcent = ( SBpourcent - SBmin ) / ( SBmax - SBmin);

    %-----Interpolation of the data-----%
    pp = griddedInterpolant(SBpourcent,ampctrl,'pchip'); % pp is a function

    %-----Restrict the input value between 0 and 1-----%
    value = (0<=value & value<=1)*value + (value<0)*0 + (1<value)*1;

    if (value == 0)
        voltage = 0;
    else
        voltage = pp(value);
    end
    
end