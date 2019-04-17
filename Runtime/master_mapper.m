if ~exist('mouse_','var'), error('This demo requires the mouse input. Please enable it in the main menu or try the simulation mode.'); end
hotkey('p', 'escape_screen(); assignin(''caller'',''continue_'',false);');
% showcursor(false);  % remove the joystick cursor
% TrialRecord.MarkSkippedFrames = false;  % skip skipped frame markers
bhv_code(10, 'Fixation', 20, 'Stimulus', 90, 'Reward')

% Condition Variable name
fixation_point = 1;

% editables
% Timing
wait_time = 5000;
fix_rad = 2.5;
fix_dur = 60000;
grace = 500;
reward = 40;
reward_interval = 3000;

%Stimulus
color = [0 0 0];
stimulus = 1; % 1: Bar, 2: Grating, 3: RDM Dots

% Grating Property
SpatialFrequencyStep = 0.1;
TemporalFrequencyStep = 0.1;

%Rdm dots
coherence = 100;
numDot = 100;
dotSize = 0.15;

editable('reward', 'reward_interval','-color','color', 'stimulus', 'SpatialFrequencyStep','TemporalFrequencyStep', 'coherence','numDot','dotSize')

% Parameter (for continuity)
switch stimulus
    case 1
        if isfield(TrialRecord.User,'position'), position = TrialRecord.User.position; else position = [0 0]; end
        if isfield(TrialRecord.User,'sizel'), sizel = TrialRecord.User.sizel; else sizel = 2; end
        if isfield(TrialRecord.User,'orientation'), orientation = TrialRecord.User.orientation; else orientation = 0; end
        if isfield(TrialRecord.User,'ratio'), ratio = TrialRecord.User.ratio; else ratio = pi/32; end
        
        dashboard(3,'Bar Stimulus  Position: Left click + Drag, Orientation: [PageUp PageDown]',[0 1 0]);
        dashboard(4,'Bar Width: [LEFT(-) RIGHT(+)], Bar Length: [DOWN(-) UP(+)]',[0 1 0]);
        dashboard(5,'Turn on/off, press ''Enter'', To Pause, press ''p''',[0 1 0]);
        
    case 2
        dashboard(3,'Move: Left click + Drag, Resize: Right click + Drag, Direction [PageUp PageDown]',[0 1 0]);
        dashboard(4,'Spatial Frequency: [LEFT(-) RIGHT(+)], Temporal Frequency: [DOWN(-) UP(+)]',[0 1 0]);
        dashboard(5,'Press ''p'' to quit.',[1 0 0]);

        % Parameters (for continuity)
        if isfield(TrialRecord.User,'position'), position = TrialRecord.User.position; else position = [0 0]; end
        if isfield(TrialRecord.User,'radius'), radius = TrialRecord.User.radius; else radius = 2; end
        if isfield(TrialRecord.User,'direction'), direction = TrialRecord.User.direction; else direction = 0; end
        if isfield(TrialRecord.User,'spatial_frequency'), spatial_frequency = TrialRecord.User.spatial_frequency; else  spatial_frequency= 0; end
        if isfield(TrialRecord.User,'temporal_frequency'), temporal_frequency = TrialRecord.User.temporal_frequency; else temporal_frequency = 0; end
    
    case 3
        dashboard(3,'Move: Left click + Drag, Resize: Right click + Drag',[0 1 0]);
        dashboard(4,'Speed: [left (-) right (+)], Direction [PageUp PageDown]',[0 1 0]);
        dashboard(5,'Press ''p'' to quit.',[1 0 0]);

        % Parameters (for continuity)
        if isfield(TrialRecord.User,'position'), position = TrialRecord.User.position; else, position = [0 0]; end
        if isfield(TrialRecord.User,'radius'), radius = TrialRecord.User.radius; else, radius = 2; end
        if isfield(TrialRecord.User,'direction'), direction = TrialRecord.User.direction; else, direction = 0; end
        if isfield(TrialRecord.User,'speed'), speed = TrialRecord.User.speed; else, speed = 5; end

        
    otherwise
        dashboard(1, 'The Stimulus Variable must be 1: Bar Stimulus, 2: Grating, 3: RDM Dots', [0 0 1]);
        idle(60000, [1 0 0])
end


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

% Stimulus 
switch stimulus
    case 1
        % Movable Bar
        stim = Bar_RF_Mapper(mouse_);
        stim.Position = position;
        stim.Orientation = orientation;
        stim.Sizel = sizel;
        stim.Ratio = ratio;
        stim.Colore = color;

    case 2
        stim = Grating_RF_MapperC(mouse_);
        stim.SpatialFrequencyStep = SpatialFrequencyStep;
        stim.TemporalFrequencyStep = TemporalFrequencyStep;
        stim.Position = position;
        stim.Radius = radius;
        stim.Direction = direction;
        stim.SpatialFrequency = spatial_frequency;
        stim.TemporalFrequency = temporal_frequency;
        stim.Color = color;
        
    case 3
        stim = RDM_RF_MapperC(mouse_);
        stim.Position = position;
        stim.Radius = radius;
        stim.Direction = direction;
        stim.Speed = speed;
        stim.Coherence = coherence;
        stim.NumDot = numDot;
        stim.DotSize = dotSize;
        stim.DotColor = color;

end

% Concurent adapter
con = Concurrent(lh);
con.add(stim);

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
trialerror(error_type);

% Save Parameters
switch stimulus
    case 1
        TrialRecord.User.position = stim.Position;
        TrialRecord.User.orientation = stim.Orientation;
        TrialRecord.User.sizel = stim.Sizel;
        TrialRecord.User.ratio = stim.Ratio;
    
    case 2
        TrialRecord.User.position = stim.Position;
        TrialRecord.User.radius = stim.Radius;
        TrialRecord.User.direction = stim.Direction;
        TrialRecord.User.spatial_frequency = stim.SpatialFrequency;
        TrialRecord.User.temporal_frequency = stim.TemporalFrequency;
        
    case 3
        TrialRecord.User.position = stim.Position;
        TrialRecord.User.radius = stim.Radius;
        TrialRecord.User.direction = stim.Direction;
        TrialRecord.User.speed = stim.Speed;
     
end

