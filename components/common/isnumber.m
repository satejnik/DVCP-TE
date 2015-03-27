%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function result = isnumber(input)
    
    result = true;
    if ~isnumeric(input)
       result = false;
       return;
    end
    
    [rows, columns] = size(input);
    if rows ~= 1 && columns ~= 1
        result = false;
        return;
    end
end

