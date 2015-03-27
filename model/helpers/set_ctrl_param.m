%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function set_ctrl_param(art, block, param, value)

    % check input parameters    
    if ~ischar(param)
        error('param argument must be a string value containing name of a property');
    end
    
    if ~ischar(art) && ~(strcmpi(art, 'xmeas') || strcmpi(art, 'xmv'))
       error('First input parameter must be a string and have ''xmv'' or ''xmeas'' values.'); 
    end
    
    % version
    version = isnumeric(block);
    
    % set objects parameter
    if version
        block = [bdroot '/TE Plant/' art ' atk block/' art num2str(block) ' attack controller'];
    else
        block = [bdroot '/TE Plant/' art ' atk block/' block];
    end
    
    if strcmp(param, ControllerProperties.START.Value) || ...
            strcmp(param, ControllerProperties.DURATION.Value)
        value = ModelTimeSpan.FromHHMMSS(value).TotalHours;
    end
    
    if isnumeric(value)
        value = num2str(value);
    end
    
    set_param(block, param, value);
end

