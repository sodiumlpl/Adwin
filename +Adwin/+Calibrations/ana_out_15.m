function voltage = ana_out_15(value)

%-----Location of the data files-----%
path = 'C:\Users\BEC\Documents\data\2014\10\03\';
name = 'efficiency_vs_analogic_voltage_AOM_350MHz.txt'; % AOM Laser lock
filename = strcat(path,name);

%-----Importation of the data-----%
datafile = importdata(filename);
data     = datafile.data;
headers  = datafile.textdata;

%-----Spline interpolation-----%
data(:,2) = data(:,2)/max(data(:,2));

minVal  = min(data(:,2));
maxVal  = max(data(:,2));
value   = (value<minVal)*minVal + (minVal<=value & value<=maxVal)*value + (value>maxVal)*maxVal;
pp      = spline(data(:,2),data(:,1));
v       = ppval(pp,value);
voltage = (3<=v & v<=8)*v + (v>8)*8; % Keeps the voltage in the range [3 V; 8 V]

end