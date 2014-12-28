function set = sameset(varargin)
%SAMESET Summary of this function coming soon..
%   Detailed explanation coming soon..
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
    
    if nargin > 1
        input = {};
       for i = 1:nargin
           input = [input varargin{i}];
       end
    else
        input = varargin{1};
    end

    tmp = input;
    for i = 1:length(input) - 1
        tmp = intersect(input{i}, input{i + 1});
    end
    
    set = tmp;
end

