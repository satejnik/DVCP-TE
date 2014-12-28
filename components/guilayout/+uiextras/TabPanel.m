classdef TabPanel < uiextras.CardPanel & uiextras.DecoratedPanel
    %TabPanel  Show one element inside a tabbed panel
    %
    %   obj = uiextras.TabPanel() creates a panel with tabs along one edge
    %   to allow selection between the different child objects contained.
    %
    %   obj = uiextras.TabPanel(param,value,...) also sets one or more
    %   property values.
    %
    %   See the <a href="matlab:doc uiextras.TabPanel">documentation</a> for more detail and the list of properties.
    %
    %   Examples:
    %   >> f = figure();
    %   >> p = uiextras.TabPanel( 'Parent', f, 'Padding', 5 );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'r' );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'b' );
    %   >> uicontrol( 'Style', 'frame', 'Parent', p, 'Background', 'g' );
    %   >> p.TabNames = {'Red', 'Blue', 'Green'};
    %   >> p.SelectedChild = 2;
    %
    %   See also: uiextras.Panel
    %             uiextras.BoxPanel
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 893 $
    %   $Date: 2013-12-18 10:23:50 +0000 (Wed, 18 Dec 2013) $
    
    properties
        TabSize = 50
        TabPosition = 'top' % which side of the contents to put the tabs [top|bottom]
    end % public properties
    
    properties( Dependent = true )
        TabNames          % The title string for each tab
        TabEnable = {}    % The enable state of individual tabs
    end % dependent properties
    
    properties( SetAccess = private, GetAccess = private, Hidden = true )
        Images_ = struct()
        TabImage_ = []
        PageLabels = []
        PageEnable_ = {}
    end % private properties
    
    
    methods
        
        function obj = TabPanel(varargin)
            % First step is to create the parent class. We pass the
            % arguments (if any) just incase the parent needs setting
            obj = obj@uiextras.CardPanel( varargin{:} );
            obj = obj@uiextras.DecoratedPanel( varargin{:} );
            
            % Get some defaults
            bgcol = obj.BackgroundColor;
            obj.HighlightColor = ( 2*[1 1 1] + bgcol )/3;
            obj.ShadowColor    = 0.5*bgcol;

            % Add a UIControl for drawing the tabs
            obj.TabImage_ = uicontrol( ...
                'Visible', 'on', ...
                'units', 'pixels', ...
                'Parent', obj.UIContainer, ...
                'HandleVisibility', 'off', ...
                'Position', [1 1 1 1], ...
                'style', 'checkbox', ...
                'Tag', 'uiextras.TabPanel:TabImage');
            
            % Make sure the images are loaded
            obj.reloadImages();
            
            % Set some defaults
            obj.setPropertyFromDefault( 'HighlightColor' );
            obj.setPropertyFromDefault( 'ShadowColor' );            
            obj.setPropertyFromDefault( 'TabPosition' );
            obj.setPropertyFromDefault( 'TabSize' );

            % Parse any input arguments
            if nargin>0
                set( obj, varargin{:} );
            end
            obj.redraw();
        end % TabPanel
        
    end % public methods
    
    methods
        
        function set.TabSize(obj,value)
            obj.TabSize = value;
            obj.redraw();
        end % set.TabSize
        
        function set.TabPosition(obj,value)
            if ~ischar( value ) || ~ismember( lower( value ), {'top','bottom'} )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''TabPosition'' must be ''top'' or ''bottom''.' );
            end
            obj.TabPosition = [upper( value(1) ),lower( value(2:end) )];
            obj.redraw();
        end % set.TabPosition
        
        function value = get.TabNames( obj )
            if isempty( obj.PageLabels )
                value = {};
            elseif numel( obj.PageLabels ) == 1
                value = {get( obj.PageLabels, 'String' )};
            else
                value = get( obj.PageLabels, 'String' )';
            end
        end % get.TabNames
        
        function set.TabNames(obj,value)
            if ~iscell( value ) || numel( value )~=numel( obj.Children )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''TabNames'' must be a cell array of strings the same size as property ''Children''.' )
            end
            for ii=1:numel( obj.Children )
                set( obj.PageLabels(ii), 'String', value{ii} );
            end
        end % set.TabNames

        function value = get.TabEnable(obj)
            value = obj.PageEnable_;
        end % get.TabEnable

        function set.TabEnable(obj,value)
            if ~iscell( value ) || numel( value )~=numel( obj.Children ) ...
                    || any( ~ismember( lower(value), {'on','off'} ) )
                error( 'GUILayout:InvalidPropertyValue', ...
                    'Property ''TabEnable'' must be a cell array of ''on''/''off'' the same size as property ''Children''.' )
            end
            obj.PageEnable_ = lower( value );
            if strcmpi( obj.Enable, 'on' )
                obj.onEnable();
            end
        end % set.TabEnable
        
    end % accessor methods
    
    methods ( Access = protected )
        
        function redraw(obj)
            %redraw  Redraw the tabs and contents
            
            % Check the object exists (may be being deleted!)
            if isempty(obj.TabImage_) || ~ishandle(obj.TabImage_)
                return;
            end
            
            C = obj.Children;
            T = obj.TabNames;
            
            % Make sure label array is right size
            nC = numel(C);
            nT = numel(T);
            
            if nC==0 || nT~=nC
                % With no tabs, blank the image. Note that we must leave
                % non-emoty cdata otherwise the checkbox re-appears!
                set( obj.TabImage_, 'CData', reshape(obj.BackgroundColor, [1 1 3]) );
                return
            end
            
            pos = getpixelposition( obj.UIContainer );
            pad = obj.Padding;
            
            % Calculate the required height from the font size
            oldFontUnits = get( obj.PageLabels(1), 'FontUnits' );
            set( obj.PageLabels(1), 'FontUnits', 'Pixels' );
            fontHeightPix = get( obj.PageLabels(1), 'FontSize' );
            set( obj.PageLabels(1), 'FontUnits', oldFontUnits );
            tabHeight = ceil( 1.5*fontHeightPix + 4 );
            
            % Work out where the tabs labels and contents go
            if strcmpi( obj.TabPosition, 'Top' )
                tabPos = [1 1+pos(4)-tabHeight, pos(3), tabHeight+2];
                contentPos = [pad+1 pad+1 pos(3)-2*pad pos(4)-2*pad-tabHeight];
            else
                tabPos = [1 1, pos(3), tabHeight+2];
                contentPos = [pad+1 tabHeight+pad+1 pos(3)-2*pad pos(4)-2*pad-tabHeight];
            end
            
            % Shorthand for colouring things in
            fgCol = obj.BackgroundColor;
            bgCol = obj.BackgroundColor;
            shCol = 0.9*obj.BackgroundColor;
            
            totalWidth = round( tabPos(3)-1 );
            divWidth = 8;
            textWidth = obj.TabSize;
            if textWidth<0
                % This means we should fill the space
                textWidth = floor( (totalWidth - (nC+1)*divWidth) / nC );
            end
            textPos = [tabPos(1:2), textWidth, tabHeight - 4];
            
            if ~isempty( obj.SelectedChild )
                % The tabs are drawn as a single image
                tabCData(:,:,1) = bgCol(1)*ones(20,totalWidth);
                tabCData(:,:,2) = bgCol(2)*ones(20,totalWidth);
                tabCData(:,:,3) = bgCol(3)*ones(20,totalWidth);
                set( obj.TabImage_, 'Position', [tabPos(1:2),totalWidth,tabHeight] );
                
                % Use the CardLayout function to put the right child onscreen
                obj.showSelectedChild( contentPos )
                
                % Now update the tab image
                tabCData(:,1:divWidth,:) = obj.Images_.NonNot;
                for ii=1:nC
                    x = divWidth+(divWidth+textWidth)*(ii-1)+1;
                    set( obj.PageLabels(ii), ...
                        'Position', textPos+[x,0,0,0] );
                    % BJT: Fix bug where text renders off edge of container
                    if (textPos(1)+x >= totalWidth )
                        set( obj.PageLabels(ii), 'Visible', 'off' );
                    else
                        set( obj.PageLabels(ii), 'Visible', 'on' );
                        rhs = textPos(1)+x+textPos(3);
                        if ( rhs > totalWidth )
                            % Text is partially off the edge
                            set( obj.PageLabels(ii), 'Position', textPos+[x,0,totalWidth-rhs,0] );
                        end
                    end
                    
                    if ii==obj.SelectedChild,
                        set( obj.PageLabels(ii), ...
                            'ForegroundColor', obj.ForegroundColor, ...
                            'BackgroundColor', fgCol);
                        % Set the dividers to show the right image
                        tabCData(:,x:x+textWidth-1,:) = repmat(obj.Images_.SelBack,1,textWidth);
                        if ii==1
                            tabCData(:,x-divWidth:x-1,:) = obj.Images_.NonSel;
                        else
                            tabCData(:,x-divWidth:x-1,:) = obj.Images_.NotSel;
                        end
                        if ii==nC
                            tabCData(:,x+textWidth:x+textWidth+divWidth-1,:) = obj.Images_.SelNon;
                        else
                            tabCData(:,x+textWidth:x+textWidth+divWidth-1,:) = obj.Images_.SelNot;
                        end
                    else
                        set( obj.PageLabels(ii), ...
                            'ForegroundColor', 0.6*obj.ForegroundColor + 0.4*shCol, ...
                            'BackgroundColor', shCol );
                        tabCData(:,x:x+textWidth-1,:) = repmat(obj.Images_.NotBack,1,textWidth);
                        if ii==nC
                            tabCData(:,x+textWidth:x+textWidth+divWidth-1,:) = obj.Images_.NotNon;
                        else
                            tabCData(:,x+textWidth:x+textWidth+divWidth-1,:) = obj.Images_.NotNot;
                        end
                    end
                end % For
                
                % Stretch the CData to match the fontsize
                if tabHeight ~= 20
                    topbot = min( round( tabHeight/2 ), 5 );
                    midsz = tabHeight - 2*topbot;
                    topData = tabCData(1:topbot,:,:);
                    bottomData = tabCData(end-topbot+1:end,:,:);
                    midData = repmat( tabCData(10,:,:), [midsz,1,1] );
                    tabCData = [ topData ; midData ; bottomData ];
                end
                
                if strcmpi( obj.TabPosition, 'Top' )
                    set( obj.TabImage_, 'CData', tabCData );
                else
                    set( obj.TabImage_, 'CData', flipdim( tabCData, 1 ) ); %#ok<DFLIPDIM>
                end
            end
        end % redraw
        
        function onChildAdded( obj, source, eventData ) %#ok<INUSD>
            %onChildAdded: Callback that fires when a child is added to a container.
            % Select the new addition
            C = obj.Children;
            N = numel( C );
            visible = obj.Visible;
            title = sprintf( 'Page %d', N );
            
            obj.PageLabels(end+1,1) = uicontrol( ...
                'Visible', visible, ...
                'style', 'text', ...
                'enable', 'inactive', ...
                'string', title, ...
                'FontName', obj.FontName, ...
                'FontUnits', obj.FontUnits, ...
                'FontSize', obj.FontSize, ...
                'FontAngle', obj.FontAngle, ...
                'FontWeight', obj.FontWeight, ...
                'ForegroundColor', obj.ForegroundColor, ...
                'parent', obj.UIContainer, ...
                'HandleVisibility', 'off');
            iResetTabCallbacks( obj )
            obj.PageEnable_{1,end+1} = 'on';
            if strcmpi( obj.Enable, 'off' )
                set( obj.PageLabels(end), 'Enable', 'off' );
            end
            obj.SelectedChild = N;
        end % onChildAdded
        
        function onChildRemoved( obj, source, eventData ) %#ok<INUSL>
            %onChildAdded: Callback that fires when a container child is destroyed or reparented.
            % If the missing child is the selected one, select something else
            
            % Deal with empty explicitly since we need to clear everything
            if isempty(obj.Children)
                obj.TabNames = {};
                obj.PageEnable_ = {};
                delete(obj.PageLabels);
                obj.PageLabels = [];
                obj.SelectedChild = [];
                obj.redraw()
                return;
            end
            
            % Clear one entry, maybe selecting a different one
            obj.TabNames( eventData.ChildIndex ) = [];
            obj.PageEnable_( eventData.ChildIndex ) = [];
            delete( obj.PageLabels(eventData.ChildIndex) );
            obj.PageLabels(eventData.ChildIndex) = [];
            iResetTabCallbacks( obj );
            if obj.SelectedChild >= eventData.ChildIndex
                % We need to change the selection. This will force a redraw
                obj.SelectedChild = max( 1, obj.SelectedChild - 1 );
            else
                % We don't need to change the selection, so need to
                % explicitly redraw
                obj.redraw();
            end
        end % onChildRemoved
        
        function onBackgroundColorChanged( obj, source, eventData ) %#ok<INUSD>
            %onBackgroundColorChanged  Callback that fires when the container background color is changed
            %
            % We need to make the panel match the container background
            obj.reloadImages();
            obj.redraw();
        end % onBackgroundColorChanged
        
        function onPanelColorChanged( obj, source, eventData ) %#ok<INUSD>
            % Colors have changed. This requires the images to be reset and
            % redrawn.
            obj.reloadImages();
            obj.redraw();
        end % onPanelColorChanged
        
        function onPanelFontChanged( obj, source, eventData ) %#ok<INUSL>
            % Font has changed. Since the font size and shape affects the
            % space available for the contents, we need to redraw.
            for ii=1:numel( obj.PageLabels )
                set( obj.PageLabels(ii), eventData.Property, eventData.Value );
            end
            obj.redraw();
        end % onPanelFontChanged
        
        function onEnable( obj, source, eventData ) %#ok<INUSD>
            % We use "inactive" to be the "on" state
            if strcmpi( obj.Enable, 'on' )
                % Take notice of the individual enable states. Where the
                % page is to be enabled we set the title uicontrol to be
                % inactive rather than on to avoid mouse-over problems.
                hittest = obj.PageEnable_;
                enable = strrep( obj.PageEnable_, 'on', 'inactive' );
                for jj=1:numel( obj.PageLabels )
                    set( obj.PageLabels(jj), ...
                        'Enable', enable{jj}, ...
                        'HitTest', hittest{jj} ); 
                    % Since the panel as a whole is on, we may need to
                    % switch off some children
                    obj.helpSetChildEnable( obj.Children(jj), hittest{jj} );
                end
            else
                for jj=1:numel( obj.PageLabels )
                    set( obj.PageLabels(jj), 'Enable', 'off', 'HitTest', 'off' );
                end
            end
        end % onEnable
        
        function reloadImages( obj )
            % Reload tab images
            
            % If any of the colours are not yet constructed, stop now
            if isempty( obj.TabImage_ ) ...
                    || isempty( obj.HighlightColor ) ...
                    || isempty( obj.ShadowColor )
                return;
            end
            
            % First part of the name says which type of right-hand edge is needed
            % (non = no edge, not = not selected, sel = selected), second gives
            % left-hand
            obj.Images_.NonSel = iLoadIcon( 'tab_NoEdge_Selected.png', ...
                obj.BackgroundColor, obj.HighlightColor, obj.ShadowColor );
            obj.Images_.SelNon = iLoadIcon( 'tab_Selected_NoEdge.png', ...
                obj.BackgroundColor, obj.HighlightColor, obj.ShadowColor );
            obj.Images_.NonNot = iLoadIcon( 'tab_NoEdge_NotSelected.png', ...
                obj.BackgroundColor, obj.HighlightColor, obj.ShadowColor );
            obj.Images_.NotNon = iLoadIcon( 'tab_NotSelected_NoEdge.png', ...
                obj.BackgroundColor, obj.HighlightColor, obj.ShadowColor );
            obj.Images_.NotSel = iLoadIcon( 'tab_NotSelected_Selected.png', ...
                obj.BackgroundColor, obj.HighlightColor, obj.ShadowColor );
            obj.Images_.SelNot = iLoadIcon( 'tab_Selected_NotSelected.png', ...
                obj.BackgroundColor, obj.HighlightColor, obj.ShadowColor );
            obj.Images_.NotNot = iLoadIcon( 'tab_NotSelected_NotSelected.png', ...
                obj.BackgroundColor, obj.HighlightColor, obj.ShadowColor );
            obj.Images_.SelBack = iLoadIcon( 'tab_Background_Selected.png', ...
                obj.BackgroundColor, obj.HighlightColor, obj.ShadowColor );
            obj.Images_.NotBack = iLoadIcon( 'tab_Background_NotSelected.png', ...
                obj.BackgroundColor, obj.HighlightColor, obj.ShadowColor );
            
        end % reloadImages
        
    end % protected methods
    
