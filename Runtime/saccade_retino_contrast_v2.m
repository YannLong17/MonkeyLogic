% Retinotopic Saccade Experiment Timing Script (runtime V2)
% Name the Condition Object
fix_target1 = 1;
fix_target2 = 2;

% Time Interval (ms)
fix_wait = 5000;
fix_time = 500;
mask_time = 250;
sim_latency = 200;
mu = 480 - 250 - 50;    % Mean Saccade Latency
sigma = 25;             % Std Variation of saccade latency
grace = 20;             % Loose hold threshold

stim_time = 50;
saccade_time = 40;
sacc_wait = 5000;

% Task Properties
fix_radius = 1.5;
reward = 50;

% Contrast Values
mask_contrast = 1;
stim_contrast = [0, 0.05, 0.1, 0.2, 0.35, 0.5, 0.75, 1];

% Stimulus Property
rf_x = 5;
rf_y = -3;
stim_size = 2;
orientation = 0;
color = [0, 0, 0];
stimulus = 1; % 1= bar, 2= grating
color2 = [1, 1, 1];
TemporalFrequency = 0;
SpatialFrequency = 1;

% Saccade Vector
sacc_x = 15;
sacc_y = 0;

% Editable
editable('reward', 'fix_radius', 'rf_x', 'rf_y', 'stim_size', 'orientation', 'sacc_x', 'sacc_y', '-color', 'color', '-color', 'color2', 'stimulus', 'TemporalFrequency', 'SpatialFrequency')

% Save parameters to TrialRecord (does Nothing)
TrialRecord.User.sacc = [sacc_x, sacc_y];
TrialRecord.User.orientation = orientation;
TrialRecord.User.rf_x = rf_x;
TrialRecord.User.rf_y = rf_y;
% Randomly Choose a contrast
TrialRecord.User.contrast = stim_contrast(randi(length(stim_contrast)));
% Mask on/off
TrialRecord.User.mask = binornd(1, 0.5);
TrialRecord.User.Stimulus = stimulus;

%%  Create The Stimulus Objects

% First Fixation
fix1 = SingleTarget(eye_);
fix1.Threshold = fix_radius;
fix1.Target = fix_target1;

% Second Fixation
fix2 = SingleTarget(eye_);
fix2.Threshold = fix_radius;
fix2.Target = fix_target2;

switch stimulus
    case 1 % Bar Stimulus
        % Mask
        mask = BarStimulus(null_);
        mask.Sizel = stim_size;     
        mask.Ratio = 1/4;          
        mask.Orientation = orientation;
        mask.Color = color;
        mask.Contrast = TrialRecord.User.mask;

        % Target Stimulus
        target = BarStimulus(null_);
        target.Sizel = stim_size;     
        target.Ratio = 1/4;          
        target.Orientation = orientation;
        target.Position = [rf_x, rf_y];
        target.Color = color;
        target.Contrast = TrialRecord.User.contrast;
        
        
    case 2 % Grating Stimulus
        mask = SineGratingC(null_);
        mask.Radius = stim_size;                  % aperture radius in degrees
        mask.Direction = orientation;         % degrees
        mask.SpatialFrequency = SpatialFrequency;   % cycles per deg
        mask.TemporalFrequency = TemporalFrequency;  % cycles per sec
        mask.Color1 = color;                  % RGB [0 0 0]
        mask.Color2 = color2;                 % RGB
        mask.Contrast = TrialRecord.User.mask;


        target = SineGratingC(null_);
        target.Radius = stim_size;                  % aperture radius in degrees
        target.Direction = orientation;         % degrees
        target.SpatialFrequency = SpatialFrequency;   % cycles per deg
        target.TemporalFrequency = TemporalFrequency;  % cycles per sec
        target.Color1 = color;                  % RGB [0 0 0]
        target.Color2 = color2;                 % RGB
        target.Position = [rf_x, rf_y];
        target.Contrast = TrialRecord.User.contrast;
end
%% Condition Specific Object and Scenes

