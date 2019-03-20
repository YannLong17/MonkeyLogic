if ~exist('mouse_','var'), error('This demo requires the mouse input. Please enable it in the main menu or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
showcursor(false);  % remove the joystick cursor
TrialRecord.MarkSkippedFrames = false;  % skip skipped frame markers
bhv_code(10, 'Fixation', 20, 'Stimulus', 90, 'Reward')

dashboard(3,'Move: Left click + Drag, Resize: Right click + Drag, Direction [PageUp PageDown]',[0 1 0]);
dashboard(4,'Spatial Frequency: [LEFT(-) RIGHT(+)], Temporal Frequency: [DOWN(-) UP(+)]',[0 1 0]);
dashboard(5,'Press ''x'' to quit.',[1 0 0]);

% Parameters (for continuity)
if isfield(TrialRecord.User,'position'), position = TrialRecord.User.position; else position = [0 0]; end
if isfield(TrialRecord.User,'radius'), radius = TrialRecord.User.radius; else radius = 2; end
if isfield(TrialRecord.User,'direction'), direction = TrialRecord.User.direction; else direction = 0; end
if isfield(TrialRecord.User,'spatial_frequency'), spatial_frequency = TrialRecord.User.spatial_frequency; else  spatial_frequency= 0; end
if isfield(TrialRecord.User,'temporal_frequency'), temporal_frequency = TrialRecord.User.temporal_frequency; else temporal_frequency = 0; end

% Condition Variable name
fixation_point = 1;

% editables
% Grating Property
SpatialFrequencyStep = 0.1;
TemporalFrequencyStep = 0.1;
% Fixation and Reward
wait_time = 5000;
fix_rad = 2.5;
fix_dur = 60000;
grace = 500;
reward = 40;
reward_interval = 3000;

editable('reward', 'reward_interval', 'SpatialFrequencyStep','TemporalFrequencyStep');

% Fixation
% Fixation Point
fix = SingleTarget(eye_);
fix.Target = fixation_point;
fix.Threshold = fix_rad;

% Aquire Fixation
wth = WaitThenHold(fix);
wth.WaitTime = wait_time;
wth.HoldTime = 0;

scene1 = create_scene(wth, fixation_point);

% Reward Schedule
rwd = LBC_RewardScheduler(fix);
reward_min_fix = reward_interval;
reward_interval_min = reward_interval;
reward_interval_max = reward_interval;
rwd.Schedule = [reward_min_fix, reward_interval_min, reward_interval_max, reward, 90];  %[min fix, min interval, max interval, pulse duration, eventMarker] 

% Hold fixation with grace period
lh = LooseHold(rwd);
lh.HoldTime = fix_dur;
lh.BreakTime = grace;

% Grating
grat1 = Grating_RF_MapperC(mouse_);
grat1.SpatialFrequencyStep = SpatialFrequencyStep;
grat1.TemporalFrequencyStep = TemporalFrequencyStep;
grat1.Position = position;
grat1.Radius = radius;
grat1.Direction = direction;
grat1.SpatialFrequency = spatial_frequency;
grat1.TemporalFrequency = temporal_frequency;

% Concurent adapter
con = Concurrent(lh);
con.add(grat1);

scene2 = create_scene(con, fixation_point);

% Run task
run_scene(scene1);
if ~wth.Success
    error_type = 4;  % no fixation  
else
    run_scene(scene2)
    if ~lh.Success
        error_type = 3;  % broke fixation
    else
        error_type = 0; % Success
    end
    
end

idle(0); % clear screen

% save parameters
trialerror(error_type);
TrialRecord.User.position = grat1.Position;
TrialRecord.User.radius = grat1.Radius;
TrialRecord.User.direction = grat1.Direction;
TrialRecord.User.spatial_frequency = grat1.SpatialFrequency;
TrialRecord.User.temporal_frequency = grat1.TemporalFrequency;
