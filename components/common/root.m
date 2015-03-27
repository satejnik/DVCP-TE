%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function path = root(value)

    persistent path_persist;
    
    if nargin > 0
       path_persist = value;
    elseif isempty(path_persist)
       path_persist = '';
    end
    
    path = path_persist;
end

