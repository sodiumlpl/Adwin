function voltage = ana_out_22(value)

ofs = -0.02;

voltage = (0<=value & value<=71.6)*(value/(71.6/(10-ofs))+ofs) + (value<0)*ofs + (value>71.6)*10;

end