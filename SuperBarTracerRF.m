classdef SuperBarTracerRF < BarTracer
   properties
       % Inputs
      N_Trajectories = 5;  % Total number of possible Trajectories 
      Bar_Speed = 50;    % Bar Speed in DVA/s
      Bar_Width = 0.1;  % Bar Width in DVA
       
   end
   
   properties (SetAccess = protected)
       % Output
       PathId     % Randomly selected Orientation for current instance 
       PathTime   % Path Total Duration in s
   end 
    
   properties (Access = protected)
       % Internal Variable
       BigD
       RefreshRate
   end

 methods
       function obj = SuperBarTracerRF(varargin)
       obj = obj@BarTracer(varargin{:});
       
       Screen = obj.Tracker.Screen;
       ppd = Screen.PixelsPerDegree;
       obj.BigD = sqrt((Screen.Xsize/ppd)^2 + (Screen.Ysize/ppd)^2);
       obj.RefreshRate = Screen.RefreshRate;
       
       obj.Sizel = obj.BigD;
       
       end
       
       function set.N_Trajectories(obj,val)
            if ~isscalar(val), error('N_Orientations must be a scalar'); end
            if val < 0, error('N_Orientations must be a positive integer'); end
            obj.N_Trajectories = val;
            create_trajectory(obj);
       end
        
      function set.Bar_Speed(obj,val)
            if ~isscalar(val), error('Bar_Speed must be a scalar'); end
            if val < 0, error('Bar_Speed must be positive'); end
            obj.Bar_Speed = val;
            create_trajectory(obj);
      end
        
      function set.Bar_Width(obj,val)
            if ~isscalar(val), error('Bar_Width must be a scalar'); end
            if val < 0, error('Bar_Width must be positive'); end
            obj.Bar_Width = val;
            obj.Ratio = obj.Bar_Width/obj.BigD;
        end
 
 function continue_ = analyze(obj,p)
            continue_ = analyze@BarTracer(obj,p);
            obj.Success = obj.Adapter.Success;
        end
 
 end   
     methods (Access = protected)
        function create_trajectory(obj)
            % Randomly choose current orientation
            obj.PathId = randi(obj.N_Trajectories);
            theta = 2*pi/obj.N_Trajectories;
            theta = theta*obj.PathId;
            obj.Orientation = theta;
            
            % Find Path Duration
            total_time = obj.BigD/obj.Bar_Speed;
            % Convert time to frames (rounding to nearest frame)
            total_frame = round(total_time * obj.RefreshRate);
            obj.PathTime = total_frame / obj.RefreshRate;
            
            % Trace Trajectory
            t = linspace(-obj.BigD/2, obj.BigD/2, total_frame);
            obj.Trajectory = [t*cos(theta); t*sin(theta)]';

        end

    end
    
end