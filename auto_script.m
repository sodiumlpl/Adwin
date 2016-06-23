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

test_adwin.chge_state_dig(1,'Reset',[],'Reset_time-DelayShutter');

test_adwin.chge_state_dig(1,'Reset',1,'DelayShutter');

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'Reset',[],'Reset_time-DelayShutter');

test_adwin.chge_state_dig(2,'Reset',1,'DelayShutter');

%%%% Digital : 4 : Zeeman Shutter %%%%

test_adwin.chge_state_dig(4,'Reset',[],'Reset_time-DelayShutter');

%%%% Digital : 5 : MOT Shutter %%%%

test_adwin.chge_state_dig(5,'Reset',[],'Reset_time-DelayShutter');

%%%% Digital : 7 : Repumper Shutter %%%%

test_adwin.chge_state_dig(7,'Reset',[],'Reset_time-DelayShutterRepump');

%%%% Digital : 9 : Transport inhib 2 %%%%

test_adwin.chge_state_dig(9,'Reset',[],'Reset_time');

%%%% Digital : 30 : Mechanical Shutter %%%%

test_adwin.chge_state_dig(30,'Reset',[],'Reset_time-DelayShutterMech');

%%%% Analog : 1 : Zeeman AOM freq [MHz] %%%%

test_adwin.chge_state_ana(1,'Reset',[],'Reset_time','AOM_Zeeman_freq','C','');

test_adwin.chge_end_state_ana(1,'Reset','AOM_Zeeman_freq');

%%%% Analog : 2 : MOT AOM freq [MHz] %%%%

test_adwin.chge_state_ana(2,'Reset',[],'Reset_time','AOM_MOT_freq','C','');

test_adwin.chge_end_state_ana(2,'Reset','AOM_MOT_freq');

%%%% Analog : 3 : Imaging AOM freq [MHz] %%%%

test_adwin.chge_state_ana(3,'Reset',[],'Reset_time','Zeeman_rep_freq','C','');

test_adwin.chge_end_state_ana(3,'Reset','Zeeman_rep_freq');

%%%% Analog : 4 : MOT AOM eff %%%%

test_adwin.chge_state_ana(4,'Reset',[],'Reset_time','AOM_MOT_eff','C','');

test_adwin.chge_end_state_ana(4,'Reset','AOM_MOT_eff');

%%%% Analog : 5 : Imaging AOM eff %%%%

test_adwin.chge_state_ana(5,'Reset',[],'Reset_time','Zeeman_rep_eff','C','');

test_adwin.chge_end_state_ana(5,'Reset','Zeeman_rep_eff');

%%%% Analog : 6 : MOT EOM freq [GHz] %%%%

test_adwin.chge_state_ana(6,'Reset',[],'Reset_time','EOM_MOT_freq','C','');

test_adwin.chge_end_state_ana(6,'Reset','EOM_MOT_freq');

%%%% Analog : 7 : Repumper AOM freq [GHz] %%%%

test_adwin.chge_state_ana(7,'Reset',[],'Reset_time','AOM_Repumper_freq','C','');

test_adwin.chge_end_state_ana(7,'Reset','AOM_Repumper_freq');

%%%% Analog : 8 : Zeeman EOM freq [GHz] %%%%

test_adwin.chge_state_ana(8,'Reset',[],'Reset_time','EOM_Zeeman_freq','C','');

test_adwin.chge_end_state_ana(8,'Reset','EOM_Zeeman_freq');

%%%% Analog : 9 : Repumper AOM amp %%%%

test_adwin.chge_state_ana(9,'Reset',[],'Reset_time','AOM_Repumper_eff','C','');

test_adwin.chge_end_state_ana(9,'Reset','AOM_Repumper_eff');

%%%% Analog : 10 : Zeeman EOM amp %%%%

test_adwin.chge_state_ana(10,'Reset',[],'Reset_time','EOM_Zeeman_amp','C','');

test_adwin.chge_end_state_ana(10,'Reset','EOM_Zeeman_amp');

%%%% Analog : 11 : Power Supply Int [A] %%%%

test_adwin.chge_state_ana(11,'Reset',[],'Reset_time','Switch_II_cur','C','');

test_adwin.chge_end_state_ana(11,'Reset','Switch_II_cur');

%%%% Analog : 12: MOT EOM amp %%%%

test_adwin.chge_state_ana(12,'Reset',[],'Reset_time','EOM_MOT_amp','C','');

