function maximize(hFig)
%MAXIMIZE Maximize a figure window to fill the entire screen.
% 	Maximizes the current or input figure so that it fills the whole of the
% 	screen that the figure is currently on. This function is platform
% 	independent.
%
% 	Examples:
%   	maximize
%   	maximize(h)
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------

    if nargin < 1
        hFig = gcf;
    end
    drawnow % Required to avoid Java errors
    jFig = get(handle(hFig), 'JavaFrame'); 
    jFig.setMaximized(true);

end