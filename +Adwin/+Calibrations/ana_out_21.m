function voltage = ana_out_21(value)

ofs = 0.06;

voltage = (0<=value & value<=22.5)*(value/(22.5/(10-ofs))+ofs) + (value<0)*ofs + (value>22.5)*10;

end