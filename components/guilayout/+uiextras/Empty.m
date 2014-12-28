classdef Empty < hgsetget
    %Empty  Create an empty space
    %
    %   obj = uiextras.Empty() creates an empty space object that can be
    %   used in layouts to add gaps between other elements.
    %
    %   obj = uiextras.Empty(param,value,...) also sets one or more
    %   property values.
    %
    %   See the <a href="matlab:doc uiextras.Empty">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> box = uiextras.HBox( 'Parent', f );
    %   >> uicontrol( 'Parent', box, 'Background', 'r' )
    %   >> uiextras.Empty( 'Parent', box )
    %   >> uicontrol( 'Parent', box, 'Background', 'b' )
    %
    %   See also: uiextras.HBox
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 287 $
    %   $Date: 2010-07-14 12:21:33 +0100 (Wed, 14 Jul 2010) $
    
    
    
    properties( Dependent = true, Transient = true )
        BackgroundColor  % background color [r g b]
        Parent           % parent [handle]
        Position         % position [left bottom width height]
        Tag              % tag [string]
        Type             % type [string]
        Units            % units [inches|centimeters|normalized|points|pixels|characters]
        Visible          % visible [on|off]
    end % dependent properties
    
    properties( SetAccess = private, GetAccess = private )
        UIControl = -1
    end % private properties
    
    methods
        
        function obj = Empty( varargin )
            %Empty  Construct a new empty widget
            
            % Find if parent has been supplied
            parent = uiextras.findArg( 'Parent', varargin{:} );
            if isempty( parent )
                parent = gcf();
            end
            
            % Find the default background color to use
            color = get( ancestor(parent,'figure'), 'DefaultUIControlBackgroundColor' );
            % Create the widget
            obj.UIControl = uicontrol( ...
                'Parent', parent, ...
                'Style', 'frame', ...
                'ForegroundColor', color, ...
                'BackgroundColor', color, ...
                'Tag', class( obj ), ...
                'HitTest', 'off' );
            
            if nargin
                set( obj, varargin{:} );
            end
            
            % Store it in the Control to prevent it going out of scope
            setappdata( obj.UIControl, 'Control', obj );
        end % constructor
        
        function control = double( obj )
            %double  Convert to an HG double handle.
            %
            %  d = double(e) converts empty widget e to an HG handle d.
            control = obj.UIControl;
        end % double
        
        function delete( obj )
            %delete  Destroy this object (and associated graphics)
            if ishandle( obj.UIControl )
                delete( obj.UIControl );
            end
        end % delete
        
    end % public methods
    
    methods
        
        function set.Position( obj, value )
            set( obj.UIControl, 'Position', value );
        end % set.Position
        
        function value = get.Position( obj )
            value = get( obj.UIControl, 'Position' );
        end % get.Position
        
        function set.BackgroundColor( obj, value )
            set( obj.UIControl, 'BackgroundColor', value );
            set( obj.UIControl, 'ForegroundColor', value );
        end % set.BackgroundColor
        
        function value = get.BackgroundColor( obj )
            value = get( obj.UIControl, 'BackgroundColor' );
        end % get.BackgroundColor
        
        function set.Units( obj, value )
            set( obj.UIControl, 'Units', value );
        end % set.Units
        
        function value = get.Units( obj )
            value = get( obj.UIControl, 'Units' );
        end % get.Units
        
        function set.Parent( obj, value )
            set( obj.UIControl, 'Parent', double( value ) );
        end % set.Parent
        
        function value = get.Parent( obj )
            value = get( obj.UIControl, 'Parent' );
        end % get.Parent
        
        function set.Visible( obj, value )
            set( obj.UIControl, 'Visible', value );
        end % set.Visible
        
        function value = get.Visible( obj )
            value = get( obj.UIControl, 'Visible' );
        end % get.Visible
        
        function set.Tag( obj, value )
            set( obj.UIControl, 'Tag', value );
        end % set.Tag
        
        function value = get.Tag( obj )
            value = get( obj.UIControl, 'Tag' );
        end % get.Tag
        
        function value = get.Type( obj )
            value = class( obj );
        end % get.Type
        
    end % accessor methods
    
end % classdef