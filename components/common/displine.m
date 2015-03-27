%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function displine(str)

    persistent len;
    
    if nargin < 1 && ~isempty(len) && len > 0
       len = 0;
       return;
    end
    
    % check parameters   
    if ~ischar(str)
        error('Input parameters must be a char array.');
    end
    
    % perform display line
    if ~isempty(len) && len > 0
        disp(repmat(char(8), 1, len + 1));
    end
    
    len = length(str) + 1;
    disp(str);
end