switch TrialRecord.CurrentCondition
    case 1 % Actual Saccade
        % Object Properties
        mask.Position = [rf_x+sacc_x, rf_y+sacc_y];
         
        % Saccade Acquisition
        sacc_detect = SingleTarget(eye_);
        sacc_detect.Threshold = fix_radius;
        sacc_detect.Target = 2*[sacc_x, sacc_y]/3;
        sacc_detect_wait = WaitThenHold(sacc_detect);
        sacc_detect_wait.WaitTime = sacc_wait;
        sacc_detect_wait.HoldTime = 0;
        
        % Scene 4: Saccade Target Presentation and Saccade Aqcuisition
        saccade_latency = Concurrent(sacc_detect_wait);
        % saccade_latency.add(fix2);
        saccade_latency.add(mask);
        scene4_sacc_lat = create_scene(saccade_latency, fix_target2);
 
        % Scene 5: Acquire second fixation 
        aquire2 = WaitThenHold(fix2);
        aquire2.WaitTime = sacc_wait;
        aquire2.HoldTime = 0;
        scene5_fix2 = create_scene(aquire2, fix_target2);
            

    case 2 % Simulated Saccade
        mask.Position = [rf_x, rf_y];

        % Scene 4: Simulated Saccade Latency
        sim_latency = normrnd(mu,sigma);
        hold3 = LooseHold(fix1);
        hold3.BreakTime = grace;
        hold3.HoldTime = sim_latency;
        saccade_latency = Concurrent(hold3);
        saccade_latency.add(mask);        
        scene4_sacc_lat = create_scene(saccade_latency, fix_target1);
        
        % Scene 5: Acquire second fixation 
        aquire2 = WaitThenHold(fix2);
        aquire2.WaitTime = grace;
        aquire2.HoldTime = saccade_time;    % Simulate the saccade duration
        scene5_fix2 = create_scene(aquire2, fix_target2);
                   
end

%% Scenes

% Scene 1: Wait for fixation
aquire1 = WaitThenHold(fix1);
aquire1.WaitTime = fix_wait;
aquire1.HoldTime = 0;
scene1_fix1 = create_scene(aquire1, fix_target1);

% Scene 2: Hold Fixation
hold1 = LooseHold(fix1);
hold1.HoldTime = fix_time-mask_time;
hold1.BreakTime = grace;
scene2_fix1hold = create_scene(hold1, fix_target1);

% Scene 3: Mask Presentation
hold2 = LooseHold(fix1);
hold2.HoldTime = mask_time;
hold1.BreakTime = grace;
hold_mask = Concurrent(hold2);
hold_mask.add(mask);        
scene3_mask = create_scene(hold_mask, fix_target1);

% Scene 6: Target Stimulus Presentation
hold4 = WaitThenHold(fix2);
hold4.HoldTime = stim_time;
hold4.WaitTime = 0;
hold_stim = Concurrent(hold4);
hold_stim.add(target);
scene6_target = create_scene(hold_stim, fix_target2);

% Scene 7: Target Off, maintain fixation
hold5 = LooseHold(fix2);
hold5.HoldTime = fix_time - stim_time;
hold5.BreakTime = grace;
scene7_fix2 = create_scene(hold5, fix_target2);


%% Running the scenes

run_scene(scene1_fix1, 21); % Initial Fixation

if ~aquire1.Success
    error_type = 4;  % no fixation  
else
    run_scene(scene2_fix1hold);% Hold Fixation
    if ~hold1.Success
        error_type = 3;  % broke fixation
    else
        
        run_scene(scene3_mask, 41);% Mask Presentation
        if ~hold_mask.Success
            error_type = 3;  % broke fixation
        
        else
            run_scene(scene4_sacc_lat, 22); % Saccade Target Presentation 
            
            if ~ saccade_latency.Success
                error_type = TrialRecord.CurrentCondition + 1;  % Late Response or break Fixation                     
            else
                run_scene(scene5_fix2, 45); % Mask Turned Off 
                
                if ~aquire2.Success
                     error_type = TrialRecord.CurrentCondition + 1;  % Late Response or break Fixation                       
                else
                
                    run_scene(scene6_target, 31); % Target On 
                    dashboard(1, sprintf('Condition %i, Stimulus Contrast: %f', TrialRecord.CurrentCondition, TrialRecord.User.contrast), [1 1 1]);

                    if ~hold_stim.Success
                        error_type = 3;  % Broke Fixation                       
                    else
                        
                        run_scene(scene7_fix2, 35); % Target off 
                
                        if ~hold5.Success
                            error_type = 3;  % Broke Fixation                       
                        else    
               
                            goodmonkey(reward);% Correct
                            eventmarker(100);
                            error_type = 0; % Success
                        end
                    end
                end
            end
        end
    end
end

    % Record Saccade Latency and Duration
if TrialRecord.CurrentCondition == 1
    TrialRecord.User.saccade_latency = sacc_detect_wait.AcquiredTime; % Saccade Latency, need to save to a user variable
    TrialRecord.User.saccade_duration = aquire2.AcquiredTime; % 2/3 Saccade Time
    bhv_variable('saccade_latency', TrialRecord.User.saccade_latency);
    bhv_variable('saccade_duration', TrialRecord.User.saccade_duration);
end

% Save bhv variables to BHV2 File
bhv_variable('mask', TrialRecord.User.mask);
bhv_variable('contrast', TrialRecord.User.contrast);

idle(0); % clear screen
trialerror(error_type);

