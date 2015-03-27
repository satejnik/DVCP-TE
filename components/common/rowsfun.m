%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function ret = rowsfun(f, M)

    rowfun = @(func, matrix) @(row) func(matrix(row, :));
    applytorows = @(func, matrix) arrayfun(rowfun(func, matrix), 1:size(matrix,1), 'UniformOutput', false)';
    takeall = @(x) reshape([x{:}], size(x{1},2), size(x,1))';
    genericapplytorows = @(func, matrix) takeall(applytorows(func, matrix));
    ret = genericapplytorows(f, M);
end

