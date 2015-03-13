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

delete(test_adwin);