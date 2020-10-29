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

%%%% Analog : 10 : Rep+Pol EOM amp %%%%

test_adwin.chge_end_state_ana(10,'Reset','EOM_RepPol_eff');

%%%% Analog : 11 : Current Supply 2 [A] %%%%

test_adwin.chge_end_state_ana(11,'Reset','Switch_II_cur');

%%%% Analog : 12 : MOT EOM amp %%%%

test_adwin.chge_end_state_ana(12,'Reset','EOM_MOT_eff');

%%%% Analog : 14 : Current Supply 2 [V] %%%%

test_adwin.chge_end_state_ana(14,'Reset','Switch_II_vol');

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

%%%% Digital : 3 : AOM Rep+Pol %%%%

test_adwin.chge_state_dig(3,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 30 : Mechanical Shutter %%%%

test_adwin.chge_state_dig(30,'MOT_loading',[],'MOT_loading_time');

%%%% Digital : 33 : Rep+Pol Shutter %%%%

test_adwin.chge_state_dig(33,'MOT_loading',[],'MOT_loading_time');

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

%%%% Analog : 10 : Rep+Pol EOM amp %%%%

test_adwin.chge_end_state_ana(10,'MOT_loading','EOM_RepPol_eff');

%%%% Analog : 11 : Current Supply 2 [A] %%%%

test_adwin.chge_end_state_ana(11,'MOT_loading','Switch_II_cur');

%%%% Analog : 12 : MOT EOM amp %%%%

test_adwin.chge_end_state_ana(12,'MOT_loading','EOM_MOT_eff');

%%%% Analog : 14 : Current Supply 2 [V] %%%%

test_adwin.chge_end_state_ana(14,'MOT_loading','Switch_II_vol');

%%%% Analog : 16 : Zeeman AOM eff %%%%

test_adwin.chge_end_state_ana(16,'MOT_loading','AOM_Zeeman_eff');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Block MOT_compress %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array(3) = Adwin.Block;
test_adwin.block_seq_array(2).next = test_adwin.block_seq_array(3);

for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(3).dig_out_struct(i).timings_array(1).state = test_adwin.block_seq_array(2).dig_out_struct(i).timings_array(end).state;

end

test_adwin.block_seq_array(3).name = 'MOT_compress';
test_adwin.block_seq_array(3).t_start = 'Reset_time+MOT_loading_time';

test_adwin.block_seq_array(3).parent_adwin = test_adwin;

%%%% Digital : 1 : AOM Zeeman %%%%

test_adwin.chge_state_dig(1,'MOT_compress',[],'DelayShutterZeeman');

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'MOT_compress',[],'MOT_compress_total_time');

%%%% Digital : 3 : AOM Rep+Pol %%%%

test_adwin.chge_state_dig(3,'MOT_compress',[],'DelayShutterRepPol');

%%%% Digital : 34 : MOT Shutter %%%%

test_adwin.chge_state_dig(34,'MOT_compress',[],'MOT_compress_total_time');

%%%% Analog : 1 : Zeeman AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(1,'MOT_compress','AOM_Zeeman_freq');

%%%% Analog : 2 : MOT AOM freq [MHz] %%%%

test_adwin.chge_state_ana(2,'MOT_compress',[],'MOT_compress_time','AOM_MOT_freq','R','');

test_adwin.chge_end_state_ana(2,'MOT_compress','AOM_MOT_end_freq');

%%%% Analog : 3 : Rep+Pol AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(3,'MOT_compress','AOM_RepPol_freq');

%%%% Analog : 4 : MOT AOM eff %%%%

test_adwin.chge_state_ana(4,'MOT_compress',[],'MOT_compress_time','AOM_MOT_eff','R','');

test_adwin.chge_state_ana(4,'MOT_compress',1,'Transfer_ramp_time','AOM_MOT_end_eff','R','');

test_adwin.chge_end_state_ana(4,'MOT_compress','AOM_MOT_transfer_end_eff');

%%%% Analog : 5 : Rep+Pol AOM eff %%%%

test_adwin.chge_end_state_ana(5,'MOT_compress','AOM_RepPol_eff');

%%%% Analog : 6 : MOT EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(6,'MOT_compress','EOM_MOT_freq');

%%%% Analog : 8 : Rep+Pol EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(8,'MOT_compress','EOM_RepPol_freq');

%%%% Analog : 10 : Rep+Pol EOM amp %%%%

test_adwin.chge_end_state_ana(10,'MOT_compress','EOM_RepPol_eff');

%%%% Analog : 11 : Current Supply 2 [A] %%%%

test_adwin.chge_state_ana(11,'MOT_compress',[],'MOT_compress_time','Switch_II_cur','R','');

test_adwin.chge_end_state_ana(11,'MOT_compress','MOT_end_current');

