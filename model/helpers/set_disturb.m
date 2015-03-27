%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function set_disturb(input)

    if ischar(input)
        set_param([bdroot '/Disturbances'], 'Value', input);
        return;
    end

    if isnumeric(input)
        disturbances = zeros(1, 20);
        disturbances(input) = 1;
        set_param([bdroot '/Disturbances'], 'Value', mat2str(disturbances));
        return;
    end
    
    if ~isvector(input)
        error('Bad input parameter.');
    end
    
    if size(input, 2) == 1
        input = input';
    end
    
    set_param([bdroot '/Disturbances'], 'Value', mat2str(input));
end

