function set_pause(input)
%SET_PAUSE Summary of this function coming soon..
%   Detailed explanation coming soon..
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------

    if ischar(input)
        set_param([bdroot '/Pause'], 'Value', input);
        return;
    end

    if isnumeric(input) && max(size(input)) < 2
        set_param([bdroot '/Pause'], 'Value', num2str(input));
        return;
    end
    
    error('Bad input parameter');
end