%%%% Analog : 12 : MOT EOM amp %%%%

test_adwin.chge_state_ana(12,'MOT_compress',[],'EOM_MOT_ramp_time','EOM_MOT_eff','R','');

test_adwin.chge_state_ana(12,'MOT_compress',[],'MOT_compress_total_time-Depump_time','EOM_MOT_end_eff','C','');

%%%% Analog : 14 : Current Supply 2 [V] %%%%

test_adwin.chge_end_state_ana(14,'MOT_compress','Switch_II_vol');

%%%% Analog : 16 : Zeeman AOM eff %%%%

test_adwin.chge_end_state_ana(16,'MOT_compress','AOM_Zeeman_eff');

%%%%%%%%%%%%%%%%%%%%%%%
%%%% Block MagTrap %%%%
%%%%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array(4) = Adwin.Block;
test_adwin.block_seq_array(3).next = test_adwin.block_seq_array(4);

for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(4).dig_out_struct(i).timings_array(1).state = test_adwin.block_seq_array(3).dig_out_struct(i).timings_array(end).state;

end

test_adwin.block_seq_array(4).name = 'MagTrap';
test_adwin.block_seq_array(4).t_start = 'Reset_time+MOT_loading_time+MOT_compress_total_time';

test_adwin.block_seq_array(4).parent_adwin = test_adwin;

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'MagTrap',[],'DelayShutterMOT');

%%%% Digital : 15 : Current Supply 1 %%%%

test_adwin.chge_state_dig(15,'MagTrap',[],'MagTrap_total_time');

%%%% Digital : 17 : Current Supply 3 %%%%

test_adwin.chge_state_dig(17,'MagTrap',[],'MagTrap_total_time');

%%%% Digital : Out 60 %%%%

test_adwin.chge_state_dig(60,'MagTrap',[],'MagTrap_ramp_time');

test_adwin.chge_state_dig(60,'MagTrap',1,'MagTrap_time');

%%%% Analog : 1 : Zeeman AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(1,'MagTrap','AOM_Zeeman_freq');

%%%% Analog : 2 : MOT AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(2,'MagTrap','AOM_MOT_end_freq');

%%%% Analog : 3 : Rep+Pol AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(3,'MagTrap','AOM_RepPol_freq');

%%%% Analog : 4 : MOT AOM eff %%%%

test_adwin.chge_end_state_ana(4,'MagTrap','AOM_MOT_eff');

%%%% Analog : 5 : Rep+Pol AOM eff %%%%

test_adwin.chge_end_state_ana(5,'MagTrap','AOM_RepPol_eff');

%%%% Analog : 6 : MOT EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(6,'MagTrap','EOM_MOT_freq');

%%%% Analog : 8 : Rep+Pol EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(8,'MagTrap','EOM_RepPol_freq');

%%%% Analog : 10 : Rep+Pol EOM amp %%%%

test_adwin.chge_end_state_ana(10,'MagTrap','EOM_RepPol_eff');

%%%% Analog : 11 : Current Supply 2 [A] %%%%

test_adwin.chge_state_ana(11,'MagTrap',[],'MagTrap_ramp_time','MOT_end_current','R','');

test_adwin.chge_end_state_ana(11,'MagTrap','MagTrap_current');

%%%% Analog : 12 : MOT EOM amp %%%%

test_adwin.chge_end_state_ana(12,'MagTrap','EOM_MOT_end_eff');

%%%% Analog : 14 : Current Supply 2 [V] %%%%

test_adwin.chge_end_state_ana(14,'MagTrap','Switch_II_vol');

%%%% Analog : 16 : Zeeman AOM eff %%%%

test_adwin.chge_end_state_ana(16,'MagTrap','AOM_Zeeman_eff');

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Block Transport %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array(5) = Adwin.Block;
test_adwin.block_seq_array(4).next = test_adwin.block_seq_array(5);

for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(5).dig_out_struct(i).timings_array(1).state = test_adwin.block_seq_array(4).dig_out_struct(i).timings_array(end).state;

end

test_adwin.block_seq_array(5).name = 'Transport';
test_adwin.block_seq_array(5).t_start = 'Reset_time+MOT_loading_time+MOT_compress_total_time+MagTrap_total_time';

test_adwin.block_seq_array(5).parent_adwin = test_adwin;

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'Transport',[],'Mag_trspt_total_time-DelayShutterMOT');

%%%% Digital : 9 : Current Supply 2 %%%%

test_adwin.chge_state_dig(9,'Transport',[],'Mag_trspt_total_time');

%%%% Digital : Out 12 %%%%

test_adwin.chge_state_dig(12,'Transport',[],'inf');

%%%% Digital : 15 : Current Supply 1 %%%%

test_adwin.chge_state_dig(15,'Transport',[],'Mag_trspt_total_time');

