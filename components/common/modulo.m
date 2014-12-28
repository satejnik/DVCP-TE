function [modul, numbers, rest] = modulo(a, b)
%MODULO Summary of this function coming soon..
%   Detailed explanation coming soon..
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------

    modul = mod(a, b);
    numbers = floor(a/b);
    if ~numbers
        rest = b - a;
    else
        rest = 0;
    end;
    
end

