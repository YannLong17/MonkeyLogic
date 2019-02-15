function [C,timingfile,userdefined_trialholder] = movingBarUserloop(MLConfig,TrialRecord)

%
% ----- cell string array example -----
% C = { 'fix(0,0)', 'pic(A.jpg,0,0,320,240,[0 0 0])', 'mov(B.avi,0,0)', ...
%       'crc(0.5,[1 0 0],1,-7,0)', 'sqr([0.6 0.3],[0 0 1],1,7,0)', ...
%       'snd(C.wav)', 'stm(2,D.mat,1)', 'ttl(3)', 'gen(E.m,0,0)' };
%
% ----- struct array example -----
% C(1).Type = 'fix';
% C(1).Xpos = 0;
% C(1).Ypos = 0;
%
% C(2).Type = 'pic';
% C(2).Name = 'A.jpg';
% C(2).Xpos = 0;
% C(2).Ypos = 0;
% C(2).Xsize = 320;         % in pixels, optional
% C(2).Ysize = 240;         % in pixels, optional
% C(2).Colorkey = [0 0 0];  % [R G B], optional
%
% C(3).Type = 'mov';
% C(3).Name = 'B.avi';
% C(3).Xpos = 0;
% C(3).Ypos = 0;
%
% C(4).Type = 'crc';
% C(4).Radius = 0.5;     % visual angle
% C(4).Color = [1 0 0];  % [R G B]
% C(4).FillFlag = 1;
% C(4).Xpos = -7;
% C(4).Ypos = 0;
%
% C(5).Type = 'sqr';
% C(5).Xsize = 0.6;      % visual angle
% C(5).Ysize = 0.3;      % visual angle
% C(5).Color = [0 0 1];
% C(5).FillFlag = 1;
% C(5).Xpos = 7;
% C(5).Ypos = 0;
%
% C(6).Type = 'snd';
% C(6).Name = 'C.wav';
% 
% [y,fs] = audioread('C.wav');  % Alternative way
% C(6).Type = 'snd';  % You can provide the waveform directly, but this
% C(6).WaveForm = y;  % will increase the data file size.
% C(6).Freq = fs;
%
% C(6).Type = 'snd';  % for a sine wave
% C(6).Name = 'sin';
% C(6).Duration = 1;  % in seconds
% C(6).Freq = 1000;   % Hertz
%
% C(7).Type = 'stm';
% C(7).OutputPort = 2;    % Stimulation 2
% C(7).Name = 'D.mat';
% C(7).Retriggering = 1;  % optional
%
% load('D.mat');          % 'y' and 'fs' are in D.mat
% C(7).Type = 'stm';
% C(7).OutputPort = 2;    % Stimulation 2
% C(7).WaveForm = y;
% C(7).Freq = fs;
% C(7).Retriggering = 1;  % optional
%
% C(8).Type = 'ttl';
% C(8).OutputPort = 3;    % TTL 3
%
% C(9).Type = 'gen';
% C(9).Name = 'E.m';
% C(9).Xpos = 0;          % optional
% C(9).Ypos = 0;          % optional
%


% default return value
C = [];
timingfile = 'movingBarRFTiming.m';
userdefined_trialholder = '';

% The very first call to this function is just to retrieve the timing
% filename before the task begins and we don't want to waste our preset
% values for this, so we just return if it is the first call.
persistent timing_filename_returned
if isempty(timing_filename_returned)
    timing_filename_returned = true;
    return
end

% constants
block = TrialRecord.CurrentBlock;
condition = TrialRecord.CurrentCondition;

% Set Condition and Block
% persistent condition_sequence
if isempty(TrialRecord.TrialErrors)
    block = 1;
    condition = 1;
end


% Set the Fixation Point
C(1).Type = 'fix';
C(1).Xpos = 0;
C(1).Ypos = 0;


% Set the block number and the condition number of the next trial
TrialRecord.next_block(block);
TrialRecord.next_condition(condition);
