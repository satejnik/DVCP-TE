%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function result=iif(cond, t, f)

    if isscalar(cond) 
       if cond 
           result = t;
       else
           result = f;
       end
    else
      result = (cond).*t + (~cond).*f;
    end  
end