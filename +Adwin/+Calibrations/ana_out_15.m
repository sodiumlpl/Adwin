function voltage = ana_out_15(value)

voltage = (0<=value & value<=102.3).*(value/(102.3/(10+0.01))-0.01) + (value<0)*-0.01 + (value>102.3)*10;

end