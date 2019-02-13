classdef Bar_RF_Mapper < BarStimulus
    properties
                
    end
    properties (Access = protected)
        LB_Hold
        Picked
        PickedPosition
        RB_Hold
        OrtChange
        PickedOrientation
        KB_Hold
        bOldTracker
    end
    methods
        function obj = Bar_RF_Mapper(varargin)
            obj = obj@BarStimulus(varargin{:});
            obj.bOldTracker = isprop(obj.Tracker,'MouseData');
        end
        
        function init(obj,p)
            init@BarStimulus(obj,p);
            obj.LB_Hold = false;
            obj.Picked = false;
            obj.RB_Hold = false;
            obj.OrtChange = false;
            obj.KB_Hold = false(1,4);
        end
        function fini(obj,p)
            fini@BarStimulus(obj,p);
            mglactivategraphic(obj.GraphicID,false);
        end
        
        function continue_ = analyze(obj,p)
            continue_ = analyze@BarStimulus(obj,p);
            
            % get the mouse and keyboard input
            if obj.bOldTracker
                xydeg = obj.Tracker.CalFun.pix2deg(obj.Tracker.MouseData(end,:));
                LB_Down = obj.Tracker.ClickData{1}(end);
                RB_Down = obj.Tracker.ClickData{2}(end);
                left  = mglgetkeystate(37);  % left arrow
                up    = mglgetkeystate(38);  % up arrow
                right = mglgetkeystate(39);  % right arrow
                down  = mglgetkeystate(40);  % down arrow
            else 
                xydeg = obj.Tracker.CalFun.pix2deg(obj.Tracker.XYData(end,:));
                LB_Down = obj.Tracker.ClickData(end,1);
                RB_Down = obj.Tracker.ClickData(end,2);
                left  = obj.Tracker.KeyInput(end,1);
                up    = obj.Tracker.KeyInput(end,2);
                right = obj.Tracker.KeyInput(end,3);
                down  = obj.Tracker.KeyInput(end,4);
            end
            
            % mouse control
            r = realsqrt(sum((xydeg).^2));
            theta = sign(xydeg(2)) * acosd((xydeg(1))/r);
            
            % Change Position
            if ~obj.LB_Hold && LB_Down, obj.Picked = true;  obj.LB_Hold = true; obj.PickedPosition = xydeg - obj.Position; end
            if obj.LB_Hold && ~LB_Down, obj.Picked = false; obj.LB_Hold = false; end
            if obj.Picked, obj.Position = xydeg - obj.PickedPosition; end
            
            % Change Orientation
            if ~obj.RB_Hold && RB_Down, obj.OrtChange = true;  obj.RB_Hold = true; obj.PickedOrientation = degtorad(theta); end
            if obj.RB_Hold && ~RB_Down, obj.OrtChange = false; obj.RB_Hold = false; end
            if obj.OrtChange
                obj.Orientation = mod(obj.PickedOrientation, pi);
            end
            
%              if ~obj.Picked && ~isnan(theta), obj.Orientation = mod(theta,pi); end
            
            % keyboard control
            % Ratio Control
            if ~left && obj.KB_Hold(1)
                a = obj.Ratio - 0.05;
                if 0<a; obj.Ratio = a; end
            end
            if ~right && obj.KB_Hold(3)
                a = obj.Ratio + 0.05;
                if a<pi/4; obj.Ratio = a; end
            end
            
            % Size Control
            if ~up && obj.KB_Hold(2)
                obj.Sizel = obj.Sizel + 0.5;
            end
            if ~down && obj.KB_Hold(4)
                a = obj.Sizel - 0.5;
                if 0<a, obj.Sizel = a; end
            end
            
            obj.KB_Hold = [left up right down];
            
            % display some information on the control screen
            p.dashboard(1,sprintf('Position = [%.1f %.1f], Size = %.1f',obj.Position,obj.Sizel));
            p.dashboard(2,sprintf('Orientation = %.1f, Ratio = %.2f, theta = %.1f', radtodeg(obj.Orientation),obj.Ratio, theta));

        end
    end
end
