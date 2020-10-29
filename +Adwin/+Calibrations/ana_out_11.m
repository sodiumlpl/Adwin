function voltage = ana_out_11(value)

ofs = -0.07;
Imax = 112.4;

%voltage = value;

voltage = (0<=value & value<=Imax)*(value/(Imax/(10-ofs))+ofs) + (value<0)*ofs + (value>Imax)*10;

end