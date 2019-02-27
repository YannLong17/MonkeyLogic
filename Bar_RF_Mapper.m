classdef Bar_RF_Mapper < BarStimulus
    properties
        Colors = [0 0 0; 1 1 1];
        Orientation_Shift = pi/4;
    end
    properties (Access = protected)
        LB_Hold
        Picked
        PickedPosition
        RB_Hold
        PickedOrientation
        KB_Hold
        bOldTracker
        colori = 1;
        bar_width;
        
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
            obj.KB_Hold = false(1,7);
            obj.bar_width = obj.Ratio * obj.Sizel;
            
        end
        function fini(obj,p)
            fini@BarStimulus(obj,p);
            mglactivategraphic(obj.GraphicID,false);
        end
                     
       function set.Colors(obj,val)
             if isempty(val) || any(any(val<0)) || any(any(isnan(val))), val = [NaN NaN NaN]; end
             if 3~=size(val,2), error('Colors must be a n-by-3 vector'); end
            obj.Colors = val;
            obj.colori = 1;
            obj.Color = obj.Colors(obj.colori, :);
       end
       
      function set.Orientation_Shift(obj,val)
            if ~isscalar(val), error('Orientation_Shift must be a scalar'); end
%             if val < 0, error('Bar_Speed must be positive'); end
            obj.Orientation_Shift = mod(val, pi);
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
                enter = mglgetkeystate(13); % 
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
                enter = obj.Tracker.KeyInput(end,5);
                pageup = obj.Tracker.KeyInput(end,6);
                pagedown = obj.Tracker.KeyInput(end,7);
            end
            
            % mouse control
            r = realsqrt(sum((xydeg).^2));
            theta = sign(xydeg(2)) * acosd((xydeg(1))/r);
            
            % Change Position
            if ~obj.LB_Hold && LB_Down, obj.Picked = true;  obj.LB_Hold = true; obj.PickedPosition = xydeg - obj.Position; end
            if obj.LB_Hold && ~LB_Down, obj.Picked = false; obj.LB_Hold = false; end
            if obj.Picked, obj.Position = xydeg - obj.PickedPosition; end
            
            % keyboard control

            % Bar Width Control
            if ~left && obj.KB_Hold(1)
                a = obj.bar_width - 0.1;
                if 0<a
                    obj.bar_width = a; 
                    obj.set_Ratio;
                end
            end
            if ~right && obj.KB_Hold(3)
                a = obj.bar_width + 0.1;
                if a<obj.Sizel/2
                    obj.bar_width = a; 
                    obj.set_Ratio;
                end
            end
            
            % Size Control
            if ~up && obj.KB_Hold(2)
                obj.Sizel = obj.Sizel + 0.5;
                obj.set_Ratio;
            end
                
            if ~down && obj.KB_Hold(4)
                a = obj.Sizel - 0.5;
                if 0<a
                    obj.Sizel = a;
                    obj.set_Ratio; 
                end
            end
            if ~enter && obj.KB_Hold(5)
                obj.colori = mod(obj.colori,size(obj.Colors,1)) + 1;
                obj.Color = obj.Colors(obj.colori, :);
            end
            
            % Orientation
            if ~pageup && obj.KB_Hold(6)
                obj.Orientation = mod(obj.Orientation + obj.Orientation_Shift,pi);
            end
            if ~pagedown && obj.KB_Hold(7)
                obj.Orientation = mod(obj.Orientation - obj.Orientation_Shift,pi);
            end
          
            obj.KB_Hold = [left up right down enter pageup pagedown];
            
            % display some information on the control screen
            p.dashboard(1,sprintf('Position = [%.1f %.1f], Bat Length = %.1f',obj.Position,obj.Sizel));
            p.dashboard(2,sprintf('Orientation = %.1f, Bar Width = %.2f, theta = %.1f', rad2deg(obj.Orientation),obj.bar_width, theta));

        end
    end
    methods(Access=protected)
        function set_Ratio(obj)
            obj.Ratio = obj.bar_width/obj.Sizel;
        end
    end
    
    
end
