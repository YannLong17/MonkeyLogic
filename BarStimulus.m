classdef BarStimulus < mlstimulus  % The file name should match the class name
    properties
        % Define input variables here. All variables should be initialized
        % before create_scene() is called.
        Position    % [x y] in DVA
        Sizel       % Length of long size, in DVA 
        Ratio       % Thickness ratio, angle from 0 to pi/4
        Orientation % Bar Orientation, angle from 0 to pi
        Color       % RGB [0 0 0]
        
    end
    properties (SetAccess = protected)
        % Define output variables here.
        
    end
    
    
    properties (Access = protected)
        % Define internal variables here. These variables are not accessible
        % from the outside of the class.
        ScrPosition
        ScrSize
        Vertex
        GraphicID
    end
    
    methods
        function obj = BarStimulus(varargin)  % Change this function's name to the same as the class name
            obj = obj@mlstimulus(varargin{:});  % DO NOT DELETE THIS LINE. It is to complete the adapter chain.
            
            % Things to do when the class is instantiated
            obj.Position = [0 0];
            obj.Sizel = 2.0;
            obj.Orientation = 0.0;
            obj.Ratio = pi/32;
            obj.Color = [1 1 1];
            
            obj.ScrSize = obj.Sizel * obj.Tracker.Screen.PixelsPerDegree;
            obj.ScrPosition = obj.Tracker.CalFun.deg2pix(obj.Position);
        end
        function delete(obj) % #ok<INUSD>
            % Things to do when this adapter is destroyed by MATLAB
            destroy_graphic(obj);
        end
        
        function set.Position(obj,pos)
            if 2~=numel(pos), error('Position must be a 1-by-2 vector'); end
            pos = pos(:)';
            if ~isempty(obj.Position) && all(pos==obj.Position), return, end
            obj.Position = pos;
            obj.ScrPosition = obj.Tracker.CalFun.deg2pix(pos); %#ok<*MCSUP>
        end
        
        function set.Sizel(obj,sizel)
            if ~isscalar(sizel), error('Size must be a scalar'); end
            if sizel<=0, error('Size must be a positive number'); end
            if ~isempty(obj.Sizel) && sizel==obj.Sizel, return, end
            obj.Sizel = sizel;
            obj.ScrSize = obj.Tracker.Screen.PixelsPerDegree * sizel;
        end
        
       function set.Orientation(obj,ort)
            if ~isscalar(ort), error('Orientation must be an angle'); end
            if ~isempty(obj.Orientation) && ort==obj.Orientation, return, end
            obj.Orientation = mod(ort,pi);
       end
        
       function set.Ratio(obj,ratio)
            if ~isscalar(ratio), error('Ratio must be an angle'); end
            if ~isempty(obj.Ratio) && ratio==obj.Ratio, return, end
            obj.Ratio = mod(ratio, pi/4);
        end
        
        
       function set.Color(obj,val)
            if isempty(val) || any(val<0) || any(isnan(val)), val = [NaN NaN NaN]; end
            if 3~=numel(val), error('Color must be a 1-by-3 vector'); end
            obj.Color = val(:)';
       end
        
        
        function init(obj,p)
            init@mlstimulus(obj,p);
            % Things to do when the scene starts
            if ~obj.Trigger, obj.Triggered = true; end
        end
        
        function fini(obj,p)
            fini@mlstimulus(obj,p);
            mglactivategraphic(obj.GraphicID,false);
            % Things to do when the scene stops
        end
       
        function continue_ = analyze(obj,p)
            continue_ = analyze@mlstimulus(obj,p);
            obj.Success = obj.Adapter.Success;
            if ~obj.Triggered && obj.Success
                obj.Triggered = true;
                p.eventmarker(obj.EventMarker);
            end
        end
        
        function draw(obj,p)
            draw@mlstimulus(obj,p);
            % Things to do to update graphics
            % This function is called every frame during the scene but after
            % analyze() is called.
            
            if obj.Triggered
                destroy_graphic(obj);
                
                % Create Vertex
                obj.Vertex = zeros(2,4);
                x1 = cos(pi/2 - obj.Ratio)*0.5;
                y1 = sin(pi/2 - obj.Ratio)*0.5;
                obj.Vertex(1,1) = x1;
                obj.Vertex(2,1) = - y1;
                obj.Vertex(1,2) = x1;
                obj.Vertex(2,2) = y1;
                obj.Vertex(1,3) = - x1;
                obj.Vertex(2,3) = y1;
                obj.Vertex(1,4) = - x1;
                obj.Vertex(2,4) = - y1;
                
                % Rotate Stimulus
                rot_mat = [cos(obj.Orientation), -sin(obj.Orientation); sin(obj.Orientation), cos(obj.Orientation)];
                obj.Vertex = rot_mat*obj.Vertex + 0.5;
                
                % Draw Stimulus
                obj.GraphicID = mgladdpolygon([obj.Color, obj.Color],obj.ScrSize,[obj.Vertex(1,:)' 1-obj.Vertex(2,:)']);
                mglsetorigin(obj.GraphicID,obj.ScrPosition);
                           
            end
            
        end
    end
    methods (Access = protected)
        
        function destroy_graphic(obj)
            if ~isempty(obj.GraphicID), mgldestroygraphic(obj.GraphicID); obj.GraphicID = []; end
        end
    end
end
