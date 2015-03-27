%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function subfolders = subfolders( directory )

    contents = dir(directory);
    operator = [contents(:).isdir];
    contents = {contents(operator).name};
    contents(ismember(contents,{'.','..'})) = [];
    subfolders = contents;
end

