classdef RDM_RF_MapperC < RandomDotMotion
    properties
        Speed_shift = 1;
        Direction_shift = 45;
    end
    properties (Access = protected)
        LB_Hold
        RB_Hold
        Picked
        ApertureResize
        PickedPosition
        PickedRadius
        bOldTracker
        KB_Hold
    end
    methods
        function obj = RDM_RF_MapperC(varargin)
            obj = obj@RandomDotMotion(varargin{:});
            obj.bOldTracker = isprop(obj.Tracker,'MouseData');
        end
        function init(obj,p)
            init@RandomDotMotion(obj,p);
            obj.LB_Hold = false;
            obj.RB_Hold = false;
            obj.Picked = false;
            obj.ApertureResize = false;
            obj.KB_Hold = false(1, 4);            
        end
        function continue_ = analyze(obj,p)
            continue_ = analyze@RandomDotMotion(obj,p);
            
            % get the mouse position and keyboard input
            if obj.bOldTracker
                xydeg = obj.Tracker.CalFun.pix2deg(obj.Tracker.MouseData(end,:));
                LB_Down = obj.Tracker.ClickData{1}(end);
                RB_Down = obj.Tracker.ClickData{2}(end);
                left  = mglgetkeystate(37);  % left arrow
                right = mglgetkeystate(39);  % right arrow
                pageup = mglgetkeystate(33);
                pagedown = mglgetkeystate(34);
            else
                xydeg = obj.Tracker.CalFun.pix2deg(obj.Tracker.XYData(end,:));
                LB_Down = obj.Tracker.ClickData(end,1);
                RB_Down = obj.Tracker.ClickData(end,2);
                left  = obj.Tracker.KeyInput(end,1);
                right = obj.Tracker.KeyInput(end,2);
                pageup = obj.Tracker.KeyInput(end,3);
                pagedown = obj.Tracker.KeyInput(end,4);
                
            end
            
            % calculate its polar coordinates
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

            % if ~obj.Picked && ~obj.ApertureResize && ~isnan(theta), obj.Direction = theta; end
            
            % if 0<=r, obj.Speed = r; end
            
            % keyboard control
            if ~left && obj.KB_Hold(1)
                a = obj.Speed - obj.Speed_shift;
                if 0<=a, obj.Speed = a; end
            end

            if ~right && obj.KB_Hold(2)
                obj.Speed = obj.Speed + obj.Speed_shift;
            end
           
            % Orientation Control
            if ~pageup && obj.KB_Hold(3)
                obj.Direction = mod(obj.Direction + obj.Direction_shift, 360);
            end
            if ~pagedown && obj.KB_Hold(4)
                obj.Direction = mod(obj.Direction - obj.Direction_shift, 360);
            end
            
            obj.KB_Hold = [left right pageup pagedown];
            
            
            % display some information on the control screen
            p.dashboard(1,sprintf('Position = [%.1f %.1f]',obj.Position));
            p.dashboard(2,sprintf('Direction = %.1f, Speed = %.1f',obj.Direction, obj.Speed));
        end
    end
end
