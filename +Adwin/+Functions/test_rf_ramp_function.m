function val = test_rf_ramp_function(t)

alpha = 8;

nu_i = evalin('base','rf_start');

nu_f = evalin('base','rf_end');

y=@ (t) (nu_i-nu_f)/(1-exp(-alpha))*exp(-alpha*t)+(nu_f-nu_i*exp(-alpha))/(1-exp(-alpha));

val = y(t);

end