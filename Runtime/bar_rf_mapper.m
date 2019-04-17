if ~exist('mouse_','var'), error('This demo requires the mouse input. Please enable it in the main menu or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
% showcursor(false);  % remove the joystick cursor
% TrialRecord.MarkSkippedFrames = false;  % skip skipped frame markers
bhv_code(10, 'Fixation', 20, 'Stimulus', 90, 'Reward')

dashboard(3,'Position: Left click + Drag, Orientation: [PageUp PageDown]',[0 1 0]);
dashboard(4,'Bar Width: [LEFT(-) RIGHT(+)], Bar Length: [DOWN(-) UP(+)]',[0 1 0]);
dashboard(5,'Color: Enter',[0 1 0]);
dashboard(6,'Press ''x'' to quit.',[1 0 0]);

% Parameters (for continuity)
if isfield(TrialRecord.User,'position'), position = TrialRecord.User.position; else position = [0 0]; end
if isfield(TrialRecord.User,'sizel'), sizel = TrialRecord.User.sizel; else sizel = 2; end
if isfield(TrialRecord.User,'orientation'), orientation = TrialRecord.User.orientation; else orientation = 0; end
if isfield(TrialRecord.User,'ratio'), ratio = TrialRecord.User.ratio; else ratio = pi/32; end
% if isfield(TrialRecord.User,'color'), color = TrialRecord.User.color; else color = [0 0 0]; end

% Condition Variable name
fixation_point = 1;

% editables
wait_time = 5000;
fix_rad = 2.5;
fix_dur = 60000;
grace = 500;
reward = 40;
reward_interval = 3000;
% colors = [0 0 0; 0.5 0.5 0.5];
colore = [0,0,0];
editable('reward', 'reward_interval', '-color', 'colore')


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

% Movable Bar
bar = Bar_RF_Mapper(mouse_);
bar.Position = position;
bar.Orientation = orientation;
bar.Sizel = sizel;
bar.Ratio = ratio;
bar.Colore = colore;
% bar.Color = color;

% Concurent adapter
con = Concurrent(lh);
con.add(bar);

scene2 = create_scene(con, fixation_point);

% Run task
run_scene(scene1);
if ~wth.Success
% 	idle(0);  % clear screen
    error_type = 4;  % no fixation  
else
    run_scene(scene2)
    if ~lh.Success
%         idle(0);  % clear screen
        error_type = 3;  % broke fixation
    else
        error_type = 0; % Success
    end
    
end

idle(0); % clear screen

% save parameters
trialerror(error_type);
TrialRecord.User.position = bar.Position;
TrialRecord.User.orientation = bar.Orientation;
TrialRecord.User.sizel = bar.Sizel;
TrialRecord.User.ratio = bar.Ratio;
% TrialRecord.User.color = bar.Color;


