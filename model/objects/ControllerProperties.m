classdef ControllerProperties
%CONTROLLERPROPERTIES Summary of this class coming soon..
%   Detailed explanation coming soon..
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
    
    properties
        Value
    end
    
    methods
        function this = ControllerProperties(value)
            this.Value = value;
        end
    end
    
    enumeration
        ATTACK('switch_mode')
        MODE('atkMode')
        VALUE('Value')
        START('start')
        DURATION('duration')
        SIGNALVARIABLE('signalin')
        SAMPLING('stime')
        CUSTOMOUTPUT('afterend')
    end
end

