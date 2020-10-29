function voltage = ana_out_20(value)

ofs = -0.01;

voltage = (0<=value & value<=53.2)*(value/(53.2/(10-ofs))+ofs) + (value<0)*ofs + (value>53.2)*10;

end