if ~exist('eye_','var'), error('This demo requires eye signal input. Please set it up or try the simulation mode.'); end
showcursor(false);  % remove the joystick cursor

% Name the task object define by the userloop
fixation_point = 1;

% Define properties
fix_rad = 2;
wait_time = 5000;
fix_hold = 150;
% fix_dur = 1500;
% grace = 250;
% sample_time = 2500;
% analysis_window = 1; %ms

% editables
bar_speed = 20;
bar_width = 0.5;
n_trajectories = 5;
editable('bar_speed', 'bar_width', 'n_trajectories');

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
barRF.Color = [0 0 0];          % RGB [0 0 0]

% Maintain Fixation during Trial
wth2 = WaitThenHold(fix);
wth2.WaitTime = 0;
wth2.HoldTime = barRF.PathTime * 1000;

con = Concurrent(wth2);            % The Concurrent adapter behaves as if it is lh2a, in terms of stopping scenes and setting Success,
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
    dashboard(1, sprintf('Current Path: %i',barRF.PathId), [0 1 1])
    run_scene(scene2)
    
    if ~wth.Success
        idle(0);  % clear screen
        error_type = 3;  % broke fixation
    else
        error_type = 0; % Success
    end
    
end

idle(0);



