function voltage = ana_out_5(value)

%-----Location of the data files-----%
path = 'C:\Users\BEC\Documents\data\2014\09\30\';
name = 'efficiency_vs_analogic_voltage_AOM_300MHz_1004.txt'; % AOM Imaging
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
voltage = (3.5<=v & v<=9.99)*v + (v>9.99)*9.99; % Keeps the voltage in the range [3.5 V; 9.99 V]

% voltage = value;

end