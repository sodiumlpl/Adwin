function voltage = ana_out_13(value)

voltage = (0<=value & value<=102.3).*(value/102.3*(9.99+0.04)-0.04) + (value<0)*-0.04 + (value>102.3)*9.99;

%voltage = value;
end