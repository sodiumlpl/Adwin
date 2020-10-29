function voltage = ana_out_24(value)

ofs = 0.1;

voltage = (0<=value & value<=72)*(value/(72/(10-ofs))+ofs) + (value<0)*ofs + (value>72)*10;

end