function voltage = ana_out_14(value)

ofs = -0.04;
Vmax = 15.35;

voltage = (0<=value & value<=Vmax)*(value/(Vmax/(10-ofs))+ofs) + (value<0)*ofs + (value>Vmax)*10;

%voltage = value;

end