end % classdef

%-------------------------------------------------------------------------%

function im = iLoadIcon(imagefilename, backgroundcolor, highlightcolor, shadowcolor )
% Special image loader that turns various primary colours into background
% colours.

error( nargchk( 4, 4, nargin, 'struct' ) ); %#ok<NCHKN>

% Load an icon and set the transparent color
this_dir = fileparts( mfilename( 'fullpath' ) );
icon_dir = fullfile( this_dir, 'Resources' );
im8 = imread( fullfile( icon_dir, imagefilename ) );
im = double(im8)/255;
rows = size(im,1);
cols = size(im,2);

% Anything that's pure green goes to transparent
f=find((im8(:,:,1)==0) & (im8(:,:,2)==255) & (im8(:,:,3)==0));
im(f) = nan;
im(f + rows*cols) = nan;
im(f + 2*rows*cols) = nan;

% Anything pure red goes to selected background
f=find((im8(:,:,1)==255) & (im8(:,:,2)==0) & (im8(:,:,3)==0));
im(f) = backgroundcolor(1);
im(f + rows*cols) = backgroundcolor(2);
im(f + 2*rows*cols) = backgroundcolor(3);

% Anything pure blue goes to background background
f=find((im8(:,:,1)==0) & (im8(:,:,2)==0) & (im8(:,:,3)==255));
im(f) = backgroundcolor(1);
im(f + rows*cols) = backgroundcolor(2);
im(f + 2*rows*cols) = backgroundcolor(3);

