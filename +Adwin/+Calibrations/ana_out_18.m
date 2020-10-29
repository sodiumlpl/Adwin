function voltage = ana_out_18(value)

voltage = (0<=value & value<=61.4)*(value/(61.4/(10-0.17))+0.17) + (value<0)*0.17 + (value>61.4)*10;

end