function [hists, elems] = counts(V, E)
%COUNTS Summary of this function coming soon..
%   Detailed explanation coming soon..
%
%	Copyright © 2014 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2014 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2014 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------

    %% Check.
    if ~isvector(V)
        error('Input parameter V must be a vector.');
    end
    
    %% Hists of whole vector.
    [hists, elems] = hist(V, unique(V));
    %indeces = (hists == 0);
    %hists(indeces) = hists(circshift(indeces', -1)');
    
    %% Certain elements vector supplied.
    if(nargin > 1)
        if ~isvector(E)% || length(V) < length(E)
            error('Input parameter E must be a vector of length less than length of V.');
        end
        
        hists = hists(ismember(elems, unique(E)));
        elems = intersect(V, E);
    end
end