% Anything pure yellow goes to deselected background
f=find((im8(:,:,1)==255) & (im8(:,:,2)==255) & (im8(:,:,3)==0));
im(f) = 0.9*backgroundcolor(1);
im(f + rows*cols) = 0.9*backgroundcolor(2);
im(f + 2*rows*cols) = 0.9*backgroundcolor(3);

% Anything pure white goes to highlight
f=find((im8(:,:,1)==255) & (im8(:,:,2)==255) & (im8(:,:,3)==255));
im(f) = highlightcolor(1);
im(f + rows*cols) = highlightcolor(2);
im(f + 2*rows*cols) = highlightcolor(3);

% Anything pure black goes to shadow
f=find((im8(:,:,1)==0) & (im8(:,:,2)==0) & (im8(:,:,3)==0));
im(f) = shadowcolor(1);
im(f + rows*cols) = shadowcolor(2);
im(f + 2*rows*cols) = shadowcolor(3);

end % iLoadIcon

%-------------------------------------------------------------------------%

function iTabClicked( src, evt, obj, idx ) %#ok<INUSL>

% Call the user callback before selecting the tab
evt = struct( ...
    'Source', obj, ...
    'PreviousChild', obj.SelectedChild, ...
    'SelectedChild', idx );
uiextras.callCallback( obj.Callback, obj, evt );
obj.SelectedChild = idx;

end % iTabClicked

%-------------------------------------------------------------------------%

function iResetTabCallbacks( obj )
% Helper to setup the callback functions on each tab label
for N=1:numel(obj.PageLabels)
   set(obj.PageLabels(N), 'ButtonDownFcn', {@iTabClicked, obj, N});
end
end % iResetTabCallbacks