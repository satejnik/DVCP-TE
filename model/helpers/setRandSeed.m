function seed = setRandSeed(varargin)
%SETRANDSEED Sets a random seed for the model.
%   SETRANDSEED generates, if not present a random seed
%               and sets it for a current model.
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------

    %% check input parameters
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
