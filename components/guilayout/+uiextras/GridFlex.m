classdef GridFlex < uiextras.Grid
    %GridFlex  Container with contents arranged in a resizable grid
    %
    %   obj = uiextras.GridFlex() creates a new new grid layout with
    %   draggable dividers between elements. The number of rows and columns
    %   to use is determined from the number of elements in the RowSizes
    %   and ColumnSizes properties respectively. Child elements are
    %   arranged down column one first, then column two etc. If there are
    %   insufficient columns then a new one is added. The output is a new
    %   layout object that can be used as the parent for other
    %   user-interface components. The output is a new layout object that
    %   can be used as the parent for other user-interface components.
    %
    %   obj = uiextras.GridFlex(param,value,...) also sets one or more
    %   parameter values.
    %
    %   See the <a href="matlab:doc uiextras.GridFlex">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> g = uiextras.GridFlex( 'Parent', f, 'Spacing', 5 );
    %   >> uicontrol( 'Parent', g, 'Background', 'r' )
    %   >> uicontrol( 'Parent', g, 'Background', 'b' )
    %   >> uicontrol( 'Parent', g, 'Background', 'g' )
    %   >> uiextras.Empty( 'Parent', g )
    %   >> uicontrol( 'Parent', g, 'Background', 'c' )
    %   >> uicontrol( 'Parent', g, 'Background', 'y' )
    %   >> set( g, 'ColumnSizes', [-1 100 -2], 'RowSizes', [-1 -2] );
    %
    %   See also: uiextras.Grid
    %             uiextras.HBoxFlex
    %             uiextras.VBoxFlex
    %             uiextras.Empty
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 366 $
    %   $Date: 2011-02-10 15:48:11 +0000 (Thu, 10 Feb 2011) $
    
    properties
        ShowMarkings = 'on'  % Show markings on the draggable dividers [ on | off ]
    end % public methods
    
    properties( Access = private )
        RowDividers = []
        SelectedRowDivider = -1
        ColumnDividers = []
        SelectedColumnDivider = -1
        BlockRedraw = false
    end % private properties
    
    methods
        
        function obj = GridFlex( varargin )
            %GridFlex  Container with contents in a grid and movable dividers
            
            % First step is to create the parent class. We pass the
            % arguments (if any) just incase the parent needs setting
            obj@uiextras.Grid( varargin{:} );
            
            % Set some defaults
            obj.setPropertyFromDefault( 'ShowMarkings' );
            
            % Set user-supplied property values
            if nargin > 0
                set( obj, varargin{:} );
            end
        end % constructor
        
    end % public methods
    
    methods
        
        function set.ShowMarkings( obj, value )
            % Check
            if ~ischar( value ) || ~ismember( lower( value ), {'on','off'} )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''ShowMarkings'' may only be set to ''on'' or ''off''.' )
            end
            % Apply
            obj.ShowMarkings = lower( value );
            obj.redraw();
        end % set.ShowMarkings
        
    end % accessor methods
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw container contents
            
            % Prevent recursive redraws if we need to add/remove/reorder
            % dividers
            if obj.BlockRedraw
                return;
            end
            obj.BlockRedraw = true;
            
            % First simply call the grid redraw
            [widths,heights] = redraw@uiextras.Grid(obj);
            rowSizes = obj.RowSizes;
            columnSizes = obj.ColumnSizes;
            padding = obj.Padding;
            spacing = obj.Spacing;
            pos0 = ceil( getpixelposition( obj.UIContainer ) );
            
            % Now add the column dividers
            mph = uiextras.MousePointerHandler( obj.Parent );
            numDynamic = 0;
            for ii = 1:numel(columnSizes)-1
                if any(columnSizes(1:ii)<0) && any(columnSizes(ii+1:end)<0)
                    numDynamic = numDynamic + 1;
                    % Both dynamic, so add a divider
                    position = [sum( widths(1:ii) ) + padding + spacing * (ii-1) + 1, ...
                        padding + 1, ...
                        max(1,spacing), ...
                        max(1,pos0(4)-2*padding)];
                    % Create the divider widget
                    if numDynamic > numel( obj.ColumnDividers )
                        obj.ColumnDividers(numDynamic) = uiextras.makeFlexDivider( ...
                            obj.UIContainer, ...
                            position, ...
                            get( obj.UIContainer, 'BackgroundColor' ), ...
                            'Vertical', ...
                            obj.ShowMarkings );
                        set( obj.ColumnDividers(numDynamic), ...
                            'ButtonDownFcn', @obj.onColumnButtonDown, ...
                            'Tag', 'UIExtras:GridFlex:ColumnDivider' );
                        % Add it to the mouse-over handler
                        mph.register( obj.ColumnDividers(numDynamic), 'left' );
                    else
                        % Just update an existing divider
                        uiextras.makeFlexDivider( ...
                            obj.ColumnDividers(numDynamic), ...
                            position, ...
                            get( obj.UIContainer, 'BackgroundColor' ), ...
                            'Vertical', ...
                            obj.ShowMarkings );
                    end
                    setappdata( obj.ColumnDividers(numDynamic), 'WhichDivider', ii );
                end
            end
            % Remove any excess dividers
            if numel( obj.ColumnDividers ) > numDynamic
                delete( obj.ColumnDividers(numDynamic+1:end) );
                obj.ColumnDividers(numDynamic+1:end) = [];
            end
            
            % Now add the row dividers
            numDynamic = 0;
            for ii = 1:numel(rowSizes)-1
                if any(rowSizes(1:ii)<0) && any(rowSizes(ii+1:end)<0)
                    numDynamic = numDynamic + 1;
                    % Both dynamic, so add a divider
                    position = [padding + 1, ...
                        pos0(4) - sum( heights(1:ii) ) - padding - spacing*ii + 1, ...
                        max(1,pos0(3)-2*padding), ...
                        max(1,spacing)];
                    % Create the divider widget
                    if numDynamic > numel( obj.RowDividers )
                        obj.RowDividers(numDynamic) = uiextras.makeFlexDivider( ...
                            obj.UIContainer, ...
                            position, ...
                            get( obj.UIContainer, 'BackgroundColor' ), ...
                            'Horizontal', ...
                            obj.ShowMarkings );
                        set( obj.RowDividers(numDynamic), 'ButtonDownFcn', @obj.onRowButtonDown, ...
                            'Tag', 'UIExtras:GridFlex:RowDivider' );
                        % Add it to the mouse-over handler
                        mph.register( obj.RowDividers(numDynamic), 'top' );
                    else
                        % Just update an existing divider
                        uiextras.makeFlexDivider( ...
                            obj.RowDividers(numDynamic), ...
                            position, ...
                            get( obj.UIContainer, 'BackgroundColor' ), ...
                            'Horizontal', ...
                            obj.ShowMarkings );
                    end
                    setappdata( obj.RowDividers(numDynamic), 'WhichDivider', ii );
                end
            end
            % Remove any excess dividers
            if numel( obj.RowDividers ) > numDynamic
                delete( obj.RowDividers(numDynamic+1:end) );
                obj.RowDividers(numDynamic+1:end) = [];
            end

            % We need to ensure dividers are above all other children so
            % that they receive mouse clicks
            c = allchild( obj.UIContainer );
            tags = get(c,'Tag');
            isDivider = strcmp( tags, 'UIExtras:GridFlex:RowDivider' ) ...
                | strcmp( tags, 'UIExtras:GridFlex:ColumnDivider' );
            firstChild = find( ~isDivider, 1, 'first' );
            lastDivider = find( isDivider, 1, 'last' );
            if firstChild < lastDivider
                % We need to put the divider first
                set( obj.UIContainer, 'Children', [c(isDivider);c(~isDivider)] );
            end
            obj.BlockRedraw = false;

        end % redraw
        
        function onRowButtonDown( obj, source, eventData ) %#ok<INUSD>
            figh = ancestor( source, 'figure' );
            % Remove all column dividers
            ch = allchild( obj.UIContainer );
            dividers = strcmpi( get( ch, 'Tag' ), 'GridFlex:ColumnDivider' );
            delete( ch(dividers) );
            % We need to store any existing motion callbacks so that we can
            % restore them later.
            oldProps = struct();
            oldProps.WindowButtonMotionFcn = get( figh, 'WindowButtonMotionFcn' );
            oldProps.WindowButtonUpFcn = get( figh, 'WindowButtonUpFcn' );
            oldProps.Pointer = get( figh, 'Pointer' );
            oldProps.Units = get( figh, 'Units' );
            
            % Make sure all interaction modes are off to prevent our
            % callbacks being clobbered
            zoomh = zoom( figh );
            r3dh = rotate3d( figh );
            panh = pan( figh );
            oldState = '';
            if isequal( zoomh.Enable, 'on' )
                zoomh.Enable = 'off';
                oldState = 'zoom';
            end
            if isequal( r3dh.Enable, 'on' )
                r3dh.Enable = 'off';
                oldState = 'rotate3d';
            end
            if isequal( panh.Enable, 'on' )
                panh.Enable = 'off';
                oldState = 'pan';
            end
            
            
            % Now hook up new callbacks
            set( figh, ...
                'WindowButtonMotionFcn', @obj.onRowButtonMotion, ...
                'WindowButtonUpFcn', {@obj.onRowButtonUp, oldProps, oldState}, ...
                'Pointer', 'top', ...
                'Units', 'Pixels' );
            % Make the divider visible
            cdata = get( source, 'CData' );
            if mean( cdata(:) ) < 0.5
                % Make it brighter
                cdata = 1-0.5*(1-cdata);
                newCol = 1-0.5*(1-get( obj.UIContainer, 'BackgroundColor' ));
            else
                % Make it darker
                cdata = 0.5*cdata;
                newCol = 0.5*get( obj.UIContainer, 'BackgroundColor' );
            end
            set( source, ...
                'BackgroundColor', newCol, ...
                'ForegroundColor', newCol, ...
                'CData', cdata );
            
            obj.SelectedRowDivider = source;
        end % onRowButtonDown
        
        function onRowButtonMotion( obj, source, eventData ) %#ok<INUSD>
            figh = ancestor( source, 'figure' );
            cursorpos = get( figh, 'CurrentPoint' );
            dividerpos = get( obj.SelectedRowDivider, 'Position' );
            
            % We need to gaurd against the focus having been lost. In this
            % case we should have received a button-up event, but sometimes
            % don't (at least on Windows).
            if ishandle( obj.SelectedRowDivider )
                pos0 = getpixelposition( obj.UIContainer, true );
                dividerpos(2) = cursorpos(2) - pos0(2) - round(obj.Spacing/2) + 1;
                % Make sure that the position doesn't cause an element to
                % shrink too much
                minSizes = obj.MinimumRowSizes(:);
                pixSizes = uiextras.calculatePixelSizes( pos0(4), ...
                    obj.RowSizes, minSizes, obj.Padding, obj.Spacing );
                N = numel( minSizes );
                % Sometimes the actual width is smaller than the minimum!
                minSizes = min( minSizes, pixSizes );
                whichDivider = getappdata( obj.SelectedRowDivider, 'WhichDivider' );
                minPos = pos0(4) - ceil( obj.Padding ...
                    + sum( pixSizes(1:whichDivider-1) ) ...
                    + minSizes(whichDivider) ...
                    + obj.Spacing*(whichDivider-0.5) );
                dividerpos(2) = min( dividerpos(2), minPos );
                if whichDivider<(N-1)
                    maxPos = floor( obj.Padding ...
                        + sum( pixSizes(whichDivider+2:end) ) ...
                        + minSizes(whichDivider+1) ...
                        + obj.Spacing*(N-whichDivider-0.5) );
                else
                    % Final divider
                    maxPos = floor( obj.Padding ...
                        + minSizes(whichDivider+1) ...
                        + obj.Spacing*0.5 );
                end
                dividerpos(2) = max( dividerpos(2), maxPos );
                set( obj.SelectedRowDivider, 'Position', dividerpos );
            else
                % Divider has been lost, so we are in a bad state. The
                % best we can do is kill the callbacks and attempt to put
                % the figure back in a decent state.
                set( figh, 'Pointer', 'arrow', ...
                    'WindowButtonMotionFcn', [], ...
                    'WindowButtonUpFcn', [] );
            end
        end % onRowButtonMotion
        
        function onRowButtonUp( obj, source, eventData, oldFigProps, oldState )
            % Deliberately call the motion function to ensure any last
            % movement is captured
            obj.onRowButtonMotion( source, eventData );
            
            % Restore figure properties
            figh = ancestor( source, 'figure' );
            flds = fieldnames( oldFigProps );
            for ii=1:numel(flds)
                set( figh, flds{ii}, oldFigProps.(flds{ii}) );
            end
            
            % If the figure has an interaction mode set, re-set it now
            if ~isempty( oldState )
                switch upper( oldState )
                    case 'ZOOM'
                        zoom( figh, 'on' );
                    case 'PAN'
                        pan( figh, 'on' );
                    case 'ROTATE3D'
                        rotate3d( figh, 'on' );
                    otherwise
                        error( 'GUILayout:InvalidState', 'Invalid interaction mode ''%s''.', oldState );
                end
            end
            
            % Work out which divider was moved and which are the resizable
            % elements either side of it
            whichDivider = getappdata( obj.SelectedRowDivider, 'WhichDivider' );
            origPos = getappdata( obj.SelectedRowDivider, 'OriginalPosition' );
            newPos = get( obj.SelectedRowDivider, 'Position' );
            obj.SelectedRowDivider = -1;
            delta = newPos(2) - origPos(2) - round(obj.Spacing/2) + 1;
            sizes = obj.RowSizes;
            % Convert all flexible sizes into pixel units
            totalPosition = ceil( getpixelposition( obj.UIContainer ) );
            totalHeight = totalPosition(4);
            heights = uiextras.calculatePixelSizes( totalHeight, ...
                sizes, obj.MinimumRowSizes, obj.Padding, obj.Spacing );
            
            topelement = find( sizes(1:whichDivider)<0, 1, 'last' );
            bottomelement = find( sizes(whichDivider+1:end)<0, 1, 'first' )+whichDivider;
            
            % Now work out the new sizes. Note that we must ensure the size
            % stays negative otherwise it'll stop being resizable
            change = sum(sizes(sizes<0)) * delta / sum( heights(sizes<0) );
            sizes(topelement) = min( -0.000001, sizes(topelement) - change );
            sizes(bottomelement) = min( -0.000001, sizes(bottomelement) + change );
            
            % Setting the sizes will cause a redraw
            obj.RowSizes = sizes;
        end % onRowButtonUp
        
        function onColumnButtonDown( obj, source, eventData ) %#ok<INUSD>
            % Remove all row dividers
            figh = ancestor( source, 'figure' );
            ch = allchild( obj.UIContainer );
            dividers = strcmpi( get( ch, 'Tag' ), 'GridFlex:RowDivider' );
            delete( ch(dividers) );
            % We need to store any existing motion callbacks so that we can
            % restore them later.
            oldProps = struct();
            oldProps.WindowButtonMotionFcn = get( figh, 'WindowButtonMotionFcn' );
            oldProps.WindowButtonUpFcn = get( figh, 'WindowButtonUpFcn' );
            oldProps.Pointer = get( figh, 'Pointer' );
            oldProps.Units = get( figh, 'Units' );
            
            % Make sure all interaction modes are off to prevent our
            % callbacks being clobbered
            zoomh = zoom( figh );
            r3dh = rotate3d( figh );
            panh = pan( figh );
            oldState = '';
            if isequal( zoomh.Enable, 'on' )
                zoomh.Enable = 'off';
                oldState = 'zoom';
            end
            if isequal( r3dh.Enable, 'on' )
                r3dh.Enable = 'off';
                oldState = 'rotate3d';
            end
            if isequal( panh.Enable, 'on' )
                panh.Enable = 'off';
                oldState = 'pan';
            end
            
            % Now hook up new callbacks
            set( figh, ...
                'WindowButtonMotionFcn', @obj.onColumnButtonMotion, ...
                'WindowButtonUpFcn', {@obj.onColumnButtonUp, oldProps, oldState}, ...
                'Pointer', 'left', ...
                'Units', 'Pixels' );
            % Make the divider visible
            cdata = get( source, 'CData' );
            if mean( cdata(:) ) < 0.5
                % Make it brighter
                cdata = 1-0.5*(1-cdata);
                newCol = 1-0.5*(1-get( obj.UIContainer, 'BackgroundColor' ));
            else
                % Make it darker
                cdata = 0.5*cdata;
                newCol = 0.5*get( obj.UIContainer, 'BackgroundColor' );
            end
            set( source, ...
                'BackgroundColor', newCol, ...
                'ForegroundColor', newCol, ...
                'CData', cdata );
            obj.SelectedColumnDivider = source;
        end % onColumnButtonDown
        
        function onColumnButtonMotion( obj, source, eventData ) %#ok<INUSD>
            figh = ancestor( source, 'figure' );
            cursorpos = get( figh, 'CurrentPoint' );
            
            % We need to gaurd against the focus having been lost. In this
            % case we should have received a button-up event, but sometimes
            % don't (at least on Windows).
            if ishandle( obj.SelectedColumnDivider )
                dividerpos = get( obj.SelectedColumnDivider, 'Position' );
                pos0 = getpixelposition( obj.UIContainer, true );
                dividerpos(1) = cursorpos(1) - pos0(1) - round(obj.Spacing/2) + 1;
                                % Make sure that the position doesn't cause an element to
                % shrink too much
                minSizes = obj.MinimumColumnSizes(:);
                pixSizes = uiextras.calculatePixelSizes( pos0(3), ...
                    obj.ColumnSizes, minSizes, obj.Padding, obj.Spacing );

                N = numel( minSizes );
                % Sometimes the actual width is smaller than the minimum!
                minSizes = min( minSizes, pixSizes );
                whichDivider = getappdata( obj.SelectedColumnDivider, 'WhichDivider' );
                minPos = ceil( obj.Padding ...
                    + sum( pixSizes(1:whichDivider-1) ) ...
                    + minSizes(whichDivider) ...
                    + obj.Spacing*(whichDivider-0.5) );
                dividerpos(1) = max( dividerpos(1), minPos );
                if whichDivider<(N-1)
                    maxPos = pos0(3) - floor( obj.Padding ...
                        + sum( pixSizes(whichDivider+2:end) ) ...
                        + minSizes(whichDivider+1) ...
                        + obj.Spacing*(N-whichDivider-0.5) );
                else
                    % Final divider
                    maxPos = pos0(3) - floor( obj.Padding ...
                        + minSizes(whichDivider+1) ...
                        + obj.Spacing*0.5 );
                end
                dividerpos(1) = min( dividerpos(1), maxPos );

                set( obj.SelectedColumnDivider, 'Position', dividerpos );
            else
                % Divider has been lost, so we are in a bad state. The
                % best we can do is kill the callbacks and attempt to put
                % the figure back in a decent state.
                set( figh, 'Pointer', 'arrow', ...
                    'WindowButtonMotionFcn', [], ...
                    'WindowButtonUpFcn', [] );
            end
        end % onColumnButtonMotion
        
        function onColumnButtonUp( obj, source, eventData, oldFigProps, oldState )
            figh = ancestor( source, 'figure' );
            % Deliberately call the motion function to ensure any last
            % movement is captured
            obj.onColumnButtonMotion( source, eventData );
            
            % Restore figure properties
            flds = fieldnames( oldFigProps );
            for ii=1:numel(flds)
                set( figh, flds{ii}, oldFigProps.(flds{ii}) );
            end
            
            % If the figure has an interaction mode set, re-set it now
            if ~isempty( oldState )
                switch upper( oldState )
                    case 'ZOOM'
                        zoom( figh, 'on' );
                    case 'PAN'
                        zoom( figh, 'on' );
                    case 'ROTATE3D'
                        rotate3d( figh, 'on' );
                    otherwise
                        error( 'GUILayout:InvalidState', 'Invalid interaction mode ''%s''.', oldState );
                end
            end
            
            % Work out which divider was moved and which are the resizable
            % elements either side of it
            whichDivider = getappdata( obj.SelectedColumnDivider, 'WhichDivider' );
            origPos = getappdata( obj.SelectedColumnDivider, 'OriginalPosition' );
            newPos = get( obj.SelectedColumnDivider, 'Position' );
            obj.SelectedColumnDivider = -1;
            delta = newPos(1) - origPos(1) - round(obj.Spacing/2) + 1;
            sizes = obj.ColumnSizes;
            
            % Convert all flexible sizes into pixel units
            totalPosition = ceil( getpixelposition( obj.UIContainer ) );
            totalWidth = totalPosition(3);
            widths = uiextras.calculatePixelSizes( totalWidth, ...
                sizes, obj.MinimumColumnSizes, obj.Padding, obj.Spacing );
            
            leftelement = find( sizes(1:whichDivider)<0, 1, 'last' );
            rightelement = find( sizes(whichDivider+1:end)<0, 1, 'first' )+whichDivider;
            
            % Now work out the new sizes. Note that we must ensure the size
            % stays negative otherwise it'll stop being resizable
            change = sum(sizes(sizes<0)) * delta / sum( widths(sizes<0) );
            sizes(leftelement) = min( -0.000001, sizes(leftelement) + change );
            sizes(rightelement) = min( -0.000001, sizes(rightelement) - change );
            
            % Setting the sizes will cause a redraw
            obj.ColumnSizes = sizes;
        end % onColumnButtonUp
        
        function onBackgroundColorChanged( obj, source, eventData ) %#ok<INUSD>
            %onBackgroundColorChanged  Callback that fires when the container background color is changed
            %
            % We need to make the dividers match the background, so redarw
            % them
            obj.redraw();
        end % onChildRemoved
        
    end % protected methods
    
end % classdef