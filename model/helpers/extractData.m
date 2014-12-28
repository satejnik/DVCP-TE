function data = extractData
%EXTRACTDATA Summary of this function coming soon..
%   Detailed explanation coming soon..
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------

    data.tout = evalin('base', 'tout');
    data.simout = evalin('base', 'simout');
    if evalin('base', 'exist(''simout_normal'')')
        data.simoutNormal = evalin('base', 'simout_normal');
    end
    if evalin('base', 'exist(''xmv_normal'')')
        data.xmvNormal = evalin('base', 'xmv_normal');
    end
    data.xmv = evalin('base', 'xmv');
%     data.idv = evalin('base', 'idv');
%     data.atkxmeas = evalin('base', 'atkxmeas');
%     data.atkxmv = evalin('base', 'atkxmv');
end

