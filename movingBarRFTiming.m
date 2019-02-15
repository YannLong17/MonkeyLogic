if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
showcursor(false);  % remove the joystick cursor

% Name the task object define by the userloop
fixation_point = 1;

% Define properties
fix_rad = 2;
wait_time = 5000;
fix_hold = 50;
bar_color = [0 0 0];  % RGB [0 0 0]

% editables
reward = 50;
bar_speed = 10; % 10 Dva/s  From paper
bar_width = 0.2; % 0.2 Dva From paper
n_trajectories = 8; % 4 Orientation * 2 Direction
editable('bar_speed', 'bar_width', 'n_trajectories', 'reward');

% Creating Scene
% Fixation Point
fix = SingleTarget(eye_);
fix.Target = fixation_point;
fix.Threshold = fix_rad;

% Aquire Fixation
wth = WaitThenHold(fix);
wth.WaitTime = wait_time;
wth.HoldTime = fix_hold;

scene1 = create_scene(wth, fixation_point);

% Stimulus
barRF = SuperBarTracerRF(null_);
barRF.Bar_Speed = bar_speed;
barRF.Bar_Width = bar_width;
barRF.N_Trajectories = n_trajectories;
barRF.Color = bar_color;          

% Maintain Fixation during Trial
wth2 = WaitThenHold(fix);
wth2.WaitTime = 0;
wth2.HoldTime = barRF.PathTime * 1000;

con = Concurrent(wth2);           % The Concurrent adapter behaves as if it is lh2a, in terms of stopping scenes and setting Success,
con.add(barRF);                   % and run grat2b additionally but grat2b does not affect the progression or Success of the scene.

% create scenes
scene2 = create_scene(con, fixation_point);


% Run task
run_scene(scene1);
% dashboard(3, 'Waiting For Fixation', [1 0 0])
if ~wth.Success
	idle(0);  % clear screen
    error_type = 4;  % no fixation  
    
else
    run_scene(scene2)
    
    if ~wth2.Success
        idle(0);  % clear screen
        error_type = 3;  % broke fixation
    else
        goodmonkey(reward)
        error_type = 0; % Success
    end
    
end

idle(0);

% Save Trial Param
trialerror(error_type);
TrialRecord.User.PathId = barRF.PathId;
TrialRecord.User.Trajectory = barRF.Trajectory;
TrialRecord.User.PathTime = barRF.PathTime*1000;



