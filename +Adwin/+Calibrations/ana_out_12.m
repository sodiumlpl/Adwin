function voltage = ana_out_12(value)

% EOM MOT amplitude calibration

%-----Calibration data-----%
ampctrl  = [1 2 3 3.5 4 4.2 4.4 4.6 4.7 4.8 4.9 5 5.05 5.1 5.15 5.2 5.3 5.4 5.5 5.6 5.8 6 6.2 6.5 7 8];
SBamp = [0 8 14 22 44 60 84 114 128 148 168 190 200 216 226 240 254 274 290 304 336 356 368 386 400 404];
SBampmax = 404;

SBpourcent = SBamp/SBampmax;

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