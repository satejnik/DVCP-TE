function spyc(varargin)
%SPYC Visualize sparsity pattern with color-coded scale.
%   SPYC(S) plots the color-coded sparsity pattern of the matrix S.
%
%   SPYC(S,CMAP) plots the sparsity pattern of the matrix S USING 
%                    COLORMAP CMAP.
%
%   SPYC(S,CMAP,PB) allows turning off the display of a colorbar by passing
%                   flag PB=0
%
%   written by Try Hard
%   $Revision: 0.0.0.2 $  $Date: 2013/08/24 11:11:11 $

    if nargin < 1 || nargin > 3
        error( 'spyc:InvalidNumArg', 'spyc takes one to three inputs');
    end
    
    index = 1;
    if isaxis(varargin{1})
        axes(varargin{1});
        index = 2;
    else
        axes(gca);
    end
    
    A = varargin{index};
    
    if isempty(A)
        error( 'spyc:InvalidArg', 'sparse matrix is empty');
    end
    
    if nargin > index
        index = index + 1;
        cmap = varargin{index};
        if ~isempty(cmap) && ~isnumeric(cmap)
            cmap = flipud(colormap(cmap));
        end
    else
        cmap = flipud(colormap('hot'));
    end

    % analyse
    indx = find(A); % not null
    [Nx, Ny] = size(A);
	A = full(A(indx));    
    [ix, iy] = ind2sub([Nx Ny], indx);
    imap = round((A - min(A)) * 63 / (max(A) - min(A))) + 1;
    
	colormap(cmap);
    scatter(iy, ix, [], imap, 'Marker', '.', 'SizeData', 200);
    set(gca, 'ydir','reverse')
    axis equal;
    xlabel(['nz = ' num2str(length(indx))]);
    axis([0 Nx + 1 0 Ny + 1]);
    box on;
    set(gca, 'XTick', 1:Nx);
    set(gca, 'YTick', 1:Ny);
    colorbar();
% 	caxis([min(min(A)) max(max(A))]);
    maximize(gcf);
end



