classdef SineGratingC < mlstimulus
    properties
        Position                % [x,y] in degrees
        Radius                  % aperture radius in degrees
        Direction = 45;         % degrees
        SpatialFrequency = 1;   % cycles per deg
        TemporalFrequency = 2;  % cycles per sec
        Color1                  % RGB [0 0 0]
        Color2                  % RGB
        Contrast                % Scalar between [0 1]
    end
    properties (Access = protected)
        GridX
        GridY
        Imdata
        ScrPosition
        ScrRadius
        GraphicID
    end
    methods
        function obj = SineGratingC(varargin)
            obj = obj@mlstimulus(varargin{:});
            
            obj.Position = [0 0];
            obj.Radius = 1;
            obj.Color1 = [0 0 0];
            obj.Color2 = [1 1 1];
            obj.Contrast = 1;
            
        end
        function delete(obj)
            destroy_graphic(obj);
        end
        
        function set.Position(obj,pos)
            if 2~=numel(pos), error('Position must be a 1-by-2 vector'); end
            pos = pos(:)';
            if ~isempty(obj.Position) && all(pos==obj.Position), return, end
            obj.Position = pos;
            obj.ScrPosition = obj.Tracker.CalFun.deg2pix(pos); %#ok<*MCSUP>
        end
        function set.Radius(obj,radius)
            if ~isscalar(radius), error('Radius must be a scalar'); end
            if radius<=0, error('Radius must be a positive number'); end
            if ~isempty(obj.Radius) && radius==obj.Radius, return, end
            obj.Radius = radius;
            
            ppd = obj.Tracker.Screen.PixelsPerDegree;
            z = -radius:1/ppd:radius;
            z = z - mean(z);
            [x,y] = meshgrid(z,z);
            imdata = zeros([size(x) 4]);
            imdata(:,:,1) = (x.^2 + y.^2) < radius*radius;
            obj.GridX = x;
            obj.GridY = y;
            obj.Imdata = imdata;
        end
        
       function set.Color1(obj,val)
            if isempty(val) || any(val<0) || any(isnan(val)), val = [NaN NaN NaN]; end
            if 3~=numel(val), error('Color must be a 1-by-3 vector'); end
            obj.Color1 = val(:)';
       end
       
       function set.Color2(obj,val)
            if isempty(val) || any(val<0) || any(isnan(val)), val = [NaN NaN NaN]; end
            if 3~=numel(val), error('Color must be a 1-by-3 vector'); end
            obj.Color2 = val(:)';
       end
       
       function set.Contrast(obj,val)
            if isempty(val) || any(val<0) || any(isnan(val)), val = NaN; end
            if ~isscalar(val), error('Contrast must be a scalar'); end
            obj.Contrast = min(1, val);
       end
        
        function init(obj,p)
            init@mlstimulus(obj,p);
            if ~obj.Trigger, obj.Triggered = true; end
        end
        function fini(obj,p)
            fini@mlstimulus(obj,p);
            mglactivategraphic(obj.GraphicID,false);
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
            
            if obj.Triggered
                destroy_graphic(obj);

                direction = mod(-obj.Direction,360);
                cycles_per_deg = obj.SpatialFrequency;
                cycles_per_sec = obj.TemporalFrequency;
                t = p.scene_frame() * p.Screen.FrameLength / 1000;  % in seconds
                grating = (sind(360*cycles_per_deg*(obj.GridX*cosd(direction) + obj.GridY*sind(direction)) - 360*cycles_per_sec*t) + 1) / 2;
                
                % Apply Contrast
                bg = (obj.Color1 + obj.Color2)/2;   % Mean Between 2 colors
                color_1 = bg + obj.Contrast*(obj.Color1-bg);
                color_2 = bg + obj.Contrast*(obj.Color2-bg);

                for i = 1:3
                   obj.Imdata(:,:,i+1) = color_1(i) + grating*(color_2(i) - color_1(i)); 
                end

                obj.GraphicID = mgladdbitmap(obj.Imdata);
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
