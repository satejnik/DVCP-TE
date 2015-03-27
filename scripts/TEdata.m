%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------

TEdata.Xmeas = cell(1,41);
for i=1:41;
    TEdata.Xmeas{i}.name = TEdata.title{i};
    TEdata.Xmeas{i}.units = TEdata.ylabel{i};
end

TEdata.Xmvs = cell(1,12);
for i=1:12;
    TEdata.Xmvs{i}.name = TEmvs.title{i};
    TEdata.Xmvs{i}.units = TEmvs.ylabel{i};
end