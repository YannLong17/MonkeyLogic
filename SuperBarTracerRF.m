classdef SuperBarTracerRF < BarTracer
   properties
       % Inputs
      N_Orientations
      Bar_Speed
       
   end
   
   properties (SetAccess = protected)
       % Output
       Trajectories
   end 
    
   properties (Access = protected)
       % Internal Variable
   end

 methods
       function obj = SuperBarTracerRF(varargin)
       obj = obj@BarTracer(varargin{:});
       end
       
       function set.N_Orientations(obj,val)
            if ~isscalar(val), error('N_Orientations must be a scalar'); end
            if val < 0, error('N_Orientations must be a positive integer'); end
            obj.N_Orientations = val;
            create_trajectories(obj);
       end
        
      function set.Bar_Speed(obj,val)
            if ~isscalar(val), error('Bar_Speed must be a scalar'); end
            if val < 0, error('Bar_Speed must be positive'); end
            obj.Bar_Speed = val;
            create_trajectories(obj);
        end
 
 function continue_ = analyze(obj,p)
            continue_ = analyze@BarStimulus(obj,p);
            obj.Success = obj.Adapter.Success;


        end
 
 end   
     methods (Access = protected)
        function create_trajectories(obj)
%             if isempty(obj.Trajectory), return, end
%             padding = ceil(obj.AnalysisWindow / obj.Tracker.Screen.FrameLength) / obj.Step;
%             if round(padding)~=padding, error('AnalysisWindow is not a multiple of the screen update interval (FrameLength * Step)'); end
%             obj.PaddedTrajectory = [repmat(obj.Trajectory(1,:),padding,1); obj.Trajectory; obj.Trajectory(end,:)];
%             obj.ScrPaddedTrajectory = obj.Tracker.CalFun.deg2pix(obj.PaddedTrajectory);
%             obj.ScrPaddedTrajectory = obj.ScrPaddedTrajectory([2:end end],:);
%             obj.MaxFrame = (padding + size(obj.Trajectory,1)) * obj.Step;
        end
    end
    
end