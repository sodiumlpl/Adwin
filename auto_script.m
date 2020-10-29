%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% ADWIN Digital Sequence %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%
%%%% Block Reset %%%%
%%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array = Adwin.Block;

for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(1).dig_out_struct(i).timings_array(1).state = Adwin.Default_parameters.dig_out_init{i};

end

test_adwin.block_seq_array(1).name = 'Reset';
test_adwin.block_seq_array(1).t_start = '0';

test_adwin.block_seq_array(1).parent_adwin = test_adwin;

%%%% Digital : 1 : AOM Zeeman %%%%

test_adwin.chge_state_dig(1,'Reset',[],'Reset_time-DelayShutterZeeman');

test_adwin.chge_state_dig(1,'Reset',1,'DelayShutterZeeman');

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'Reset',[],'Reset_time-DelayShutterMOT');

test_adwin.chge_state_dig(2,'Reset',1,'DelayShutterMOT');

%%%% Digital : 3 : AOM Rep+Pol %%%%

test_adwin.chge_state_dig(3,'Reset',[],'Reset_time-DelayShutterRepPol');

test_adwin.chge_state_dig(3,'Reset',1,'DelayShutterRepPol');

%%%% Digital : 8 : AOM 1.7 GHz %%%%

test_adwin.chge_state_dig(8,'Reset',[],'Reset_time-DelayShutterRepPol');

%%%% Digital : 9 : Current Supply 2 %%%%

test_adwin.chge_state_dig(9,'Reset',[],'Reset_time');

%%%% Digital : 30 : Mechanical Shutter %%%%

test_adwin.chge_state_dig(30,'Reset',[],'Reset_time-DelayShutterMech');

%%%% Digital : 33 : Rep+Pol Shutter %%%%

test_adwin.chge_state_dig(33,'Reset',[],'Reset_time-DelayShutterRepPol');

%%%% Digital : 34 : MOT Shutter %%%%

test_adwin.chge_state_dig(34,'Reset',[],'Reset_time-DelayShutterMOT');

%%%% Digital : 36 : Zeeman Shutter %%%%

test_adwin.chge_state_dig(36,'Reset',[],'Reset_time-DelayShutterZeeman');

%%%% Analog : 1 : Zeeman AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(1,'Reset','AOM_Zeeman_freq');

%%%% Analog : 2 : MOT AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(2,'Reset','AOM_MOT_freq');

%%%% Analog : 3 : Rep+Pol AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(3,'Reset','AOM_RepPol_freq');

%%%% Analog : 4 : MOT AOM eff %%%%

test_adwin.chge_end_state_ana(4,'Reset','AOM_MOT_eff');

%%%% Analog : 5 : Rep+Pol AOM eff %%%%

test_adwin.chge_end_state_ana(5,'Reset','AOM_RepPol_eff');

%%%% Analog : 6 : MOT EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(6,'Reset','EOM_MOT_freq');

%%%% Analog : 8 : Rep+Pol EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(8,'Reset','EOM_RepPol_freq');

%%%% Analog : 10 : Rep+Pol EOM eff %%%%

test_adwin.chge_end_state_ana(10,'Reset','EOM_RepPol_eff');

%%%% Analog : 11 : Current Supply 2 [A] %%%%

test_adwin.chge_end_state_ana(11,'Reset','MOT_current');

%%%% Analog : 12 : MOT EOM eff %%%%

test_adwin.chge_end_state_ana(12,'Reset','EOM_MOT_eff');

%%%% Analog : 14 : Current Supply 2 [V] %%%%

test_adwin.chge_end_state_ana(14,'Reset','MOT_voltage');

%%%% Analog : 16 : Zeeman AOM eff %%%%

test_adwin.chge_end_state_ana(16,'Reset','AOM_Zeeman_eff');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Block MOT_loading %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array(2) = Adwin.Block;
test_adwin.block_seq_array(1).next = test_adwin.block_seq_array(2);

for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(2).dig_out_struct(i).timings_array(1).state = test_adwin.block_seq_array(1).dig_out_struct(i).timings_array(end).state;

