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
sample_time = 2500;
% analysis_window = 1; %ms

% editables
% Bar_speed = 0.1;
% n_trajectories = 1;
% editable('Bar_speed', 'n_trajectories');

n_t = 350;
x = linspace(-20, 20, n_t)';
y = linspace(0, 0, n_t)';

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
wth2 = WaitThenHold(fix);
wth2.WaitTime = 0;
wth2.HoldTime = sample_time;


bar = BarTracer(null_);

screeninfo = bar.ScreenInfo;
screeninfo


% % Trajectory
bar.Trajectory = [x y];
bar.Step = 1;  % target position update interval, in # of frames
% bar.AnalysisWindow = analysis_window;

bar.Position    = [0 0];            % [x y] in DVA
bar.Sizel        = 2;               % Length of long size, in DVA 
bar.Ratio       = pi/32;            % Thickness ratio, angle from 0 to pi/4
bar.Orientation = 0;                % Bar Orientation, angle from 0 to pi
bar.Color       = [1 1 1];          % RGB [0 0 0]

con = Concurrent(wth2);            % The Concurrent adapter behaves as if it is lh2a, in terms of stopping scenes and setting Success,
con.add(bar);                   % and run grat2b additionally but grat2b does not affect the progression or Success of the scene.

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
    % dashboard(3, 'Its running!', [0 1 0])
    if ~wth.Success
        idle(0);  % clear screen
        error_type = 3;  % broke fixation
    else
        error_type = 0; % Success
    end
    
end

idle(0);



