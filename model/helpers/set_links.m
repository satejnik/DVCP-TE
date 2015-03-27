%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function set_links(status)

    xmvs = 1:12;
    xmeas = [1:5 7:12 14:15 17 31 40];
    for i = xmeas
        set_link([bdroot '/TE Plant/xmeas atk block/xmeas' num2str(i) ' attack controller'], status);
    end
    for i = xmvs
        set_link([bdroot '/TE Plant/xmv atk block/xmv' num2str(i) ' attack controller'], status);
    end
end

