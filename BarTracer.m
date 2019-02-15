classdef BarTracer < BarStimulus
    properties
        % Target = Bar Object
        Trajectory             % [x y], n-by-2
        AnalysisWindow = 0     % msec
        Step = 1               % every n frames
    end
    properties (SetAccess = protected)
%         TargetLocation
        MaxFrame
%         TargetScrCoordinates
%         ScreenInfo
    end
    properties (Access = protected)
        % TargetID
        PaddedTrajectory
        % ScrPaddedTrajectory
    end
    
    methods
        function obj = BarTracer(varargin)
            obj = obj@BarStimulus(varargin{:});          
        end
        
        function set.Trajectory(obj,val)
            if 2~=size(val,2), error('Trajectory must be a n-by-2 matrix'); end
            obj.Trajectory = val;
            pad_trajectory(obj);
        end
        function set.AnalysisWindow(obj,val)
            if ~isscalar(val), error('AnalysisWindow must be a scalar'); end
            if val < 0, error('AnalysisWindow must be a positive integer'); end
            obj.AnalysisWindow = val;
            pad_trajectory(obj);
        end
        function set.Step(obj,val)
            if ~isscalar(val), error('Step must be a scalar'); end
            if val <= 0, error('Step must be a positive integer'); end
            obj.Step = val;
            pad_trajectory(obj);
        end
        
        function continue_ = analyze(obj,p)
            analyze@BarStimulus(obj,p);
            obj.Success = obj.Adapter.Success;

            frame_no = p.scene_frame();  % 0-based
            continue_ = frame_no < obj.MaxFrame;
            
            
            frame_idx = floor(frame_no/obj.Step) + 1;
            
            if continue_ 
                obj.Position = obj.PaddedTrajectory(frame_idx,:);
            
            end
            % if ~isempty(obj.TargetID), mglsetorigin(obj.TargetID,obj.TargetScrCoordinates); end
        end
    end
    
    methods (Access = protected)
        function pad_trajectory(obj)
            if isempty(obj.Trajectory), return, end
            padding = ceil(obj.AnalysisWindow / obj.Tracker.Screen.FrameLength) / obj.Step;
            if round(padding)~=padding, error('AnalysisWindow is not a multiple of the screen update interval (FrameLength * Step)'); end
            obj.PaddedTrajectory = [repmat(obj.Trajectory(1,:),padding,1); obj.Trajectory; obj.Trajectory(end,:)];
            % obj.ScrPaddedTrajectory = obj.Tracker.CalFun.deg2pix(obj.PaddedTrajectory);
            % obj.ScrPaddedTrajectory = obj.ScrPaddedTrajectory([2:end end],:);
            obj.MaxFrame = (padding + size(obj.Trajectory,1)) * obj.Step;
        end
    end
end
