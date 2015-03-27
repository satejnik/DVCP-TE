%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function seed = setRandSeed(varargin)

    % check input parameters
    if nargin > 0
        seed = varargin{1};
    else
        seed = genRandSeed();
    end
    
    block = [model '/TE Plant/TE Code/'];
    params = get_param(block, 'Parameters');
    params = [params(1:find(params == ',', 1, 'last')) num2str(seed)];
    set_param([model '/TE Plant/TE Code/'], 'Parameters', params);
end
