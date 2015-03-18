%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% ADWIN Dependent Parameters %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Imag_block_duration = Hold_time+TOF_time+Expo_time+PixelflyAcq+PixelflyAcq...
    -DelayShutterImaging + DelayShutterImaging + PulseLength + DelayShutterImaging;