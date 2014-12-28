classdef Box < uiextras.Container
    %Box  Box base class
    %
    %   See also: uiextras.HBox
    %             uiextras.VBox
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 366 $
    %   $Date: 2011-02-10 15:48:11 +0000 (Thu, 10 Feb 2011) $
    
    properties( SetObservable )
        
        Sizes = zeros( 1, 0 ) % Vector of sizes, with positive elements for absolute sizes (pixels) and negative elements for relative sizes
        Padding = 0           % Padding around contents (pixels)
        Spacing = 0           % Spacing between contents (pixels)
        
    end % public properties
    
    properties( Dependent )
  
        MinimumSizes % Minimum size (in pixels) for each element
        
    end % dependent properties
    
    properties( Access=private )
  
        MinimumSizes_ = zeros( 1, 0 )
        
    end % private properties
    
    methods
        
        function obj = Box( varargin )
            %BOX  Container with contents in a single row or column
            
            % First step is to create the parent class. We pass the
            % arguments (if any) just incase the parent needs setting
            obj@uiextras.Container( varargin{:} );
            
            % Set some defaults
            obj.setPropertyFromDefault( 'Padding' );
            obj.setPropertyFromDefault( 'Spacing' );
            
        end % constructor
        
        function set.Sizes( obj, value )
            % Check. We only count live children
            myChildren = obj.getValidChildren();
            if ~isequal( numel( myChildren ), numel( value ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Size of property ''Sizes'' must match size of property ''Children''.' )
            elseif ~isnumeric( value ) || ...
                    any( ~isreal( value ) ) || any( isnan( value ) ) || any( ~isfinite( value ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''Sizes'' must consist of real, finite, numeric values.' )
            end
            
            % Set
            obj.Sizes = value(:)';
            
            % Redraw
            obj.redraw();
        end % set.Sizes
        
        function set.MinimumSizes( obj, value )
            % Check. We only count live children
            if ~isequal( numel( obj.Sizes ), numel( value ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Size of property ''MinimumSizes'' must match size of property ''Sizes''.' )
            elseif ~isnumeric( value ) || ...
                    any( ~isreal( value ) ) || any( isnan( value ) ) || any( ~isfinite( value ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''MinimumSizes'' must consist of real, finite, numeric values.' )
            end
            
            % Set and redraw
            obj.MinimumSizes_ = value(:)';
            obj.redraw();
        end % set.MinimumSizes
        
        function value = get.MinimumSizes( obj )
            value = obj.MinimumSizes_;
        end % get.MinimumSizes
        
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
        
    end % public methods
    
    methods( Access = protected )
                
        function onChildAdded( obj, source, eventData ) %#ok<INUSD>
            % This callback fires when a child is added to a container.
            % Add an element to Sizes.  This automatically triggers a
            % redraw.
            obj.MinimumSizes_(1,end+1) = 1;
            obj.Sizes(1,end+1) = -1;
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData ) %#ok<INUSL>
            % This callback fires when a child is destroyed or removed.
            % Work out which child has gone and delete the corresponding
            % element from Sizes.  This automatically triggers a redraw.
            obj.MinimumSizes_( eventData.ChildIndex ) = [];
            obj.Sizes( eventData.ChildIndex ) = [];
        end % onChildRemoved
        
    end % protected methods
    
end % classdef