%%%% Digital : 17 : Current Supply 3 %%%%

test_adwin.chge_state_dig(17,'Transport',[],'Mag_trspt_total_time');

%%%% Digital : 18 : Transport clock %%%%

test_adwin.chge_state_dig(18,'Transport',[],'Mag_trspt_clock1');

test_adwin.chge_state_dig(18,'Transport',1,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'Mag_trspt_clock2');

test_adwin.chge_state_dig(18,'Transport',3,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'Mag_trspt_clock3');

test_adwin.chge_state_dig(18,'Transport',5,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'Mag_trspt_clock4');

test_adwin.chge_state_dig(18,'Transport',7,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'Mag_trspt_clock5');

test_adwin.chge_state_dig(18,'Transport',9,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'Mag_trspt_clock6');

test_adwin.chge_state_dig(18,'Transport',11,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'trspt_t1*2-Mag_trspt_clock6');

test_adwin.chge_state_dig(18,'Transport',13,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'trspt_t1*2-Mag_trspt_clock5');

test_adwin.chge_state_dig(18,'Transport',15,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'trspt_t1*2-Mag_trspt_clock4');

test_adwin.chge_state_dig(18,'Transport',17,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'trspt_t1*2-Mag_trspt_clock3');

test_adwin.chge_state_dig(18,'Transport',19,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'trspt_t1*2-Mag_trspt_clock2');

test_adwin.chge_state_dig(18,'Transport',21,'pulse_time');

test_adwin.chge_state_dig(18,'Transport',[],'trspt_t1*2-Mag_trspt_clock1');

test_adwin.chge_state_dig(18,'Transport',23,'pulse_time');

%%%% Digital : 19 : Transport direction %%%%

test_adwin.chge_state_dig(19,'Transport',[],'trspt_t1');

test_adwin.chge_state_dig(19,'Transport',1,'trspt_t1');

%%%% Digital : Out 20 %%%%

test_adwin.chge_state_dig(20,'Transport',[],'0.0001');

test_adwin.chge_state_dig(20,'Transport',[],'10');

%%%% Digital : 34 : MOT Shutter %%%%

test_adwin.chge_state_dig(34,'Transport',[],'Mag_trspt_total_time-DelayShutterMOT');

%%%% Analog : 11 : Current Supply 2 [A] %%%%

test_adwin.chge_state_ana(11,'Transport',[],'trspt_t1','MagTrap_current','S','current_supply_2');

test_adwin.chge_state_ana(11,'Transport',1,'trspt_t1','24.6548','S','current_supply_2_reverse');

test_adwin.chge_state_ana(11,'Transport',2,'trspt_t2','MagTrap_current','C','');

test_adwin.chge_end_state_ana(11,'Transport','MagTrap_current');

%%%% Analog : 13 : Current Supply 1 [A] %%%%

test_adwin.chge_state_ana(13,'Transport',[],'trspt_t1','0','S','current_supply_1');

test_adwin.chge_state_ana(13,'Transport',1,'trspt_t1','0.7485','S','current_supply_1_reverse');

test_adwin.chge_state_ana(13,'Transport',2,'trspt_t2','0','C','');

%%%% Analog : 14 : Current Supply 2 [V] %%%%

test_adwin.chge_end_state_ana(14,'Transport','Switch_II_vol');

%%%% Analog : 15 : Current Supply 3 [A] %%%%

test_adwin.chge_state_ana(15,'Transport',[],'trspt_t1','0','S','current_supply_3');

test_adwin.chge_state_ana(15,'Transport',1,'trspt_midpause','0','S','current_supply_3(1)');

test_adwin.chge_state_ana(15,'Transport',2,'trspt_t1','0','S','current_supply_3_reverse');

test_adwin.chge_state_ana(15,'Transport',3,'200','0','C','');

%%%% Analog : 17 : Current Supply 1 [V] %%%%

test_adwin.chge_end_state_ana(17,'Transport','Crtl_volt');

%%%% Analog : 18 : Current Supply 3 [V] %%%%

test_adwin.chge_end_state_ana(18,'Transport','Crtl_volt');

%%%%%%%%%%%%%%%%%%%%%%%
%%%% Block Imaging %%%%
%%%%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array(6) = Adwin.Block;
test_adwin.block_seq_array(5).next = test_adwin.block_seq_array(6);

for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(6).dig_out_struct(i).timings_array(1).state = test_adwin.block_seq_array(5).dig_out_struct(i).timings_array(end).state;

end

test_adwin.block_seq_array(6).name = 'Imaging';
test_adwin.block_seq_array(6).t_start = 'Reset_time+MOT_loading_time+MOT_compress_total_time+MagTrap_total_time+Mag_trspt_total_time';

test_adwin.block_seq_array(6).parent_adwin = test_adwin;

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'Imaging',[],'Repump_pulse_delay');

