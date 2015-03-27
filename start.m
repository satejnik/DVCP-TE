%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
currentDir = fileparts(mfilename('fullpath'));
commonDir = fullfile(currentDir, 'components\common');
addpath(commonDir);
root(currentDir);
%if savepath() ~= 0
%    fprintf( 'Failed to save ''%s'' search path permanently, you will need to re-run when MATLAB is restarted\n', commonDir);
%end
%-----------------------------------------------------------------------------
% Add all others folders to the search path for current session only
dirs = subfolders(currentDir);
for dd=1:numel(dirs)
    dirs{dd} = fullfile(currentDir, dirs{dd});
end
addpaths(dirs, 'recursive');
clear