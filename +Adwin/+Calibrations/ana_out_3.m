function voltage = ana_out_3(value)
    %-----Location of the data files-----%
    path = 'C:\Users\BEC\Documents\data\2014\07\09\';
    name = 'freq_vs_analogic_voltage_AOM_300MHz_1004.txt'; % AOM Imaging
    filename = strcat(path,name);

    %-----Importation of the data-----%
    datafile = importdata(filename);
    data     = datafile.data;
    headers  = datafile.textdata;
    
    %-----Spline interpolation-----%
    minVal  = min(data(:,2));
    maxVal  = max(data(:,2));
    value   = (value<minVal)*minVal + (minVal<=value & value<=maxVal)*value + (value>maxVal)*maxVal;
    pp      = spline(data(:,2),data(:,1));
    v       = ppval(pp,value);
    voltage = (0<=v & v<=10)*v + (v>10)*10; % Keeps the voltage in the range [0 V; 10 V]
end