%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
classdef AttackController < handle
    
    properties 
        Type
        Block
        Art
        Mode
        Value
        Start
        Duration
        Signal
        Sampling
        OutputType
    end
    
    methods
        function this = AttackController(art, block)
            if ~ischar(art) && ~(strcmpi(art, 'xmeas') || strcmpi(art, 'xmv'))
               error('VAC:AttackController:contructor', 'First input parameter must be a string and have ''xmv'' or ''xmeas'' values.'); 
            end
            if ~isnumeric(block)
               error('VAC:AttackController:contructor', 'Block number parameter must be a numeric value.'); 
            end
            this.Reset();
            this.Art = art;
            this.Block = block;
        end
        
        function set.Type(object, value)
            if ~isa(value, 'AttackType')
                error('VAC:AttackController:Type:setter', 'Value must be of type AttackType');
            end
            object.Type = value;
        end
        
        function set.Mode(object, value)
            if ~isa(value, 'AttackMode')
                error('VAC:AttackController:Mode:setter''Value must be of type AttackMode');
            end
            object.Mode = value;
        end
        
        function set.OutputType(object, value)
            if ~isa(value, 'CustomOutput')
                error('VAC:AttackController:OutputType:setter''Value must be of type AttackMode');
            end
            object.OutputType = value;
        end
        
        function Reset(object)
            object.Type = AttackType.DOS;
            object.Mode = AttackMode.NONE;
            object.Value = 0;
            object.Start = 0;
            object.Duration = 0;
            object.Signal = '[]';
            object.Sampling = -1;
            object.OutputType = CustomOutput.HOLDINGVALUE;
        end
        
        function Set(object, workspace)
            if nargin < 2
                workspace = 'base';
            end
            evalin(workspace, ['set_ctrl_param(''' object.Art ''',' num2str(object.Block) ',AttackControllerProperties.ATTACK.Value,''' object.Type.String ''');' ...
                               'set_ctrl_param(''' object.Art ''',' num2str(object.Block) ',AttackControllerProperties.MODE.Value,''' object.Mode.String ''');' ...
                               'set_ctrl_param(''' object.Art ''',' num2str(object.Block) ',AttackControllerProperties.VALUE.Value,''' num2str(object.Value) ''');' ...
                               'set_ctrl_param(''' object.Art ''',' num2str(object.Block) ',AttackControllerProperties.START.Value,''' num2str(object.Start) ''');' ...
                               'set_ctrl_param(''' object.Art ''',' num2str(object.Block) ',AttackControllerProperties.DURATION.Value,''' num2str(object.Duration) ''');' ...
                               'set_ctrl_param(''' object.Art ''',' num2str(object.Block) ',AttackControllerProperties.SIGNALVARIABLE.Value,''' object.Signal ''');' ...
                               'set_ctrl_param(''' object.Art ''',' num2str(object.Block) ',AttackControllerProperties.SAMPLING.Value,''' num2str(object.Sampling) ''');' ...
                               'set_ctrl_param(''' object.Art ''',' num2str(object.Block) ',AttackControllerProperties.CUSTOMOUTPUT.Value,''' object.OutputType.String ''');']);
        end
    end
end


