function voltage = ana_out_26(value)

ofs = 0.03;

voltage = (0<=value & value<=15.35)*(value/(15.35/(10-ofs))+ofs) + (value<0)*ofs + (value>15.35)*10;

end