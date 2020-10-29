function voltage = ana_out_17(value)

voltage = (0<=value & value<=61.4)*(value/(61.4/(9.9-0.1))+0.1) + (value<0)*0.1 + (value>61.4)*9.9;

%voltage = value;

end