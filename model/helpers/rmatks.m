function rmatks
%RMATKS Summary of this function coming soon..
%   Detailed explanation coming soon..
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------

    %% contants
    xmeas = [1:5 7:12 14 15 17 31 40];
    xmv = 1:12;

    %% xmeas attack controllers
    for i = xmeas
        set_xmeas_ctrl_param(i, ControllerProperties.MODE.Value, AttackMode.NONE.String);
    end
    
    %%  xmv attack controllers
    for i = xmv
        set_xmv_ctrl_param(i, ControllerProperties.MODE.Value, AttackMode.NONE.String);
    end
end