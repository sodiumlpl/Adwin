function voltage = ana_out_19(value)

ofs = 0.12;

voltage = (0<=value & value<=30.7)*(value/(30.7/(10-ofs))+ofs) + (value<0)*ofs + (value>30.7)*10;

end