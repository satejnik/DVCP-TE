classdef ButtonBox < uiextras.Container
    %ButtonBox  Abstract parent for button box classes
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 300 $
    %   $Date: 2010-07-22 16:33:47 +0100 (Thu, 22 Jul 2010) $
    
    properties( SetObservable = true )
        ButtonSize = [100 25]          % Desired size for all buttons [width height]
        HorizontalAlignment = 'center' % Horizonral alignment of buttons [left|center|right]
        VerticalAlignment = 'middle'   % Vertical alignment of buttons [top|middle|bottom]
        Spacing = 5                    % spacing between contents (pixels)
        Padding = 0                    % spacing around all contents
    end % public properties
    
    methods
        
        function obj = ButtonBox( varargin )
            %ButtonBox  Container with contents in a single row or column
            
            
            % First step is to create the parent class. We pass the
            % arguments (if any) just incase the parent needs setting
            obj@uiextras.Container( varargin{:} );
                        
            % Set some defaults
            obj.setPropertyFromDefault( 'ButtonSize' );
            obj.setPropertyFromDefault( 'HorizontalAlignment' );
            obj.setPropertyFromDefault( 'VerticalAlignment' );
            obj.setPropertyFromDefault( 'Spacing' );
            obj.setPropertyFromDefault( 'Padding' );

        end % constructor
        
        function set.ButtonSize( obj, value )
            % Check
            if ~isnumeric( value ) || numel( value )~= 2 ...
                    || any( ~isreal( value ) ) || any( isnan( value ) ) ...
                    || any( ~isfinite( value ) ) || any( value <= 0 )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''ButtonSize'' must consist of two positive integers.' )
            end
            
            % Set & redraw
            obj.ButtonSize = value;
            obj.redraw();
        end % set.Sizes
        
        function set.Padding( obj, value )
            % Check
            if ~isnumeric( value ) || ~isscalar( value ) || ...
                    ~isreal( value ) || isnan( value ) || ~isfinite( value ) || ...
                    value < 0 || rem( value, 1 ) ~= 0
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''Padding'' must be a nonnegative integer.' )
            end
            
            % Set and redraw
            obj.Padding = value;
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
            
            % Set and redraw
            obj.Spacing = value;
            obj.redraw();
        end % set.Spacing
        
        function set.HorizontalAlignment( obj, value )
            if ~ischar( value ) || ~any( strcmpi( value, {'left','center','right'} ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''HorizontalAlignment'' must be a one of ''left'',''center'',''right''.' );
            end
            obj.HorizontalAlignment = value;
            obj.redraw();
        end % set.HorizontalAlignment
        
        function set.VerticalAlignment( obj, value )
            if ~ischar( value ) || ~any( strcmpi( value, {'top','middle','bottom'} ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''HorizontalAlignment'' must be a one of ''top'',''middle'',''bottom''.' );
            end
            obj.VerticalAlignment = value;
            obj.redraw();
        end % set.VerticalAlignment
        
    end % public methods
    
end % classdef