test_adwin.chge_state_dig(2,'Imaging',1,'Repump_pulse_time');

test_adwin.chge_state_dig(2,'Imaging',[],'TOF_time');

test_adwin.chge_state_dig(2,'Imaging',3,'PulseLength');

test_adwin.chge_state_dig(2,'Imaging',4,'DelayShutterImaging');

test_adwin.chge_state_dig(2,'Imaging',[],'TOF_time+Expo_time+PixelflyAcq/2-DelayShutterImaging');

test_adwin.chge_state_dig(2,'Imaging',6,'DelayShutterImaging');

test_adwin.chge_state_dig(2,'Imaging',7,'PulseLength');

test_adwin.chge_state_dig(2,'Imaging',8,'DelayShutterImaging');

%%%% Digital : 13 : Camera Trigger %%%%

test_adwin.chge_state_dig(13,'Imaging',[],'TOF_time-DelayPic');

test_adwin.chge_state_dig(13,'Imaging',1,'Expo_time+PixelflyAcq');

test_adwin.chge_state_dig(13,'Imaging',2,'PixelflyAcq');

test_adwin.chge_state_dig(13,'Imaging',3,'Expo_time+PixelflyAcq');

%%%% Digital : 34 : MOT Shutter %%%%

test_adwin.chge_state_dig(34,'Imaging',[],'Repump_pulse_delay+Repump_pulse_time');

%%%% Digital : 35 : Imaging Shutter %%%%

test_adwin.chge_state_dig(35,'Imaging',[],'TOF_time-DelayShutterImaging');

test_adwin.chge_state_dig(35,'Imaging',1,'DelayShutterImaging+PulseLength');

test_adwin.chge_state_dig(35,'Imaging',[],'TOF_time+Expo_time+PixelflyAcq/2-DelayShutterImaging');

test_adwin.chge_state_dig(35,'Imaging',3,'DelayShutterImaging+PulseLength');

%%%% Analog : 1 : Zeeman AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(1,'Imaging','AOM_Zeeman_freq');

%%%% Analog : 2 : MOT AOM freq [MHz] %%%%

test_adwin.chge_state_ana(2,'Imaging',[],'Repump_pulse_delay','Repump_pulse_freq','C','');

test_adwin.chge_state_ana(2,'Imaging',1,'Repump_pulse_time','Repump_pulse_freq','C','');

test_adwin.chge_state_ana(2,'Imaging',[],'TOF_time+Expo_time+PixelflyAcq/2+DelayShutterMOT','AOM_imag_freq','C','');

test_adwin.chge_end_state_ana(2,'Imaging','AOM_MOT_freq');

%%%% Analog : 3 : Rep+Pol AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(3,'Imaging','AOM_RepPol_freq');

%%%% Analog : 4 : MOT AOM eff %%%%

test_adwin.chge_state_ana(4,'Imaging',[],'Repump_pulse_delay','Repump_pulse_eff','C','');

test_adwin.chge_state_ana(4,'Imaging',1,'Repump_pulse_time','Repump_pulse_eff','C','');

test_adwin.chge_state_ana(4,'Imaging',[],'TOF_time','AOM_MOT_eff','C','');

test_adwin.chge_state_ana(4,'Imaging',3,'PulseLength','AOM_imag_eff','C','');

test_adwin.chge_state_ana(4,'Imaging',[],'TOF_time+Expo_time+PixelflyAcq/2','AOM_MOT_eff','C','');

test_adwin.chge_state_ana(4,'Imaging',5,'PulseLength','AOM_imag_eff','C','');

test_adwin.chge_end_state_ana(4,'Imaging','AOM_MOT_eff');

%%%% Analog : 5 : Rep+Pol AOM eff %%%%

test_adwin.chge_end_state_ana(5,'Imaging','AOM_RepPol_eff');

%%%% Analog : 6 : MOT EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(6,'Imaging','EOM_MOT_freq');

%%%% Analog : 8 : Rep+Pol EOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(8,'Imaging','EOM_RepPol_freq');

%%%% Analog : 10 : Rep+Pol EOM amp %%%%

test_adwin.chge_end_state_ana(10,'Imaging','EOM_RepPol_eff');

%%%% Analog : 12 : MOT EOM amp %%%%

test_adwin.chge_state_ana(12,'Imaging',[],'Repump_pulse_delay','Repump_pulse_EOM_eff','C','');

test_adwin.chge_state_ana(12,'Imaging',1,'Repump_pulse_time','Repump_pulse_EOM_eff','C','');

test_adwin.chge_end_state_ana(12,'Imaging','EOM_MOT_eff');

%%%% Analog : 16 : Zeeman AOM eff %%%%

test_adwin.chge_end_state_ana(16,'Imaging','AOM_Zeeman_eff');

