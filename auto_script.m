%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% ADWIN Digital Sequence %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
%%%% Block test %%%%
%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array = Adwin.Block;

for i = 1:Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(1).dig_out_struct(i).timings_array(1).state = Adwin.Default_parameters.dig_out_init{i};

end

test_adwin.block_seq_array(1).name = 'test';
test_adwin.block_seq_array(1).t_start = '0';

test_adwin.block_seq_array(1).parent_adwin = test_adwin;

%%%% Digital : 1 : AOM Zeeman %%%%

test_adwin.chge_state_dig(1,'test',[],'t0-DelayShutter');

test_adwin.chge_state_dig(1,'test',1,'DelayShutter');

test_adwin.chge_state_dig(1,'test',2,'PulseZeeman');

test_adwin.chge_state_dig(1,'test',3,'DelayShutter');

test_adwin.chge_state_dig(1,'test',4,'ZeemanOff-2*DelayShutter');

test_adwin.chge_state_dig(1,'test',5,'DelayShutter');

test_adwin.chge_state_dig(1,'test',6,'PulseZeeman');

test_adwin.chge_state_dig(1,'test',7,'DelayShutter');

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'test',[],'t0+Delay-DelayShutter');

test_adwin.chge_state_dig(2,'test',1,'DelayShutter');

test_adwin.chge_state_dig(2,'test',2,'PulseLength');

test_adwin.chge_state_dig(2,'test',3,'DelayShutter');

test_adwin.chge_state_dig(2,'test',4,'t0+PulseZeeman+ZeemanOff+Delay-DelayShutter-DelayShutter-PulseLength-DelayShutter-(t0+Delay-DelayShutter)');

test_adwin.chge_state_dig(2,'test',5,'DelayShutter');

test_adwin.chge_state_dig(2,'test',6,'PulseLength');

test_adwin.chge_state_dig(2,'test',7,'DelayShutter');

%%%% Digital : 3 : AOM Imaging %%%%

test_adwin.chge_state_dig(3,'test',[],'t0');

test_adwin.chge_state_dig(3,'test',1,'ImagBlockDur');

%%%% Digital : 4 : Zeeman Shutter %%%%

test_adwin.chge_state_dig(4,'test',[],'t0-DelayShutter');

test_adwin.chge_state_dig(4,'test',1,'DelayShutter+PulseZeeman');

test_adwin.chge_state_dig(4,'test',2,'ZeemanOff-DelayShutter');

test_adwin.chge_state_dig(4,'test',3,'DelayShutter+PulseZeeman');

%%%% Digital : 5 : MOT Shutter %%%%

test_adwin.chge_state_dig(5,'test',[],'t0+Delay-DelayShutter');

test_adwin.chge_state_dig(5,'test',1,'DelayShutter+PulseLength');

test_adwin.chge_state_dig(5,'test',2,'t0+PulseZeeman+ZeemanOff+Delay-DelayShutter-(DelayShutter+PulseLength)-(t0+Delay-DelayShutter)');

test_adwin.chge_state_dig(5,'test',3,'DelayShutter+PulseLength');

%%%% Digital : 13 : Camera Trigger %%%%

test_adwin.chge_state_dig(13,'test',[],'t0+Delay+PulseLength+(PulseSpacing/2)-PixelflyAcq');

test_adwin.chge_state_dig(13,'test',1,'2.1*PixelflyAcq');

test_adwin.chge_state_dig(13,'test',2,'t0+PulseZeeman+ZeemanOff+Delay+PulseLength+(PulseSpacing/2)-PixelflyAcq-2.1*PixelflyAcq-(t0+Delay+PulseLength+(PulseSpacing/2)-PixelflyAcq)');

test_adwin.chge_state_dig(13,'test',3,'2.1*PixelflyAcq');

