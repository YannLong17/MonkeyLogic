classdef Grating_RF_MapperC < SineGratingC
    properties
        SpatialFrequencyStep = 0.2;
        TemporalFrequencyStep = 0.2;
        Direction_shift = 45;
    end
    properties (Access = protected)
        LB_Hold
        Picked
        PickedPosition
        RB_Hold
        ApertureResize
        PickedRadius
        KB_Hold
        bOldTracker
    end
    methods
        function obj = Grating_RF_MapperC(varargin)
            obj = obj@SineGratingC(varargin{:});
            obj.bOldTracker = isprop(obj.Tracker,'MouseData');
        end
        
        function init(obj,p)
            init@SineGratingC(obj,p);
            obj.LB_Hold = false;
            obj.Picked = false;
            obj.RB_Hold = false;
            obj.ApertureResize = false;
            obj.KB_Hold = false(1,6);
        end
        function fini(obj,p)
            fini@SineGratingC(obj,p);
            mglactivategraphic(obj.GraphicID,false);
        end
        
        function continue_ = analyze(obj,p)
            continue_ = analyze@SineGratingC(obj,p);
            
            % get the mouse and keyboard input
            if obj.bOldTracker
                xydeg = obj.Tracker.CalFun.pix2deg(obj.Tracker.MouseData(end,:));
                LB_Down = obj.Tracker.ClickData{1}(end);
                RB_Down = obj.Tracker.ClickData{2}(end);
                left  = mglgetkeystate(37);  % left arrow
                up    = mglgetkeystate(38);  % up arrow
                right = mglgetkeystate(39);  % right arrow
                down  = mglgetkeystate(40);  % down arrow
                pageup = mglgetkeystate(33);
                pagedown = mglgetkeystate(34);
                
            else 
                xydeg = obj.Tracker.CalFun.pix2deg(obj.Tracker.XYData(end,:));
                LB_Down = obj.Tracker.ClickData(end,1);
                RB_Down = obj.Tracker.ClickData(end,2);
                left  = obj.Tracker.KeyInput(end,1);
                up    = obj.Tracker.KeyInput(end,2);
                right = obj.Tracker.KeyInput(end,3);
                down  = obj.Tracker.KeyInput(end,4);
                pageup = obj.Tracker.KeyInput(end,5);
                pagedown = obj.Tracker.KeyInput(end,6);
            end
            
            % mouse control
            r = realsqrt(sum((xydeg-obj.Position).^2));
%             theta = sign(xydeg(2)-obj.Position(2)) * acosd((xydeg(1)-obj.Position(1))/r);
            
            if ~obj.LB_Hold && LB_Down, obj.Picked = true;  obj.LB_Hold = true; obj.PickedPosition = xydeg - obj.Position; end
            if obj.LB_Hold && ~LB_Down, obj.Picked = false; obj.LB_Hold = false; end
            if obj.Picked, obj.Position = xydeg - obj.PickedPosition; end
            
            if ~obj.RB_Hold && RB_Down, obj.ApertureResize = true;  obj.RB_Hold = true; obj.PickedRadius = r - obj.Radius; end
            if obj.RB_Hold && ~RB_Down, obj.ApertureResize = false; obj.RB_Hold = false; end
            if obj.ApertureResize
                apsize = r - obj.PickedRadius;
                if 0<apsize, obj.Radius = apsize; end
            end
            
            % if ~obj.Picked && ~obj.ApertureResize && ~isnan(theta), obj.Direction = mod(theta,360); end
            
            % keyboard control
            if ~left && obj.KB_Hold(1)
                a = obj.SpatialFrequency - obj.SpatialFrequencyStep;
                if 0<a, obj.SpatialFrequency = a; end
            end
            if ~up && obj.KB_Hold(2)
                obj.TemporalFrequency = obj.TemporalFrequency + obj.TemporalFrequencyStep;
            end
            if ~right && obj.KB_Hold(3)
                obj.SpatialFrequency = obj.SpatialFrequency + obj.SpatialFrequencyStep;
            end
            if ~down && obj.KB_Hold(4)
                a = obj.TemporalFrequency - obj.TemporalFrequencyStep;
                if 0<a, obj.TemporalFrequency = a; end
            end
            
            % Orientation Control
            if ~pageup && obj.KB_Hold(5)
                obj.Direction = mod(obj.Direction + obj.Direction_shift, 360);
            end
            if ~pagedown && obj.KB_Hold(6)
                obj.Direction = mod(obj.Direction - obj.Direction_shift, 360);
            end
            
            obj.KB_Hold = [left up right down pageup pagedown];
            
            % display some information on the control screen
            p.dashboard(1,sprintf('Position = [%.1f %.1f], Radius = %.1f, Direction = %.1f',obj.Position,obj.Radius,obj.Direction));
            p.dashboard(2,sprintf('SpatialFrequency = %.1f, TemporalFrequency = %.1f',obj.SpatialFrequency,obj.TemporalFrequency));
        end
    end
end
