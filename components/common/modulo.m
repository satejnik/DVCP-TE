%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function [modul, numbers, rest] = modulo(a, b)

    modul = mod(a, b);
    numbers = floor(a/b);
    if ~numbers
        rest = b - a;
    else
        rest = 0;
    end;
    
end

