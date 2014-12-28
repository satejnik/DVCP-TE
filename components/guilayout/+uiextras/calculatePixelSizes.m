function pixSizes = calculatePixelSizes( availableSize, sizes, minSizes, padding, spacing )
%calculatePixelSizes  convert flexible sizes into pixel sizes
    
%   Copyright 2009-2011 The MathWorks, Inc.
%   $Revision: 288 $ 
%   $Date: 2010-07-14 12:23:50 +0100 (Wed, 14 Jul 2010) $



%calculatePixelSizes
nChildren = numel( sizes );
pixSizes = zeros( numel( sizes ), 1 ); % initialize
minSizes = minSizes(:);

% First set the fixed-size components
fixed = ( sizes >= 0 );
pixSizes(fixed) = sizes(fixed);

% Now split the remaining space between any flexible ones
flexible = ( sizes<0 );
flexSize = availableSize ...
    - sum( sizes(fixed) ) ...     % space taken by fixed components
    - spacing * (nChildren-1) ... % space taken by the spacing
    - padding * 2;                % space around the edge
pixSizes(flexible) = sizes(flexible) / sum( sizes(flexible) ) * flexSize;

% Now look for any that are below their minimum size
tooSmall = (pixSizes < minSizes);
while any( tooSmall )
    flexSize = flexSize - sum( minSizes(tooSmall) );
    flexible(tooSmall) = false;
    pixSizes(tooSmall) = minSizes(tooSmall);
    pixSizes(flexible) = sizes(flexible) / sum( sizes(flexible) ) * flexSize;
    tooSmall = (pixSizes < minSizes);
end

% If we didn't manage to fit, reduce all sizes by a bit until
% we do
if sum( pixSizes ) > availableSize
    reduction = availableSize / sum( pixSizes );
    pixSizes = pixSizes * reduction;
end

% Finally, to prevent errors, don't allow anything to be smaller than 1 pixel
pixSizes = max( pixSizes, 1 );
end % calculatePixelSizes