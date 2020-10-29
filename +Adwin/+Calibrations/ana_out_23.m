function voltage = ana_out_23(value)

ofs = 0.05;

voltage = (0<=value & value<=24.6)*(value/(24.6/(10-ofs))+ofs) + (value<0)*ofs + (value>24.6)*10;

end