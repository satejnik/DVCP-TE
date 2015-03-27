%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function ax2 = area2(ax1, varargin)

    ax2 = axes('position', get(ax1, 'position'));
    area(ax2, varargin{:});
    % Put the new axes' y labels on the right, 
    % set the x limits the same as the original axes',
    % and make the background transparent
    set(ax1, 'box', 'off');
    set(ax2, 'YAxisLocation', 'right', ...
             'color', 'none', ...
             'box', 'off', ...
             'xgrid', get(ax1, 'xgrid'), ...
             'ygrid', get(ax1, 'ygrid'));
	ylims = get(ax2, 'ylim');
    sp = linspace(ylims(1), ylims(2),length(get(ax1, 'ytick')));
    set(ax2, 'ytick', sp);
    linkaxes([ax1 ax2],'x');
end