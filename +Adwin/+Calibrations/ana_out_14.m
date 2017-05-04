function voltage = ana_out_14(value)

voltage = (0<=value & value<=15.34)*(value/(15.34/(10+0.02))-0.02) + (value<0)*-0.02 + (value>15.34)*10;

end