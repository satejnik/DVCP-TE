classdef Container < hgsetget
    %Container  Container base class
    %
    %   c = uiextras.Container() creates a new container object. Container
    %   is an abstract class and can only be constructed as the first
    %   actual of a descendent class.
    %
    %   c = uiextras.Container(param,value,...) creates a new container
    %   object and sets one or more property values.
    %
    %   See also: uiextras.Box
    %             uiextras.ButtonBox
    %             uiextras.CardPanel
    %             uiextras.Grid
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    
    properties
        DeleteFcn       % function to call when the layout is being deleted [function handle]
    end % Public properties
    
    properties( Dependent, Transient )
        BackgroundColor % background color [r g b]
        BeingDeleted    % is the object in the process of being deleted [on|off]
        Children        % list of the children of the layout [handle array]
        Enable          % allow interaction with the contents of this layout [on|off]
        Parent          % handle of the parent container or figure [handle]
        Position        % position [left bottom width height]
        Tag             % tag [string]
        Type            % the object type (class) [string]
        Units           % position units [inches|centimeters|normalized|points|pixels|characters]
        Visible         % is the layout visible on-screen [on|off]
    end % dependent properties
    
    % These properties are provided to aid migration to GLT2
    properties( Dependent, Hidden, Transient )
        Contents
    end % GLT2 compatibility properties
    
    properties( Access = protected, Hidden, Transient )
        Listeners = cell( 0, 1 ) % array of listeners
    end % protected properties
    
    properties( SetAccess = private, GetAccess = protected, Hidden, Transient )
        UIContainer % associated uicontainer
    end % read-only protected properties
    
    properties( Access = private, Hidden, Transient )
        Children_ = zeros( 0, 1 )     % private copy of the children list
        ChildListeners = cell( 0, 2 ) % listeners for changes to children
        Enable_ = 'on'                % private copy of the enabled state
        CurrentSize_ = [0 0]          % private copy of the size
    end % private properties
    
    methods
        
        function obj = Container( varargin )
            %Container  Container base class constructor
            %
            %   obj = Container(param,value,...) creates a new Container
            %   object using the (optional) property values specified. This
            %   may only be called by child classes.
            
            % Check that we're using the right graphics version
            if isHGUsingMATLABClasses()
                error( 'GUILayout:WrongHGVersion', 'Trying to run using double-handle MATLAB graphics against the new graphics system. Please re-install.' );
            end
            
            % Find if parent has been supplied
            parent = uiextras.findArg( 'Parent', varargin{:} );
            if isempty( parent )
                parent = gcf();
            end
            units = uiextras.findArg( 'Units', varargin{:} );
            if isempty( units )
                units = 'Normalized';
            end
            
            % Create container
            args = {
                'Parent', parent, ...
                'Units', units, ...
                'BorderType', 'none'
                };
            obj.UIContainer = uipanel( args{:} );
                        
            % Set the background color
            obj.setPropertyFromDefault( 'BackgroundColor' );
            
            % Tag it!
            set( obj.UIContainer, 'Tag', strrep( class( obj ), '.', ':' ) );
            
            % Create listeners to resizing of container
            containerObj = handle( obj.UIContainer );
            obj.Listeners{end+1,1} = handle.listener( containerObj, findprop( containerObj, 'PixelBounds' ), 'PropertyPostSet', @obj.onResized );
            
            % Create listeners to addition of container children
            obj.Listeners{end+1,1} = handle.listener( containerObj, 'ObjectChildAdded', @obj.onChildAddedEvent );
            
            % Watch out for the graphics being destroyed
            obj.Listeners{end+1,1} = handle.listener( containerObj, 'ObjectBeingDestroyed', @obj.onContainerBeingDestroyed );
            
            % Store Container in container
            setappdata( obj.UIContainer, 'Container', obj );

        end % constructor
        
        function container = double( obj )
            %double  Convert a container to an HG double handle.
            %
            %  D = double(C) converts a container C to an HG handle D.
            container = obj.UIContainer;
        end % double
        
        function pos = getpixelposition( obj )
            %getpixelposition  get the absolute pixel position
            %
            %   POS = GETPIXELPOSITION(C) gets the absolute position of the container C
            %   within its parent window. The returned position is in pixels.
            pos = getpixelposition( obj.UIContainer );
        end % getpixelposition
        
        function tf = isprop( obj, name )
            %isprop  does this object have the specified property
            %
            %   TF = ISPROP(C,NAME) checks whether the object C has a
            %   property named NAME. The result, TF, is true if the
            %   property exists, false otherwise.
            tf = ismember( name, properties( obj ) );
            
        end % isprop
        
        function p = ancestor(obj,varargin)
            %ancestor  Get object ancestor
            %
            %   P = ancestor(H,TYPE) returns the handle of the closest ancestor of h
            %   that matches one of the types in TYPE, or empty if there is no matching
            %   ancestor.  TYPE may be a single string (single type) or cell array of
            %   strings (types). If H is a vector of handles then P is a cell array the
            %   same length as H and P{n} is the ancestor of H(n). If H is one of the
            %   specified types then ancestor returns H.
            %
            %   P = ANCESTOR(H,TYPE,'TOPLEVEL') finds the highest level ancestor of one
            %   of the types in TYPE
            %
            %   If H is not an Handle Graphics object, ANCESTOR returns empty.
            p = ancestor( obj.UIContainer, varargin{:} );
        end %ancestor
        
        function setappdata( h, name, value )
            %setappdata  Set application-defined data. 
            %  setappdata(H, NAME, VALUE)
            if isa(h, 'uiextras.Container')
                h = h.UIContainer;
            end
            builtin( 'setappdata', h, name, value );
        end % setappdata
        
        function value = getappdata( h, name )
            %getappdata  Get value of application-defined data.
            %  VALUE = getappdata(H, NAME)
            if isa(h, 'uiextras.Container')
                h = h.UIContainer;
            end
            value = builtin( 'getappdata', h, name );
        end % getappdata
        
        function value = isappdata( h, name )
            %isappdata  True if application-defined data exists.
            %  isappdata(H, NAME)
            if isa(h, 'uiextras.Container')
                h = h.UIContainer;
            end
            value = builtin( 'isappdata', h, name );
        end % isappdata
        
        function rmappdata( h, name )
            %rmappdata  Remove application-defined data.
            %  rmappdata(H, NAME)
            if isa(h, 'uiextras.Container')
                h = h.UIContainer;
            end
            builtin( 'rmappdata', h, name );
        end % rmappdata
        
        function delete( obj )
            %delete  destroy this layout
            %
            % If the user destroys the object, we *must* also remove any
            % graphics
            if ~isempty( obj.DeleteFcn )
                uiextras.callCallback( obj.DeleteFcn, obj, [] );
            end
            if ishandle( obj.UIContainer ) ...
                    && ~strcmpi( get( obj.UIContainer, 'BeingDeleted' ), 'on' )
                delete( obj.UIContainer );
            end
        end % delete
        
    end % public methods
    
    methods
        
        function set.Position( obj, value )
            set( obj.UIContainer, 'Position', value );
        end % set.Position
        
        function value = get.Position( obj )
            value = get( obj.UIContainer, 'Position' );
        end % get.Position
        
        function set.Children( obj, value )
            % Check
            oldChildren = obj.Children_;
            newChildren = value;
            [tf, loc] = ismember( oldChildren, newChildren );
            if ~isequal( size( oldChildren ), size( newChildren ) ) || any( ~tf )
                error( 'GUILayout:Container:InvalidPropertyValue', ...
                    'Property ''Children'' may only be set to a permutation of itself.' )
            end
            
            % Set
            obj.Children_ = newChildren;
            
            % Reorder ChildListeners
            obj.ChildListeners(loc,:) = obj.ChildListeners;
            
            % Redraw
            obj.redraw();
        end % set.Children
        
        function value = get.Children( obj )
            value = obj.Children_;
        end % get.Children
        
        function set.Contents( obj, value )
            % Contents is just a GLT2 synonym for GLT1 "Children"
            obj.Children = value;
        end % set.Contents
        
        function value = get.Contents( obj )
            % Contents is just a GLT2 synonym for GLT1 "Children"
            value = obj.Children;
        end % get.Contents

        function set.Enable( obj, value )
            % Check
            if ~ischar( value ) || ~ismember( lower( value ), {'on','off'} )
                error( 'GUILayout:Container:InvalidPropertyValue', ...
                    'Property ''Enable'' may only be set to ''on'' or ''off''.' )
            end
            % Apply
            value = lower( value );
            % If we want to switch on but our parent is off, just store
            % in the app data.
            if strcmp( value, 'on' )
                if isappdata( obj.Parent, 'Container' )
                    parentObj = getappdata( obj.Parent, 'Container' );
                    if strcmpi( parentObj.Enable, 'off' )
                        setappdata( obj.UIContainer, 'OldEnableState', value );
                        value = 'off';
                    end
                end
            end
            obj.Enable_ = value;
            
            % Apply to children
            ch = obj.Children_;
            for ii=1:numel( ch )
                obj.helpSetChildEnable( ch(ii), obj.Enable_ );
            end
            
            % Do the work
            obj.onEnable( obj, value );
        end % set.Enable
        
        function value = get.Enable( obj )
            value = obj.Enable_;
        end % get.Enable
        
        function set.Units( obj, value )
            set( obj.UIContainer, 'Units', value );
        end % set.Units
        
        function value = get.Units( obj )
            value = get( obj.UIContainer, 'Units' );
        end % get.Units
        
        function set.Parent( obj, value )
            set( obj.UIContainer, 'Parent', double( value ) );
        end % set.Parent
        
        function value = get.Parent( obj )
            value = get( obj.UIContainer, 'Parent' );
        end % get.Parent
        
        function set.Tag( obj, value )
            set( obj.UIContainer, 'Tag', value );
        end % set.Tag
        
        function value = get.Tag( obj )
            value = get( obj.UIContainer, 'Tag' );
        end % get.Tag
        
        function value = get.Type( obj )
            value = class( obj );
        end % get.Type
        
        function value = get.BeingDeleted( obj )
            value = get( obj.UIContainer, 'BeingDeleted' );
        end % get.BeingDeleted
        
        function set.Visible( obj, value )
            set( obj.UIContainer, 'Visible', value );
        end % set.Visible
        
        function value = get.Visible( obj )
            value = get( obj.UIContainer, 'Visible' );
        end % get.Visible
        
        function set.BackgroundColor( obj, value )
            set( obj.UIContainer, 'BackgroundColor', value );
            obj.onBackgroundColorChanged( obj, value );
        end % set.BackgroundColor
        
        function value = get.BackgroundColor( obj )
            value = get( obj.UIContainer, 'BackgroundColor' );
        end % get.BackgroundColor
 
    end % accessor methods
    
    methods( Access = protected )
        
        function onResized( obj, source, eventData ) %#ok<INUSD>
            %onResized  Callback that fires when a container is resized.
            newSize = getpixelposition( obj );
            newSize = newSize([3,4]);
            if any(newSize ~= obj.CurrentSize_)
                % Size has changed, so must redraw
                obj.CurrentSize_ = newSize;
                obj.redraw();
            end
        end % onResized
        
        function onContainerBeingDestroyed( obj, source, eventData ) %#ok<INUSD>
            %onContainerBeingDestroyed  Callback that fires when the container dies
            delete( obj );
        end % onContainerBeingDestroyed
        
        function onChildAdded( obj, source, eventData ) %#ok<INUSD>
            %onChildAdded  Callback that fires when a child is added to a container.
            obj.redraw();
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData ) %#ok<INUSD>
            %onChildRemoved  Callback that fires when a container child is destroyed or reparented.
            obj.redraw();
        end % onChildRemoved
        
        function onBackgroundColorChanged( obj, source, eventData ) %#ok<INUSD>
            %onBackgroundColorChanged  Callback that fires when the container background color is changed
        end % onChildRemoved
        
        function onEnable( obj, source, eventData ) %#ok<INUSD>
            %onEnable  Callback that fires when the enable state is changed
        end % onChildRemoved
        
        function c = getValidChildren( obj )
            %getValidChildren  Return a list of only those children not being deleted
            c = obj.Children;
            c( strcmpi( get( c, 'BeingDeleted' ), 'on' ) ) = [];
        end % getValidChildren
        
        function repositionChild( obj, child, position ) %#ok<INUSL>
            %repositionChild  adjust the position and visibility of a child

            % First determine whether to use "Position" or "OuterPosition"
            if isprop( child, 'ActivePositionProperty' )
                propname = get( child, 'ActivePositionProperty' );
            else
                propname = 'Position';
            end
            if position(3)<=0 || position(4)<=0
                % Not enough space, so move offscreen instead
                position = [-10000 -10000 100 100];
            end
            % Now set the position in pixels, changing the units first if
            % necessary
            oldunits = get( child, 'Units' );
            if strcmpi( oldunits, 'Pixels' )
                set( child, propname, position );
            else
                % Other units, so switch to pixels before setting
                set( child, 'Units', 'pixels' );
                set( child, propname, position );
                set( child, 'Units', oldunits );
            end
        end % repositionChild
        
        function setPropertyFromDefault( obj, propName )
            %getPropertyDefault  Retrieve a default property value. If the
            %value is not found in the parent or any of its ancestors the
            %supplied defValue is used.
            error( nargchk( 2, 2, nargin ) ); %#ok<NCHKN>
            
            parent = get( obj.UIContainer, 'Parent' );
            myClass = class(obj);
            if strncmp( myClass, 'uiextras.', 9 )
                myClass = myClass(10:end);
            end
            defPropName = ['Default',myClass,propName];
            
            % Getting the default will fail if the default does not exist
            % of has an invalid value. In that case we leave the current
            % value as it is.
            try
                obj.(propName) = uiextras.get( parent, defPropName );
            catch err %#ok<NASGU>
                % Failed, so leave it alone
            end
        end % setPropertyFromDefault
        
        function helpSetChildEnable( ~, child, state )
            % Set the enabled state of one child widget
            
            % We need to take a great deal of care to preserve the old
            % enable state and to deal properly with children that are
            % layouts in their own right.
            if strcmpi( get( child, 'Type' ), 'uipanel' )
                % Might be another layout
                if isappdata( child, 'Container' )
                    child = getappdata( child, 'Container' );
                else
                    % Can't enable a panel
                    child = [];
                end
            elseif isprop( child, 'Enable' )
                % It supports enabling directly 
            else
                % Doesn't support enabling
                child = [];
            end
            
            if ~isempty( child )
            
            % We will use a piece of app data
            % to track the original state to ensure we don't
            % re-enable something that shouldn't be.
            if strcmpi( state, 'On' )
                if isappdata( child, 'OldEnableState' )
                    set( child, 'Enable', getappdata( child, 'OldEnableState' ) );
                    rmappdata( child, 'OldEnableState' );
                else
                    set( child, 'Enable', 'on' );
                end
            else
                if ~isappdata( child, 'OldEnableState' )
                    setappdata( child, 'OldEnableState', get( child, 'Enable' ) );
                end
                set( child, 'Enable', 'off' );
            end
            end
        end % helpSetChildEnable
        
    end % protected methods
    
    methods( Abstract = true, Access = protected )
        
        redraw( obj )
        
    end % abstract methods
    
    methods( Access = private, Sealed = true )
        
        function onChildAddedEvent( obj, source, eventData ) %#ok<INUSL>
            %onChildAddedEvent  Callback that fires when a child is added to a container.
            
            % Find child in Children
            child = eventData.Child;
            if ismember( double( child ), obj.Children_ )
                return % not *really* being added
            end
            
            % Only hook up internally if not a "hidden" child.
            if ~isprop( child, 'HandleVisibility' ) ...
                    || strcmpi( get( child, 'HandleVisibility' ), 'off' )
                return;
            end
            
            % We don't want to do anything to the panel title
            if isappdata( obj.UIContainer, 'PanelTitleCreate' ) ...
                    && getappdata( obj.UIContainer, 'PanelTitleCreate' )
                % This child is the panel label. Set its visibility off so
                % we don't see it again.
                set( child, 'HandleVisibility', 'off' );
                return;
            end
            
            % We also need to ignore legends as they are positioned by
            % their associated axes.
            if isLegendOrColorbar( eventData.Child )
                return;
            end
            
            % Add element to Children
            obj.Children_(end+1,:) = child;
            
            % Add elements to ChildListeners. A bug in R2009a and
            % earlier means we have to be careful about this
            if isBeforeR2009b()
                obj.ChildListeners(end+1,:) = ...
                    {handle.listener( child, 'ObjectBeingDestroyed', {@helpDeleteChild,obj} ), ...
                    handle.listener( child, 'ObjectParentChanged', {@helpReparentChild,obj} )};
            else
                obj.ChildListeners(end+1,:) = ...
                    {handle.listener( child, 'ObjectBeingDestroyed', @obj.onChildBeingDestroyedEvent ), ...
                    handle.listener( child, 'ObjectParentChanged', @obj.onChildParentChangedEvent )};
            end
            
            % We are taking over management of position and will do it
            % in either pixel or normalized units.
            units = lower( get( child, 'Units' ) );
            if ~ismember( units, {'pixels' ,'normalized'} )
                set( child, 'Units', 'Pixels' );
            end
            
            % If we are disabled, make sure the children are too
            if strcmpi( obj.Enable_, 'off' )
                helpSetChildEnable( obj, child, obj.Enable_ );
            end
            
            % Call onChildAdded
            eventData = uiextras.ChildEvent( child, numel( obj.Children_ ) );
            
            obj.onChildAdded( obj, eventData );
        end % onChildAddedEvent
        
        function onChildBeingDestroyedEvent( obj, source, eventData ) %#ok<INUSD>
            %onChildBeingDestroyedEvent  Callback that fires when a container child is destroyed.
            
            % Find child in Children
            [dummy, loc] = ismember( double( source ), obj.Children_ ); %#ok<ASGLU>
            
            % Remove element from Children
            obj.Children_(loc,:) = [];
            
            % Remove elements from ChildListeners
            obj.ChildListeners(loc,:) = [];
            
            % If we are in our death throes, don't start calling callbacks
            if ishandle( obj.UIContainer ) && ~strcmpi( get( obj.UIContainer, 'BeingDeleted' ), 'ON' )
                % Call onChildRemoved
                eventData = uiextras.ChildEvent( source, loc );
                obj.onChildRemoved( obj, eventData );
            end
            
        end % onChildBeingDestroyedEvent
        
        function onChildParentChangedEvent( obj, source, eventData )
            %onChildParentChangedEvent  Callback that fires when a container child is reparented.
            
            if isempty( eventData.NewParent ) ...
                    || eventData.NewParent == obj.UIContainer
                return % not being reparented *away*
            end
            
            % Find child in Children
            [dummy, loc] = ismember( double( source ), obj.Children_ ); %#ok<ASGLU>
            
            % Remove element from Children
            obj.Children_(loc,:) = [];
            
            % Remove elements from ChildListeners
            obj.ChildListeners(loc,:) = [];
            
            % Call onChildRemoved
            eventData = uiextras.ChildEvent( source, loc );
            obj.onChildRemoved( obj, eventData );
            
        end % onChildParentChangedEvent
        
    end % private sealed methods
    
end % classdef

% -------------------------------------------------------------------------

function result = isLegendOrColorbar( child )
% Determine whether an object is a legend or colorbar
tag = lower(get( child, 'Tag' ));
result = (isa( child, 'axes' ) && ismember(tag, {'legend', 'colorbar'}) );
end % isLegendOrColorbar


% Helper functions to work around a bug in R2009a and earlier

function ok = isBeforeR2009b()
persistent matlabVersionDate;
if isempty( matlabVersionDate )
    v = ver( 'MATLAB' );
    matlabVersionDate = datenum( v.Date );
%     uiwait( msgbox( sprintf( 'Got MATLAB version date: %s', v.Date ) ) )
end
ok = ( matlabVersionDate <= datenum( '15-Jan-2009', 'dd-mmm-yyyy' ) );
end

function helpDeleteChild( src, evt, obj )
obj.onChildBeingDestroyedEvent( src, evt );
end % helpDeleteChild

function helpReparentChild( src, evt, obj )
obj.onChildParentChangedEvent( src, evt );
end % helpReparentChild
