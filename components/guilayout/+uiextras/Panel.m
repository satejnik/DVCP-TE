classdef Panel < uiextras.CardPanel & uiextras.DecoratedPanel
    %Panel  Show one element inside a panel
    %
    %   obj = uiextras.Panel() creates a standard UIPANEL object but with
    %   automatic management of the contained widget or layout. The
    %   properties available are largely the same as the builtin UIPANEL
    %   object. Where more than one child is added, the currently visible
    %   child is determined using the SelectedChild property.
    %
    %   obj = uiextras.Panel(param,value,...) also sets one or more
    %   property values.
    %
    %   See the <a href="matlab:doc uiextras.Panel">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> p = uiextras.Panel( 'Parent', f, 'Title', 'A Panel', 'Padding', 5 );
    %   >> uicontrol( 'Parent', p, 'Background', 'r' )
    %
    %   >> f = figure();
    %   >> p = uiextras.Panel( 'Parent', f, 'Title', 'A Panel', 'Padding', 5 );
    %   >> b = uiextras.HBox( 'Parent', p, 'Spacing', 5 );
    %   >> uicontrol( 'Style', 'listbox', 'Parent', b, 'String', {'Item 1','Item 2'} );
    %   >> uicontrol( 'Parent', b, 'Background', 'b' );
    %   >> set( b, 'Sizes', [100 -1] );
    %
    %   See also: uipanel
    %             uiextras.BoxPanel
    %             uiextras.HBox
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 373 $
    %   $Date: 2011-07-14 13:24:10 +0100 (Thu, 14 Jul 2011) $
    
    properties( Dependent = true )
        BorderType      % Type of border around the uipanel area  [none|etchedin|etchedout|beveledin|beveledout|line]
        BorderWidth     % Width of the panel border
        Title           % Title string
        TitlePosition   % Location of title string in relation to the panel [lefttop|centertop|righttop|leftbottom|centerbottom|rightbottom]
    end % dependent properties
    
    methods
        
        function obj = Panel( varargin )
            %PANEL constructor
            
            % First step is to create the parent class. We pass the
            % arguments (if any) just incase the parent needs setting
            obj = obj@uiextras.CardPanel( varargin{:} );
            obj = obj@uiextras.DecoratedPanel( varargin{:} );
            
            set( obj.UIContainer, 'Title', '' );
            
            % Override base settings
            obj.BorderType = 'etchedin';
            obj.BorderWidth = 1;
            obj.TitlePosition = 'lefttop';
            
            % See if the user has set any defaults
            obj.setPropertyFromDefault( 'BorderType' );
            obj.setPropertyFromDefault( 'BorderWidth' );
            obj.setPropertyFromDefault( 'TitlePosition' );
            
            % Set user-supplied property values
            if nargin > 0
                set( obj, varargin{:} );
            end
        end % Panel
        
    end % public methods
    
    methods
        
        function value = get.BorderType( obj )
            value = get( obj.UIContainer, 'BorderType' );
        end % get.BorderType
        
        function set.BorderType( obj, value )
            set( obj.UIContainer, 'BorderType', value );
        end % set.BorderType
        
        function value = get.BorderWidth( obj )
            value = get( obj.UIContainer, 'BorderWidth' );
        end % get.BorderWidth
        
        function set.BorderWidth( obj, value )
            set( obj.UIContainer, 'BorderWidth', value );
            obj.redraw();
        end % set.BorderWidth
        
        function value = get.Title( obj )
            value = get( obj.UIContainer, 'Title' );
        end % get.Title
        
        function set.Title( obj, value )
            % Only need to redraw if changing to/from empty
            oldValue = get( obj.UIContainer, 'Title' );
            % Unfortunately setting the title creates a uicontrol that
            % isn't tagged, so we have to set a flag so that we know to
            % ignore it for resize purposes
            setappdata( obj.UIContainer, 'PanelTitleCreate', true );
            set( obj.UIContainer, 'Title', value );
            rmappdata( obj.UIContainer, 'PanelTitleCreate' );
            if isempty( value ) && ~isempty( oldValue )
                obj.redraw();
            elseif isempty( oldValue ) && ~isempty( value )
                obj.redraw();
            end
        end % set.Title
        
        function value = get.TitlePosition( obj )
            value = get( obj.UIContainer, 'TitlePosition' );
        end % get.TitlePosition
        
        function set.TitlePosition( obj, value )
            set( obj.UIContainer, 'TitlePosition', value );
            obj.redraw();
        end % set.TitlePosition
        
    end % accessor methods
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw the layout, positioning the children
            
            if isempty( obj.UIContainer ) || ~ishandle( obj.UIContainer )
                return
            end
            
            % The selected one inherits the visibility of the layout and
            % fills the available space
            oldUnits = obj.Units;
            obj.Units = 'Pixels';
            pos = getpixelposition( obj );
            border = obj.BorderWidth+1+obj.Padding;
            x0 = border;
            y0 = border;
            w = pos(3) - 2*border;
            h = pos(4) - 2*border;
            if ~isempty( obj.Title )
                % Work out how much extra space to leave for the title
                oldFontUnits = get( obj.UIContainer, 'FontUnits' );
                set( obj.UIContainer, 'FontUnits', 'Pixels' );
                % Get the height of the title (in pixels)
                titleSize = get( obj.UIContainer, 'FontSize' );
                % Put the old units back
                set( obj.UIContainer, 'FontUnits', oldFontUnits );
                
                % Whether to move top or bottom depends on title
                % position
                if isempty( strfind( get( obj.UIContainer, 'TitlePosition' ), 'top' ) )
                    % Title at the bottom
                    h = h - titleSize;
                    y0 = y0 + titleSize;
                else
                    % Title at the top
                    h = h - titleSize;
                end
                
            end
            % Use the CardLayout function to put the right child onscreen
            obj.showSelectedChild( [x0 y0 w h] );
            obj.Units = oldUnits;
        end % redraw
        
        function onChildAdded( obj, source, eventData ) %#ok<INUSD>
            %onChildAdded: Callback that fires when a child is added to a container.
            % Select the new addition
            obj.SelectedChild = numel( obj.Children );
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData ) %#ok<INUSL>
            %onChildAdded: Callback that fires when a container child is destroyed or reparented.
            % If the missing child is the selected one, select something else
            if eventData.ChildIndex == obj.SelectedChild
                if isempty( obj.Children )
                    obj.SelectedChild = [];
                else
                    obj.SelectedChild = max( 1, obj.SelectedChild - 1 );
                end
            end
        end % onChildRemoved
        
        function onEnable( obj, source, eventData ) %#ok<INUSD>
            %onEnable  Callback that fires when the enable state is changed
            t = findall( obj.UIContainer, ...
                'Type', 'uicontrol', ...
                'HandleVisibility', 'off', ...
                'Parent', obj.UIContainer );
            set( t, 'Enable', obj.Enable );
        end % onChildRemoved
        
        function onBackgroundColorChanged( obj, source, eventData ) %#ok<INUSL>
            %onBackgroundColorChanged  Callback that fires when the container background color is changed
            %
            % We need to make the panel match the container background
            set( obj.UIContainer, 'BackgroundColor', eventData );
        end % onChildRemoved
        
        function onPanelColorChanged( obj, source, eventData ) %#ok<INUSL>
            % Colors have changed. This shouldn't require a redraw.
            set( obj.UIContainer, eventData.Property, eventData.Value );
        end % onPanelColorChanged
        
        function onPanelFontChanged( obj, source, eventData ) %#ok<INUSL>
            % Font has changed. Since the font size and shape affects the
            % space available for the contents, we need to redraw.
            set( obj.UIContainer, eventData.Property, eventData.Value );
            obj.redraw();
        end % onPanelFontChanged
        
    end % protected methods
    
end % classdef