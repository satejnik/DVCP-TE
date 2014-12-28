function subfolders = subfolders( directory )
%SUBFOLDERS Summary of this function coming soon..
%   Detailed explanation coming soon..
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------

    contents = dir(directory);
    operator = [contents(:).isdir];
    contents = {contents(operator).name};
    contents(ismember(contents,{'.','..'})) = [];
    subfolders = contents;
end

