classdef VButtonBox < uiextras.ButtonBox
    %VButtonBox  Arrange buttons vertically in a single column
    %
    %   obj = uiextras.VButtonBox() is a type of VBox specialised for
    %   arranging a column of buttons, check-boxes or similar graphical
    %   elements. All buttons are given equal size and by default are
    %   centered in the drawing area. The justification can be changed as
    %   required.
    %
    %   obj = uiextras.VButtonBox(param,value,...) also sets one or more
    %   parameter values.
    %
    %   See the <a href="matlab:doc uiextras.VButtonBox">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> b = uiextras.VButtonBox( 'Parent', f );
    %   >> uicontrol( 'Parent', b, 'String', 'One' );
    %   >> uicontrol( 'Parent', b, 'String', 'Two' );
    %   >> uicontrol( 'Parent', b, 'String', 'Three' );
    %   >> set( b, 'ButtonSize', [130 35], 'Spacing', 5 );
    %
    %   See also: uiextras.HButtonBox
    %             uiextras.VBox
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 300 $
    %   $Date: 2010-07-22 16:33:47 +0100 (Thu, 22 Jul 2010) $
    
    methods
        
        function obj = VButtonBox( varargin )
            %VButtonBox  Create a new horizontal button box
            
            % First step is to create the parent class. We pass the
            % arguments (if any) just incase the parent needs setting
            obj@uiextras.ButtonBox( varargin{:} );

            % Set properties
            if nargin > 0
                set( obj, varargin{:} );
            end
        end % constructor
        
    end % public methods
    
    methods( Access = protected )
        
        function redraw( obj )
            % First we need to work out how much space is available - if
            % there's not enough for the desired size then the buttons may
            % have to shrink
            children = obj.getValidChildren();
            nChildren = numel( children );
            pos = ceil( getpixelposition( obj.UIContainer ) );
            availableWidth = pos(3) - 2*obj.Padding;
            availableHeight = pos(4) - 2*obj.Padding - (nChildren-1)*obj.Spacing;
            
            buttonWidth = min( obj.ButtonSize(1), availableWidth );
            buttonHeight = min( obj.ButtonSize(2), availableHeight/nChildren );
            
            % The positioning depends on the alignment
            buttonsHeight = buttonHeight*nChildren + (nChildren-1)*obj.Spacing;
            switch upper( obj.VerticalAlignment )
                case 'TOP'
                    y0 = pos(4) - obj.Padding - buttonsHeight;
                    
                case 'MIDDLE'
                    y0 = 1 + round( ( pos(4) - buttonsHeight ) / 2 );
                    
                case 'BOTTOM'
                    y0 = 1 + obj.Padding;
                    
                otherwise
                    error( 'GUILayout:InvalidState', ...
                        'Invalid vertical alignment ''%s''.', obj.VerticalAlignment )
                    
            end
            
            switch upper( obj.HorizontalAlignment )
                case 'LEFT'
                    x0 = 1+ obj.Padding;
                    
                case 'CENTER'
                    x0 = 1 + round( (pos(3) - buttonWidth ) / 2 );
                    
                case 'RIGHT'
                    x0 = pos(3) - obj.Padding - buttonWidth;
                    
                otherwise
                    error( 'GUILayout:InvalidState', ...
                        'Invalid horizontal alignment ''%s''.', obj.HorizontalAlignment )
                    
            end
            
            % OK, we now know the start coords, so position each child
            for ii=1:nChildren
                child = children(nChildren-ii+1);
                contentPos = [x0, y0 + (ii-1)*(obj.Spacing+buttonHeight), buttonWidth, buttonHeight];
                obj.repositionChild( child, contentPos )
            end
            
        end % redraw
        
    end % protected methods
    
end % classdef