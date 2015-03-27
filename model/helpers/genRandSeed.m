%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function rSeed = genRandSeed

    rng('shuffle');
    rand_range_max = 9999999999;
    rand_range_min = 1000000000;
    rSeed = randi([rand_range_min, rand_range_max]);
    
end