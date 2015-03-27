%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
classdef ModelTimeSpan
    
    properties (SetAccess = private, GetAccess = public)
        Hours = 0
        Minutes = 0
        Seconds = 0
        TotalHours
        TotalMinutes
        TotalSeconds
    end
    
    methods
        
        function self = ModelTimeSpan(varargin)
            switch nargin
                case 3
                    hours = floor(varargin{1});
                    minutes = floor(varargin{2});
                    seconds = floor(varargin{3});
                case 2
                    hours = 0;
                    minutes = floor(varargin{1});
                    seconds = floor(varargin{2});
                case 1
                    hours = 0;
                    minutes = 0;
                    seconds = floor(varargin{1});
                otherwise
                    error('Wrong number of constructor input arguments.');
            end
            
            if ~isnumber(hours) || ~isnumber(minutes) || ~isnumber(seconds)
                error('Wrong input parameters type. They must be numeric.');
            end
            
            [seconds, delta, rest] = modulo(seconds, 60);
            minutes = minutes + delta;
            
            [minutes, delta, rest] = modulo(minutes, 60);
            hours = hours + delta;
            
            self.Hours = hours;
            self.Minutes = minutes;
            self.Seconds = seconds;
        end
        
        function value = get.TotalHours(object)
            value = object.Hours + (object.Minutes/60) + (object.Seconds/3600);
        end

        function value = get.TotalMinutes(object)
        	value = object.Hours*60 + object.Minutes + (object.Seconds/3600);
        end
        
        function value = get.TotalSeconds(object)
        	value = object.Hours*3600 + object.Minutes*60 + object.Seconds;
        end
        
        function value = ToHHMMSS(object)
            value = object.Hours * 10000 + ...
                    object.Minutes * 100 + ...
                    object.Seconds;
        end
        
    end
    
    methods(Static)
        
        function self = FromHours(hours)
            
            if ~isnumber(hours)
                error('Wrong input parameter type. They must be numeric value.');
            end
            
%             [hours, rest] = parts(hours);
%             [minutes, rest] = parts(rest*60);
%             seconds = floor(rest*60);
            self = ModelTimeSpan(hours * 3600);
        end
        
        function self = FromMinutes(minutes)
            
            if ~isnumber(minutes)
                error('Wrong input parameter type. They must be numeric value.');
            end
            
%             [minutes, rest] = parts(minutes);
%             seconds = floor(rest*60);
            self = ModelTimeSpan(minutes * 60);
        end
        
        function self = FromSeconds(seconds)
            
            if ~isnumber(seconds)
                error('Wrong input parameter type. They must be numeric value.');
            end
            
            self = ModelTimeSpan(seconds);
        end
        
        function self = FromHHMMSS(hhmmss)
            hours = floor(hhmmss/10000);
            minutes = floor(mod(hhmmss, 10000)/100);
            seconds = mod(hhmmss ,100);
            self = ModelTimeSpan(hours, minutes, seconds);
        end
        
    end
end

