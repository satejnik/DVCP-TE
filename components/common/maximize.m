%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function maximize(hFig)
% 	Examples:
%   	maximize -> max. current window
%   	maximize(h) -> window handler

    if nargin < 1
        hFig = gcf;
    end
    drawnow % Required to avoid Java errors
    jFig = get(handle(hFig), 'JavaFrame'); 
    jFig.setMaximized(true);

end