function uic = makeFlexDivider( parent, position, bgCol, orientation, showMarks )
%makeFlexDivider  Create a divider widget and add markings if desired
%
%   This function is for internal use only.
%
%   See also: uiextras.VBoxFlex
%             uiextras.HBoxFlex
%             uiextras.GridFlex

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 354 $
%   $Date: 2010-11-01 10:07:13 +0000 (Mon, 01 Nov 2010) $

error( nargchk( 5, 5, nargin, 'struct' ) );

if strcmpi( showMarks, 'off' ) || position(3)<3 || position(4)<3
    % No amarkings or too small to show them, so draw a blank
    cdata = ones( position(4)-1, position(3)-1 ); % One less than the space since uicontrols always start with a blank pixel
    cdata = cat( 3, cdata*bgCol(1), cdata*bgCol(2), cdata*bgCol(3) );
else
    
    % Make the divider slightly darker than it's surroundings
    bgCol = 0.97*bgCol;
    
    % Determine the highlight and lowlight colors and create an empty image
    hiCol = 1-0.2*(1-bgCol);
    loCol = 0.8*bgCol;
    fgCol = 1-0.7*(1-bgCol);
    cdata = ones( position(4)-1, position(3)-1 ); % One less than the space since uicontrols always start with a blank pixel
    cdata = cat( 3, cdata*bgCol(1), cdata*bgCol(2), cdata*bgCol(3) );
    
    % Fill central region with foreground color. Note that the top and left get
    % a spare pixel anyway, so start at 1,1.
    cdata(1:end-1,1:end-1,1) = fgCol(1);
    cdata(1:end-1,1:end-1,2) = fgCol(2);
    cdata(1:end-1,1:end-1,3) = fgCol(3);
    
    % Add fletchings if there's space
    if strcmpi( orientation, 'Vertical' )
        % Vertical divider requires horizontal fletchings
        numFletches = min( 10, floor( position(4)/6 ) ); % Fill no more than half the space (3 pixels per mark, so divide by 6)
        y0 = round( (position(4)-numFletches*3 ) / 2 );
        for ii=1:numFletches
            y = y0+(ii-1)*3;
            % Add highlight
            cdata(y,1:end-1,1) = hiCol(1);
            cdata(y,1:end-1,2) = hiCol(2);
            cdata(y,1:end-1,3) = hiCol(3);
            % Add shadow
            cdata(y+1,1:end-1,1) = loCol(1);
            cdata(y+1,1:end-1,2) = loCol(2);
            cdata(y+1,1:end-1,3) = loCol(3);
        end
    else
        % Horizontal divider requires vertical fletchings
        numFletches = min( 10, floor( position(3)/6 ) ); % Fill no more than half the space (3 pixels per mark, so divide by 6)
        x0 = round( (position(3)-numFletches*3 ) / 2 );
        for ii=1:numFletches
            x = x0+(ii-1)*3;
            % Add highlight
            cdata(1:end-1,x,1) = hiCol(1);
            cdata(1:end-1,x,2) = hiCol(2);
            cdata(1:end-1,x,3) = hiCol(3);
            % Add shadow
            cdata(1:end-1,x+1,1) = loCol(1);
            cdata(1:end-1,x+1,2) = loCol(2);
            cdata(1:end-1,x+1,3) = loCol(3);
        end
        
    end
end

% If the first argument is a divider, we update it, otherwise create from
% scratch.
if strcmpi( get( parent, 'Type' ), 'UIControl' )
    % Update existing
    set( parent, ...
        'BackgroundColor', bgCol, ...
        'ForegroundColor', bgCol, ...
        'CData', cdata, ...
        'Position', position );
    uic = parent;
else
    % Create the widget
    uic = uicontrol( 'Parent', parent, ...
        'Style', 'Checkbox', ...
        'BackgroundColor', bgCol, ...
        'ForegroundColor', bgCol, ...
        'CData', cdata, ...
        'HitTest', 'on', ...
        'Enable', 'inactive', ...
        'Units', 'Pixels', ...
        'Position', position, ...
        'HandleVisibility', 'off' );
end

% Store the original position for later
setappdata( uic, 'OriginalPosition', position );