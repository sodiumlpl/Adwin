function voltage = ana_out_25(value)

ofs = 0.01;

voltage = (0<=value & value<=112.4)*(value/(112.4/(10-ofs))+ofs) + (value<0)*ofs + (value>112.4)*10;

end