test_adwin.chge_end_state_ana(12,'Reset','EOM_MOT_amp');

%%%% Analog : 16 : Zeeman AOM eff %%%%

test_adwin.chge_state_ana(16,'Reset',[],'Reset_time','AOM_Zeeman_eff','C','');

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

%%%% Digital : 4 : Zeeman Shutter %%%%

test_adwin.chge_state_dig(4,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 7 : Repumper Shutter %%%%

test_adwin.chge_state_dig(7,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 30 : Mechanical Shutter %%%%

test_adwin.chge_state_dig(30,'MOT_loading',[],'MOT_loading_time');

%%%% Analog : 1 : Zeeman AOM freq [MHz] %%%%

test_adwin.chge_state_ana(1,'MOT_loading',[],'MOT_loading_time','AOM_Zeeman_freq','C','');

test_adwin.chge_end_state_ana(1,'MOT_loading','AOM_Zeeman_freq');

%%%% Analog : 2 : MOT AOM freq [MHz] %%%%

test_adwin.chge_state_ana(2,'MOT_loading',[],'MOT_loading_time','AOM_MOT_freq','C','');

test_adwin.chge_end_state_ana(2,'MOT_loading','AOM_MOT_freq');

%%%% Analog : 3 : Imaging AOM freq [MHz] %%%%

test_adwin.chge_state_ana(3,'MOT_loading',[],'MOT_loading_time','Zeeman_rep_freq','C','');

test_adwin.chge_end_state_ana(3,'MOT_loading','Zeeman_rep_freq');

%%%% Analog : 4 : MOT AOM eff %%%%

test_adwin.chge_state_ana(4,'MOT_loading',[],'MOT_loading_time','AOM_MOT_eff','C','');

test_adwin.chge_end_state_ana(4,'MOT_loading','AOM_MOT_eff');

%%%% Analog : 5 : Imaging AOM eff %%%%

test_adwin.chge_state_ana(5,'MOT_loading',[],'MOT_loading_time','Zeeman_rep_eff','C','');

test_adwin.chge_end_state_ana(5,'MOT_loading','Zeeman_rep_eff');

%%%% Analog : 6 : MOT EOM freq [GHz] %%%%

test_adwin.chge_state_ana(6,'MOT_loading',[],'MOT_loading_time','EOM_MOT_freq','C','');

test_adwin.chge_end_state_ana(6,'MOT_loading','EOM_MOT_freq');

%%%% Analog : 7 : Repumper AOM freq [GHz] %%%%

test_adwin.chge_state_ana(7,'MOT_loading',[],'MOT_loading_time','AOM_Repumper_freq','C','');

test_adwin.chge_end_state_ana(7,'MOT_loading','AOM_Repumper_freq');

%%%% Analog : 8 : Zeeman EOM freq [GHz] %%%%

test_adwin.chge_state_ana(8,'MOT_loading',[],'MOT_loading_time','EOM_Zeeman_freq','C','');

test_adwin.chge_end_state_ana(8,'MOT_loading','EOM_Zeeman_freq');

%%%% Analog : 9 : Repumper AOM amp %%%%

test_adwin.chge_state_ana(9,'MOT_loading',[],'MOT_loading_time','AOM_Repumper_eff','C','');

test_adwin.chge_end_state_ana(9,'MOT_loading','AOM_Repumper_eff');

%%%% Analog : 10 : Zeeman EOM amp %%%%

test_adwin.chge_state_ana(10,'MOT_loading',[],'MOT_loading_time','EOM_Zeeman_amp','C','');

test_adwin.chge_end_state_ana(10,'MOT_loading','EOM_Zeeman_amp');

%%%% Analog : 11 : Power Supply Int [A] %%%%

test_adwin.chge_state_ana(11,'MOT_loading',[],'MOT_loading_time','Switch_II_cur','C','');

test_adwin.chge_end_state_ana(11,'MOT_loading','Switch_II_cur');

%%%% Analog : 12: MOT EOM amp %%%%

test_adwin.chge_state_ana(12,'MOT_loading',[],'MOT_loading_time','EOM_MOT_amp','C','');

test_adwin.chge_end_state_ana(12,'MOT_loading','EOM_MOT_amp');

%%%% Analog : 16 : Zeeman AOM eff %%%%

test_adwin.chge_state_ana(16,'MOT_loading',[],'MOT_loading_time','AOM_Zeeman_eff','C','');

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
test_adwin.block_seq_array(3).t_start = 'MOT_loading_time+Reset_time';

test_adwin.block_seq_array(3).parent_adwin = test_adwin;

%%%% Digital : 1 : AOM Zeeman %%%%

test_adwin.chge_state_dig(1,'Imaging',[],'DelayShutter');

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'Imaging',[],'Hold_time');

test_adwin.chge_state_dig(2,'Imaging',1,'DelayShutter');

%%%% Digital : 3 : AOM Imaging %%%%

test_adwin.chge_state_dig(3,'Imaging',[],'Hold_time+TOF_time-DelayShutterImaging');

test_adwin.chge_state_dig(3,'Imaging',1,'DelayShutterImaging');

test_adwin.chge_state_dig(3,'Imaging',2,'PulseLength');

test_adwin.chge_state_dig(3,'Imaging',3,'DelayShutterImaging');

test_adwin.chge_state_dig(3,'Imaging',[],'Hold_time+TOF_time+Expo_time+PixelflyAcq/2-DelayShutterImaging');

test_adwin.chge_state_dig(3,'Imaging',5,'DelayShutterImaging');

test_adwin.chge_state_dig(3,'Imaging',6,'PulseLength');

test_adwin.chge_state_dig(3,'Imaging',7,'DelayShutterImaging');

%%%% Digital : 5 : MOT Shutter %%%%

test_adwin.chge_state_dig(5,'Imaging',[],'Hold_time');

%%%% Digital : 6 : Imaging Shutter %%%%

test_adwin.chge_state_dig(6,'Imaging',[],'Hold_time+TOF_time-DelayShutterImaging');

test_adwin.chge_state_dig(6,'Imaging',1,'DelayShutterImaging+PulseLength');

test_adwin.chge_state_dig(6,'Imaging',[],'Hold_time+TOF_time+Expo_time+PixelflyAcq/2-DelayShutterImaging');

test_adwin.chge_state_dig(6,'Imaging',3,'DelayShutterImaging+PulseLength');

%%%% Digital : 9 : Transport inhib 2 %%%%

test_adwin.chge_state_dig(9,'Imaging',[],'Hold_time');

%%%% Digital : 13 : Camera Trigger %%%%

test_adwin.chge_state_dig(13,'Imaging',[],'Hold_time+TOF_time-DelayPic');

test_adwin.chge_state_dig(13,'Imaging',1,'Expo_time+PixelflyAcq');

test_adwin.chge_state_dig(13,'Imaging',2,'PixelflyAcq');

test_adwin.chge_state_dig(13,'Imaging',3,'Expo_time+PixelflyAcq');

%%%% Analog : 1 : Zeeman AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(1,'Imaging','AOM_Zeeman_freq');

%%%% Analog : 2 : MOT AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(2,'Imaging','AOM_MOT_freq');

%%%% Analog : 3 : Imaging AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(3,'Imaging','AOM_imag_freq');

%%%% Analog : 4 : MOT AOM eff %%%%

test_adwin.chge_end_state_ana(4,'Imaging','AOM_MOT_eff');

%%%% Analog : 5 : Imaging AOM eff %%%%

test_adwin.chge_end_state_ana(5,'Imaging','AOM_imag_eff');

%%%% Analog : 6 : MOT EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(6,'Imaging','EOM_MOT_freq');

%%%% Analog : 7 : Repumper AOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(7,'Imaging','AOM_Repumper_freq');

%%%% Analog : 8 : Zeeman EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(8,'Imaging','EOM_Zeeman_freq');

%%%% Analog : 9 : Repumper AOM amp %%%%

test_adwin.chge_end_state_ana(9,'Imaging','AOM_Repumper_eff');

%%%% Analog : 10 : Zeeman EOM amp %%%%

test_adwin.chge_end_state_ana(10,'Imaging','EOM_Zeeman_amp');

%%%% Analog : 11 : Power Supply Int [A] %%%%

test_adwin.chge_end_state_ana(11,'Imaging','Switch_II_cur');

%%%% Analog : 12: MOT EOM amp %%%%

test_adwin.chge_end_state_ana(12,'Imaging','EOM_MOT_amp');

%%%% Analog : 16 : Zeeman AOM eff %%%%

test_adwin.chge_end_state_ana(16,'Imaging','AOM_Zeeman_eff');

