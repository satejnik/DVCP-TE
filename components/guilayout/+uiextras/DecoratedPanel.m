classdef DecoratedPanel < handle
    %DecoratedPanel  Abstract panel class that manages fonts and colors
    %
    %   See also: uiextras.Panel
    %             uiextras.BoxPanel
    %             uiextras.TabPanel
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 301 $
    %   $Date: 2010-07-22 16:40:01 +0100 (Thu, 22 Jul 2010) $
    
    properties( SetObservable = true ) % should also have 'AbortSet' but this is only available on later releases
        FontAngle       % Title font angle [normal|italic|oblique]
        FontName        % Title font name
        FontSize        % Title font size
        FontUnits       % Title font units [inches|centimeters|normalized|points|pixels]
        FontWeight      % Title font weight [light|normal|demi|bold]
        ForegroundColor % Title font color and/or color of 2-D border line
        HighlightColor  % 3-D frame highlight color [r g b]
        ShadowColor     % 3-D frame shadow color [r g b]
    end % public properties
    
    properties( Constant, GetAccess = private )
        AllowedFontAngle = set( 0, 'DefaultUIPanelFontAngle' )
        AllowedFontName = listfonts(0)
        AllowedFontUnits = set( 0, 'DefaultUIPanelFontUnits' )
        AllowedFontWeight = set( 0, 'DefaultUIPanelFontWeight' )
    end % private constant properties
    
    methods
        
        function obj = DecoratedPanel( varargin )
            % Find the parent figure
            parent = uiextras.findArg( 'Parent', varargin{:} );
            if isempty( parent )
                parent = gcf();
            elseif isa( parent, 'uiextras.Container' )
                parent = double( parent );
            end
            % Set some defaults
            obj.setPropertyFromDefaultOrHG( parent, 'FontAngle' );
            obj.setPropertyFromDefaultOrHG( parent, 'FontName' );
            obj.setPropertyFromDefaultOrHG( parent, 'FontSize' );
            obj.setPropertyFromDefaultOrHG( parent, 'FontUnits' );
            obj.setPropertyFromDefaultOrHG( parent, 'FontWeight' );
            obj.setPropertyFromDefaultOrHG( parent, 'ForegroundColor' );
            obj.setPropertyFromDefaultOrHG( parent, 'HighlightColor' );
            obj.setPropertyFromDefaultOrHG( parent, 'ShadowColor' );
        end % DecoratedPanel
        
    end % public methods
    
    methods
        
        function set.FontAngle( obj, value )
            idx = find( strcmpi( value, obj.AllowedFontAngle ) );
            if isempty( idx )
                list = sprintf( '%s, ', obj.AllowedFontAngle{:} );
                list(end-1:end) = [];
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''FontAngle'' must be one of: %s.', list );
            else
                obj.FontAngle = obj.AllowedFontAngle{idx};
                eventData = struct( ...
                    'Property', 'FontAngle', ...
                    'Value', obj.FontAngle );
                obj.onPanelFontChanged( obj, eventData );
            end
        end % set.FontAngle
        
        function set.FontName( obj, value )
            idx = find( strcmpi( value, obj.AllowedFontName ) );
            if isempty( idx )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''FontName'' must be a valid font name.  See also ''listfonts''.' );
            else
                obj.FontName = obj.AllowedFontName{idx};
                eventData = struct( ...
                    'Property', 'FontName', ...
                    'Value', obj.FontName );
                obj.onPanelFontChanged( obj, eventData );
            end
        end % set.FontName
        
        function set.FontSize( obj, value )
            obj.FontSize = value;
            eventData = struct( ...
                'Property', 'FontSize', ...
                'Value', value );
            obj.onPanelFontChanged( obj, eventData );
        end % set.FontSize
        
        function set.FontUnits( obj, value )
            idx = find( strcmpi( value, obj.AllowedFontUnits ) );
            if isempty( idx )
                list = sprintf( '%s, ', obj.AllowedFontUnits{:} ); 
                list(end-1:end) = [];
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''FontUnits'' must be one of: %s.', list );
            else
                obj.FontUnits = obj.AllowedFontUnits{idx};
                eventData = struct( ...
                    'Property', 'FontUnits', ...
                    'Value', obj.FontUnits );
                obj.onPanelFontChanged( obj, eventData );
            end
        end % set.FontUnits
        
        function set.FontWeight( obj, value )
            idx = find( strcmpi( value, obj.AllowedFontWeight ) );
            if isempty( idx )
                list = sprintf( '%s, ', obj.AllowedFontWeight{:} );
                list(end-1:end) = [];
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''FontWeight'' must be one of: %s.', list );
            else
                obj.FontWeight = obj.AllowedFontWeight{idx};
                eventData = struct( ...
                    'Property', 'FontWeight', ...
                    'Value', obj.FontWeight );
                obj.onPanelFontChanged( obj, eventData );
            end
        end % set.FontWeight
        
        function set.ForegroundColor( obj, value )
            obj.ForegroundColor = uiextras.interpretColor( value );
            eventData = struct( ...
                'Property', 'ForegroundColor', ...
                'Value', obj.ForegroundColor );
            obj.onPanelColorChanged( obj, eventData );
        end % set.ForegroundColor
        
        function set.HighlightColor( obj, value )
            obj.HighlightColor = uiextras.interpretColor( value );
            eventData = struct( ...
                'Property', 'HighlightColor', ...
                'Value', obj.HighlightColor );
            obj.onPanelColorChanged( obj, eventData );
        end % set.HighlightColor
        
        function set.ShadowColor( obj, value )
            obj.ShadowColor = uiextras.interpretColor( value );
            eventData = struct( ...
                'Property', 'ShadowColor', ...
                'Value', obj.ShadowColor );
            obj.onPanelColorChanged( obj, eventData );
        end % set.ShadowColor
        
    end % accessor methods
    
    methods ( Abstract = true, Access = protected )
        onPanelColorChanged( obj, source, eventData );
        onPanelFontChanged( obj, source, eventData );
    end % abstract protected methods
    
    methods ( Access = private )
        
        function setPropertyFromDefaultOrHG( obj, parent, propName )
            %setPropertyDefault  Retrieve a default property value. If the
            %value is not found in the parent or any of its ancestors the
            %default UIPanel equivalent in 'parent' is used
            error( nargchk( 3, 3, nargin ) );
            
            myClass = class( obj );
            if strncmp( myClass, 'uiextras.', 9 )
                myClass = myClass(10:end);
            end
            defPropName = ['Default',myClass,propName];
            try
                obj.(propName) = uiextras.get( parent, defPropName );
            catch err %#ok<NASGU>
                % Go up the HG tree instead
                hgPropName = ['DefaultUIPanel',propName];
                % We can't test for default properties, so just try it
                try
                    obj.(propName) = get( parent, hgPropName );
                catch err %#ok<NASGU>
                    found = false;
                    while ~found && ~isequal( parent, 0 )
                        parent = get( parent, 'Parent' );
                        try %#ok<TRYNC>
                            obj.(propName) = get( parent, hgPropName );
                            found = true;
                        end
                    end
                end
            end
        end % setPropertyFromDefaultOrHG
        
    end % private methods
    
end % classdef