end

test_adwin.block_seq_array(2).name = 'MOT_loading';
test_adwin.block_seq_array(2).t_start = 'Reset_time';

test_adwin.block_seq_array(2).parent_adwin = test_adwin;

%%%% Digital : 1 : AOM Zeeman %%%%

test_adwin.chge_state_dig(1,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 3 : AOM Rep+Pol %%%%

test_adwin.chge_state_dig(3,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 9 : Current Supply 2 %%%%

test_adwin.chge_state_dig(9,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 30 : Mechanical Shutter %%%%

test_adwin.chge_state_dig(30,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 33 : Rep+Pol Shutter %%%%

test_adwin.chge_state_dig(33,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 34 : MOT Shutter %%%%

test_adwin.chge_state_dig(34,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 36 : Zeeman Shutter %%%%

test_adwin.chge_state_dig(36,'MOT_loading',[],'MOT_loading_time');

%%%% Analog : 1 : Zeeman AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(1,'MOT_loading','AOM_Zeeman_freq');

%%%% Analog : 2 : MOT AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(2,'MOT_loading','AOM_MOT_freq');

%%%% Analog : 3 : Rep+Pol AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(3,'MOT_loading','AOM_RepPol_freq');

%%%% Analog : 4 : MOT AOM eff %%%%

test_adwin.chge_end_state_ana(4,'MOT_loading','AOM_MOT_eff');

%%%% Analog : 5 : Rep+Pol AOM eff %%%%

test_adwin.chge_end_state_ana(5,'MOT_loading','AOM_RepPol_eff');

%%%% Analog : 6 : MOT EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(6,'MOT_loading','EOM_MOT_freq');

%%%% Analog : 8 : Rep+Pol EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(8,'MOT_loading','EOM_RepPol_freq');

%%%% Analog : 10 : Rep+Pol EOM eff %%%%

test_adwin.chge_end_state_ana(10,'MOT_loading','EOM_RepPol_eff');

%%%% Analog : 11 : Current Supply 2 [A] %%%%

test_adwin.chge_end_state_ana(11,'MOT_loading','MOT_current');

%%%% Analog : 12 : MOT EOM eff %%%%

test_adwin.chge_end_state_ana(12,'MOT_loading','EOM_MOT_eff');

%%%% Analog : 14 : Current Supply 2 [V] %%%%

test_adwin.chge_end_state_ana(14,'MOT_loading','MOT_voltage');

%%%% Analog : 16 : Zeeman AOM eff %%%%

test_adwin.chge_end_state_ana(16,'MOT_loading','AOM_Zeeman_eff');

%%%%%%%%%%%%%%%%%%%%%%%
%%%% Block Imaging %%%%
%%%%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array(3) = Adwin.Block;
test_adwin.block_seq_array(2).next = test_adwin.block_seq_array(3);

for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(3).dig_out_struct(i).timings_array(1).state = test_adwin.block_seq_array(2).dig_out_struct(i).timings_array(end).state;

end

test_adwin.block_seq_array(3).name = 'Imaging';
test_adwin.block_seq_array(3).t_start = 'Reset_time+MOT_loading_time';

test_adwin.block_seq_array(3).parent_adwin = test_adwin;

%%%% Digital : 1 : AOM Zeeman %%%%

test_adwin.chge_state_dig(1,'Imaging',[],'DelayShutterZeeman');

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'Imaging',[],'DelayShutterMOT');

test_adwin.chge_state_dig(2,'Imaging',[],'TOF_time-DelayShutterImaging');

test_adwin.chge_state_dig(2,'Imaging',2,'DelayShutterImaging');

test_adwin.chge_state_dig(2,'Imaging',3,'Imag_pulse_time');

test_adwin.chge_state_dig(2,'Imaging',3,'ImagSourceExpoTime+ImagSourcePicsGap');

test_adwin.chge_state_dig(2,'Imaging',5,'Imag_pulse_time');

%%%% Digital : 3 : AOM Rep+Pol %%%%

test_adwin.chge_state_dig(3,'Imaging',[],'DelayShutterRepPol');

%%%% Digital : 8 : AOM 1.7 GHz %%%%

test_adwin.chge_state_dig(8,'Imaging',[],'DelayShutterRepPol');

%%%% Digital : 13 : ImagSource Trigger %%%%

test_adwin.chge_state_dig(13,'Imaging',[],'TOF_time-ImagSourceDelay');

test_adwin.chge_state_dig(13,'Imaging',1,'ImagSourceExpoTime');

test_adwin.chge_state_dig(13,'Imaging',2,'ImagSourcePicsGap');

test_adwin.chge_state_dig(13,'Imaging',3,'ImagSourceExpoTime');

test_adwin.chge_state_dig(13,'Imaging',4,'ImagSourcePicsGap');

test_adwin.chge_state_dig(13,'Imaging',5,'ImagSourceExpoTime');

test_adwin.chge_state_dig(13,'Imaging',6,'ImagSourcePicsGap');

test_adwin.chge_state_dig(13,'Imaging',7,'ImagSourceExpoTime');

%%%% Digital : 35 : Imaging Shutter %%%%

test_adwin.chge_state_dig(35,'Imaging',[],'TOF_time-DelayShutterImaging');

test_adwin.chge_state_dig(35,'Imaging',1,'DelayShutterImaging+Imag_pulse_time');

test_adwin.chge_state_dig(35,'Imaging',1,'ImagSourceExpoTime+ImagSourcePicsGap ');

test_adwin.chge_state_dig(35,'Imaging',3,'DelayShutterImaging+Imag_pulse_time');

%%%% Analog : 1 : Zeeman AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(1,'Imaging','AOM_Zeeman_freq');

%%%% Analog : 2 : MOT AOM freq [MHz] %%%%

test_adwin.chge_state_ana(2,'Imaging',[],'DelayShutterMOT','AOM_MOT_freq','C','');

test_adwin.chge_state_ana(2,'Imaging',[],'TOF_time-ImagSourceDelay+ImagSourceExpoTime+ImagSourcePicsGap+ImagSourceExpoTime','AOM_imag_freq','C','');

test_adwin.chge_end_state_ana(2,'Imaging','AOM_MOT_freq');

%%%% Analog : 3 : Rep+Pol AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(3,'Imaging','AOM_RepPol_freq');

%%%% Analog : 4 : MOT AOM eff %%%%

test_adwin.chge_state_ana(4,'Imaging',[],'DelayShutterMOT','AOM_MOT_eff','C','');

test_adwin.chge_state_ana(4,'Imaging',[],'TOF_time-ImagSourceDelay+ImagSourceExpoTime+ImagSourcePicsGap+ImagSourceExpoTime','AOM_imag_eff','C','');

test_adwin.chge_end_state_ana(4,'Imaging','AOM_MOT_eff');

%%%% Analog : 5 : Rep+Pol AOM eff %%%%

test_adwin.chge_end_state_ana(5,'Imaging','AOM_RepPol_eff');

%%%% Analog : 6 : MOT EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(6,'Imaging','EOM_MOT_freq');

%%%% Analog : 8 : Rep+Pol EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(8,'Imaging','EOM_RepPol_freq');

%%%% Analog : 10 : Rep+Pol EOM eff %%%%

test_adwin.chge_end_state_ana(10,'Imaging','EOM_RepPol_eff');

%%%% Analog : 11 : Current Supply 2 [A] %%%%

test_adwin.chge_end_state_ana(11,'Imaging','MOT_current');

%%%% Analog : 12 : MOT EOM eff %%%%

test_adwin.chge_end_state_ana(12,'Imaging','EOM_MOT_eff');

%%%% Analog : 14 : Current Supply 2 [V] %%%%

test_adwin.chge_end_state_ana(14,'Imaging','MOT_voltage');

%%%% Analog : 16 : Zeeman AOM eff %%%%

test_adwin.chge_end_state_ana(16,'Imaging','AOM_Zeeman_eff');

