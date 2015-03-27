%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function result = endsWith(string, pattern)
    
    result = false;
    index = strfind(string, pattern);
    
    % not found
    if isempty(index)
        return;
    end
    
    string = string(index:end);
    if isequal(string, pattern)
        result = true;
    end
end
