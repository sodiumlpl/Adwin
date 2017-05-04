function voltage = ana_out_13(value)

voltage = (0<=value & value<=102.3).*(value/102.3*(10+0.03)-0.03) + (value<0)*-0.03 + (value>102.3)*10;

end