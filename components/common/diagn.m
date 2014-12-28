function mat = diagn(A, pointer)
%DIAGN Summary of this function coming soon..
%   Detailed explanation coming soon..
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------

    if nargin < 2
        pointer = 0;
    end
    
    s = size(A);
    mat = A .* (triu(ones(s), 1 + pointer) + tril(ones(s), -1 + pointer));
end

