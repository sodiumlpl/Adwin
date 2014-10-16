%% Clear Matlab

clear classes
close all
clc

%% create Adwin class
 
test_adwin = Adwin.Adwin;

%% start GUI

test_adwin.adwin_main_gui;

%% load scripts

auto_parameters_script;

auto_script;

%% clear

close all

for i=1:length(test_adwin.block_seq_array)
    
    for j=1:Adwin.Default_parameters.dig_out_nbr
        
        for k=1:length(test_adwin.block_seq_array(i).dig_out_struct(j).timings_array)
            
            delete(test_adwin.block_seq_array(i).dig_out_struct(j).timings_array(k));
            
        end
        
    end
    
    delete(test_adwin.block_seq_array(i));
    
end

delete(test_adwin.adw_timer);

delete(test_adwin.pgb_timer);

delete(test_adwin);