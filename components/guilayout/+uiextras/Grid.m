classdef Grid < uiextras.Container
    %Grid  Container with contents arranged in a grid
    %
    %   obj = uiextras.Grid() creates a new new grid layout with all
    %   properties set to defaults. The number of rows and columns to use
    %   is determined from the number of elements in the RowSizes and
    %   ColumnSizes properties respectively. Child elements are arranged
    %   down column one first, then column two etc. If there are
    %   insufficient columns then a new one is added. The output is a new
    %   layout object that can be used as the parent for other
    %   user-interface components. The output is a new layout object that
    %   can be used as the parent for other user-interface components.
    %
    %   obj = uiextras.Grid(param,value,...) also sets one or more
    %   parameter values.
    %
    %   See the <a href="matlab:doc uiextras.Grid">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> g = uiextras.Grid( 'Parent', f, 'Spacing', 5 );
    %   >> uicontrol( 'Style', 'frame', 'Parent', g, 'Background', 'r' )
    %   >> uicontrol( 'Style', 'frame', 'Parent', g, 'Background', 'b' )
    %   >> uicontrol( 'Style', 'frame', 'Parent', g, 'Background', 'g' )
    %   >> uiextras.Empty( 'Parent', g )
    %   >> uicontrol( 'Style', 'frame', 'Parent', g, 'Background', 'c' )
    %   >> uicontrol( 'Style', 'frame', 'Parent', g, 'Background', 'y' )
    %   >> set( g, 'ColumnSizes', [-1 100 -2], 'RowSizes', [-1 100] );
    %
    %   See also: uiextras.GridFlex
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 367 $ 
    %   $Date: 2011-02-10 16:25:22 +0000 (Thu, 10 Feb 2011) $
    
    properties( SetObservable ) 
        Padding = 0 % padding around and between contents [pixels]
        Spacing = 0 % spacing between contents [pixels]
    end % public properties
    
    properties( Dependent )
        RowSizes           % column vector of row sizes, with positive elements for absolute sizes (pixels) and negative elements for relative sizes
        ColumnSizes        % column vector of column sizes, with positive elements for absolute sizes (pixels) and negative elements for relative sizes
        MinimumRowSizes    % minimum size (in pixels) for each row
        MinimumColumnSizes % minimum size (in pixels) for each column
    end % dependent properties
    
    properties( Access=private )
  
        
    end % private properties
    properties( Access = private )
        RowSizes_ = zeros( 0, 1 )           % private property for storing actual row sizes
        ColumnSizes_ = zeros( 0, 1 )        % private property for storing actual column sizes
        MinimumRowSizes_ = zeros( 0, 1 )    % private property for storing actual minimum row sizes
        MinimumColumnSizes_ = zeros( 0, 1 ) % private property for storing actual minimum column sizes
    end % private properties
    
    methods
        
        function obj = Grid( varargin )
            %Grid  Create a container with contents in a grid.
            
            % First step is to create the parent class. We pass the
            % arguments (if any) just incase the parent needs setting
            obj@uiextras.Container( varargin{:} );

            % Set some defaults
            obj.setPropertyFromDefault( 'Padding' );
            obj.setPropertyFromDefault( 'Spacing' );

            % Set user-supplied property values (only if this is the leaf class)
            if nargin>0 && isequal( class( obj ), 'uiextras.Grid' )
                set( obj, varargin{:} );
            end
            
        end % constructor
        
    end % public methods
    
    methods
        
        function set.RowSizes( obj, value )
            
            % Check
            if ~isvector( value )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''RowSizes'' must be a vector.' )
            elseif ~isnumeric( value ) || ...
                    any( ~isreal( value ) ) || any( isnan( value ) ) || any( ~isfinite( value ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''RowSizes'' must consist of real, finite, numeric values.' )
            end
            
            % Set
            obj.RowSizes_ = value(:);
            
            % Make sure min row sizes is the same length
            nMinSizes = length(obj.MinimumRowSizes_);
            nSizes = length(obj.RowSizes_);
            if nMinSizes > nSizes
                obj.MinimumRowSizes_ = obj.MinimumRowSizes_(1:nSizes);
            elseif nMinSizes < nSizes
                obj.MinimumRowSizes_(end+1:nSizes,1) = 1;
            end
            
            % Add/remove elements to/from ColumnSizes, if required
            nColumns = ceil( numel( obj.Children ) / numel( obj.RowSizes_ ) );
            if numel( obj.ColumnSizes_ ) > nColumns
                obj.ColumnSizes_(nColumns+1:end,:) = [];
                obj.MinimumColumnSizes_(nColumns+1:end,:) = [];
            elseif numel( obj.ColumnSizes ) < nColumns
                obj.ColumnSizes_(end+1:nColumns,1) = -1;
                obj.MinimumColumnSizes_(end+1:nColumns,1) = 1;
            end
            
            % Redraw
            obj.redraw();
            
        end % set.RowSizes
        
        function value = get.RowSizes( obj )
            value = obj.RowSizes_;
        end % get.RowSizes
        
        function set.ColumnSizes( obj, value )
            % Check
            if ~isvector( value )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''ColumnSizes'' must be a vector.' )
            elseif ~isnumeric( value ) || ...
                    any( ~isreal( value ) ) || any( isnan( value ) ) || any( ~isfinite( value ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''ColumnSizes'' must consist of real, finite, numeric values.' )
            end
            
            % Set
            obj.ColumnSizes_ = value(:);
            
            % Make sure min row sizes is the same length
            nMinSizes = length(obj.MinimumColumnSizes_);
            nSizes = length(obj.ColumnSizes_);
            if nMinSizes > nSizes
                obj.MinimumColumnSizes_ = obj.MinimumColumnSizes_(1:nSizes);
            elseif nMinSizes < nSizes
                obj.MinimumColumnSizes_(end+1:nSizes,1) = 1;
            end
            
            % Add/remove elements to/from RowSizes, if required
            nRows = ceil( numel( obj.Children ) / numel( obj.ColumnSizes_ ) );
            if numel( obj.RowSizes_ ) > nRows
                obj.RowSizes_(nRows+1:end,:) = [];
                obj.MinimumRowSizes_(nRows+1:end,:) = [];
            elseif numel( obj.RowSizes ) < nRows
                obj.RowSizes_(end+1:nRows,1) = -1;
                obj.MinimumRowSizes_(end+1:nRows,1) = 1;
            end
            
            % Redraw
            obj.redraw();
        end % set.ColumnSizes
        
        function value = get.ColumnSizes( obj )
            value = obj.ColumnSizes_;
        end % get.ColumnSizes       
                
        function set.MinimumRowSizes( obj, value )
            % Check that this vector matches the size vector
            if ~isequal( numel( obj.RowSizes ), numel( value ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Size of property ''MinimumRowSizes'' must match size of property ''RowSizes''.' )
            elseif ~isnumeric( value ) || ...
                    any( ~isreal( value ) ) || any( isnan( value ) ) || any( ~isfinite( value ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''MinimumRowSizes'' must consist of real, finite, numeric values.' )
            end
            
            % Set and redraw
            obj.MinimumRowSizes_ = value(:)';
            obj.redraw();
        end % set.MinimumRowSizes
        
        function value = get.MinimumRowSizes( obj )
            value = obj.MinimumRowSizes_;
        end % get.MinimumRowSizes
                
        function set.MinimumColumnSizes( obj, value )
            % Check that this vector matches the size vector
            if ~isequal( numel( obj.ColumnSizes ), numel( value ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Size of property ''MinimumColumnSizes'' must match size of property ''RowSizes''.' )
            elseif ~isnumeric( value ) || ...
                    any( ~isreal( value ) ) || any( isnan( value ) ) || any( ~isfinite( value ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''MinimumColumnSizes'' must consist of real, finite, numeric values.' )
            end
            
            % Set and redraw
            obj.MinimumColumnSizes_ = value(:)';
            obj.redraw();
        end % set.MinimumColumnSizes
        
        function value = get.MinimumColumnSizes( obj )
            value = obj.MinimumColumnSizes_;
        end % get.MinimumColumnSizes
        
        function set.Padding( obj, value )
            % Check
            if ~isnumeric( value ) || ~isscalar( value ) || ...
                    ~isreal( value ) || isnan( value ) || ~isfinite( value ) || ...
                    value < 0 || rem( value, 1 ) ~= 0
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''Padding'' must be a nonnegative integer.' )
            end
            
            % Set
            obj.Padding = value;
            
            % Redraw
            obj.redraw();
        end % set.Padding
        
        function set.Spacing( obj, value )
            % Check
            if ~isnumeric( value ) || ~isscalar( value ) || ...
                    ~isreal( value ) || isnan( value ) || ~isfinite( value ) || ...
                    value < 0 || rem( value, 1 ) ~= 0
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''Spacing'' must be a nonnegative integer.' )
            end
            
            % Set
            obj.Spacing = value;
            
            % Redraw
            obj.redraw();
        end % set.Spacing
        
    end % accessor methods
    
    methods( Access = protected )
        
        function [widths,heights] = redraw( obj )
            %REDRAW  Redraw container contents.
            
            % Get container width and height
            totalPosition = ceil( getpixelposition( obj.UIContainer ) );
            totalWidth = totalPosition(3);
            totalHeight = totalPosition(4);
            
            % Get children
            children = obj.Children;
            nChildren = numel( children );
            
            % Get padding, spacing, widths and heights
            padding = obj.Padding;
            spacing = obj.Spacing;
            columnSizes = obj.ColumnSizes;
            minColumnSizes = obj.MinimumColumnSizes;
            rowSizes = obj.RowSizes;
            minRowSizes = obj.MinimumRowSizes;
            nColumns = numel( columnSizes );
            nRows = numel( rowSizes );
            
            % Compute widths and heights
            widths = uiextras.calculatePixelSizes( totalWidth, ...
                columnSizes, minColumnSizes, ...
                obj.Padding, obj.Spacing );
            heights = uiextras.calculatePixelSizes( totalHeight, ...
                rowSizes, minRowSizes, ...
                obj.Padding, obj.Spacing );
            
            % Compute and set new positions in pixels
            elementNumbers = reshape( 1:nRows*nColumns, [nRows, nColumns] );
            rowNumbers = repmat( transpose( 1:nRows ), [1, nColumns] );
            columnNumbers = repmat( 1:nColumns, [nRows, 1] );
            for ii = 1:nChildren
                child = children(ii);
                jj = rowNumbers(elementNumbers==ii); % row index
                kk = columnNumbers(elementNumbers==ii); % column index
                x = sum( widths(1:kk-1) ) + padding + spacing * (kk-1) + 1;
                y = totalHeight - sum( heights(1:jj) ) - padding - spacing*(jj-1) + 1;
                newPosition = [x, y, widths(kk), heights(jj)];   
                obj.repositionChild( child, newPosition );
            end
            
        end % redraw
        
        function onChildAdded( obj, source, eventData ) %#ok<INUSD>
            %onChildAdded: Callback that fires when a child is added to a container.
            % Add element to RowSizes, if required
            if numel( obj.RowSizes_ ) == 0
                obj.RowSizes_ = -1;
                obj.MinimumRowSizes_ = 1;
            end
            
            % Add element to ColumnSizes, if required
            nColumns = ceil( numel( obj.Children ) / numel( obj.RowSizes_ ) );
            if numel( obj.ColumnSizes_ ) < nColumns
                obj.ColumnSizes_(end+1:nColumns,:) = -1;
                obj.MinimumColumnSizes_(end+1:nColumns,:) = 1;
            end
            
            obj.redraw();
            
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData ) %#ok<INUSD>
            %onChildAdded: Callback that fires when a container child is destroyed or reparented.
            if numel( obj.Children ) == 0
                % Remove elements from RowSizes and ColumnSizes
                obj.RowSizes_ = zeros( 0, 1 );
                obj.ColumnSizes_ = zeros( 0, 1 );
                obj.MinimumRowSizes_ = zeros( 0, 1 );
                obj.MinimumColumnSizes_ = zeros( 0, 1 );
            else
                % Remove elements from ColumnSizes, if required
                nColumns = ceil( numel( obj.Children ) / numel( obj.RowSizes_ ) );
                if numel( obj.ColumnSizes_ ) > nColumns
                    obj.ColumnSizes_(nColumns+1:end,:) = [];
                    obj.MinimumColumnSizes_(nColumns+1:end,:) = [];
                end
            end
            
            % Redraw
            obj.redraw();
        end % onChildRemoved
        
    end % protected methods
    
end % classdef