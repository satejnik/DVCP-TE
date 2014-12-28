classdef HBoxFlex < uiextras.HBox
    %HBoxFlex  A dynamically resizable horizontal layout
    %
    %   obj = uiextras.HBoxFlex() creates a new dynamically resizable
    %   horizontal box layout with all parameters set to defaults. The
    %   output is a new layout object that can be used as the parent for
    %   other user-interface components.
    %
    %   obj = uiextras.HBoxFlex(param,value,...) also sets one or more
    %   parameter values.
    %
    %   See the <a href="matlab:doc uiextras.HBoxFlex">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure( 'Name', 'uiextras.HBoxFlex example' );
    %   >> b = uiextras.HBoxFlex( 'Parent', f );
    %   >> uicontrol( 'Parent', b, 'Background', 'r' )
    %   >> uicontrol( 'Parent', b, 'Background', 'b' )
    %   >> uicontrol( 'Parent', b, 'Background', 'g' )
    %   >> uicontrol( 'Parent', b, 'Background', 'y' )
    %   >> set( b, 'Sizes', [-1 100 -2 -1], 'Spacing', 5 );
    %
    %   See also: uiextras.VBoxFlex
    %             uiextras.HBox
    %             uiextras.Grid
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 366 $
    %   $Date: 2011-02-10 15:48:11 +0000 (Thu, 10 Feb 2011) $
    
    properties
        ShowMarkings = 'on'  % Show markings on the draggable dividers [ on | off ]
    end % public methods
    
    properties (Access=private)
        Dividers = []
        SelectedDivider = -1
    end % private properties
    
    methods
        
        function obj = HBoxFlex( varargin )
            % First step is to create the parent class. We pass the
            % arguments (if any) just incase the parent needs setting
            obj@uiextras.HBox( varargin{:} );
            
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
                error( 'GUILayout:HBoxFlex:InvalidPropertyValue', ...
                    'Property ''ShowMarkings'' may only be set to ''on'' or ''off''.' )
            end
            % Apply
            obj.ShowMarkings = lower( value );
            obj.redraw();
        end % set.ShowMarkings
    end % accessor methods
    
    methods( Access = protected )
        
        function redraw( obj )
            %REDRAW  Redraw container contents.
            
            % First call the grid redraw
            [widths,heights] = redraw@uiextras.HBox(obj);
            sizes = obj.Sizes;
            children = obj.getValidChildren();
            nChildren = numel( children );
            padding = obj.Padding;
            spacing = obj.Spacing;
            
            % Now also add/update some dividers
            mph = uiextras.MousePointerHandler( obj.Parent );
            numDynamic = 0;
            for ii = 1:nChildren-1
                if any(sizes(1:ii)<0) && any(sizes(ii+1:end)<0)
                    numDynamic = numDynamic + 1;
                    % Both dynamic, so add a divider
                    position = [sum( widths(1:ii) ) + padding + spacing * (ii-1) + 1, ...
                        padding + 1, ...
                        max(1,spacing), ...
                        heights(ii)];
                    % Create the divider widget
                    if numDynamic > numel( obj.Dividers )
                        obj.Dividers(numDynamic) = uiextras.makeFlexDivider( ...
                            obj.UIContainer, ...
                            position, ...
                            get( obj.UIContainer, 'BackgroundColor' ), ...
                            'Vertical', ...
                            obj.ShowMarkings );
                        set( obj.Dividers(numDynamic), 'ButtonDownFcn', @obj.onButtonDown, ...
                            'Tag', 'UIExtras:HBoxFlex:Divider' );
                        % Add it to the mouse-over handler
                        mph.register( obj.Dividers(numDynamic), 'left' );
                    else
                        % Just update an existing divider
                        uiextras.makeFlexDivider( ...
                            obj.Dividers(numDynamic), ...
                            position, ...
                            get( obj.UIContainer, 'BackgroundColor' ), ...
                            'Vertical', ...
                            obj.ShowMarkings );
                    end
                    setappdata( obj.Dividers(numDynamic), 'WhichDivider', ii );
                end
            end
            % Remove any excess dividers
            if numel( obj.Dividers ) > numDynamic
                delete( obj.Dividers(numDynamic+1:end) );
                obj.Dividers(numDynamic+1:end) = [];
            end
        end % redraw
        
        function onButtonDown( obj, source, eventData ) %#ok<INUSD>
            figh = ancestor( source, 'figure' );
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
            
            % Now set the new callbacks
            set( figh, ...
                'WindowButtonMotionFcn', @obj.onButtonMotion, ...
                'WindowButtonUpFcn', {@obj.onButtonUp, oldProps, oldState}, ...
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
            obj.SelectedDivider = source;
        end % onButtonDown
        
        function onButtonMotion( obj, source, eventData ) %#ok<INUSD>
            % First capture the current cursor position
            figh = ancestor( source, 'figure' );
            cursorpos = get( figh, 'CurrentPoint' );
            pos0 = getpixelposition( obj.UIContainer, true );
            
            % We need to gaurd against the focus having been lost. In this
            % case we should have received a button-up event, but sometimes
            % don't (at least on Windows).
            if ishandle( obj.SelectedDivider )
                % All OK, so move it
                dividerpos = get( obj.SelectedDivider, 'Position' );
                dividerpos(1) = cursorpos(1) - pos0(1) - round(obj.Spacing/2) + 1;
                
                % Make sure that the position doesn't cause an element to
                % shrink too much
                minSizes = obj.MinimumSizes(:);
                pixSizes = uiextras.calculatePixelSizes( pos0(3), ...
                    obj.Sizes, minSizes, obj.Padding, obj.Spacing );

                N = numel( minSizes );
                % Sometimes the actual width is smaller than the minimum!
                minSizes = min( minSizes, pixSizes );
                whichDivider = getappdata( obj.SelectedDivider, 'WhichDivider' );
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
                set( obj.SelectedDivider, 'Position', dividerpos );
            else
                % Divider has been lost, so we are in a bad state. The
                % best we can do is kill the callbacks and attempt to put
                % the figure back in a decent state.
                set( figh, 'Pointer', 'arrow', ...
                    'WindowButtonMotionFcn', [], ...
                    'WindowButtonUpFcn', [] );
            end
        end % onButtonMotion
        
        function onButtonUp( obj, source, eventData, oldFigProps, oldState )
            % Deliberately call the motion function to ensure any last
            % movement is captured
            obj.onButtonMotion( source, eventData );
            
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
            newPos = get( obj.SelectedDivider, 'Position' );
            origPos = getappdata( obj.SelectedDivider, 'OriginalPosition' );
            whichDivider = getappdata( obj.SelectedDivider, 'WhichDivider' );
            obj.SelectedDivider = -1;
            delta = newPos(1) - origPos(1) - round(obj.Spacing/2) + 1;
            sizes = obj.Sizes;
            
            % Convert all flexible sizes into pixel units
            totalPosition = ceil( getpixelposition( obj.UIContainer ) );
            totalWidth = totalPosition(3);
            pixSizes = uiextras.calculatePixelSizes( totalWidth, ...
                    obj.Sizes, obj.MinimumSizes, obj.Padding, obj.Spacing );
            
            leftelement = find( sizes(1:whichDivider)<0, 1, 'last' );
            rightelement = find( sizes(whichDivider+1:end)<0, 1, 'first' )+whichDivider;
            
            % Now work out the new sizes. Note that we must ensure the size
            % stays negative otherwise it'll stop being resizable
            change = sum(sizes(sizes<0)) * delta / sum( pixSizes(sizes<0) );
            sizes(leftelement) = min( -0.000001, sizes(leftelement) + change );
            sizes(rightelement) = min( -0.000001, sizes(rightelement) - change );
            
            % Setting the sizes will cause a redraw
            obj.Sizes = sizes;
        end % onButtonUp
        
        function onBackgroundColorChanged( obj, source, eventData ) %#ok<INUSD>
            %onBackgroundColorChanged  Callback that fires when the container background color is changed
            %
            % We need to make the dividers match the background, so redarw
            % them
            obj.redraw();
        end % onChildRemoved
        
    end % protected methods
    
end % classdef