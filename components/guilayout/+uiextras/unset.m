function unset( hObj, propName )
%uiextras.unset  Clear a default property value from a parent object
%
%   uiextras.unset(hObj,propName) clears a default property value from the
%   object hObj. Note that the hObj must be a valid graphics container
%   object such as a uipanel, figure or the special flag 0 (the overall
%   environment. If a default has been set for the specified property
%   (propName) of the specified layout (className), it is removed.
%
%   Examples:
%   >> uiextras.unset( gcf(), 'DefaultBoxPanelTitleColor' )
%
%   See also: uiextras.set
%             uiextras.get

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1$
%   $Date: 2010-05-18$

% Check inputs
error( nargchk( 2, 2, nargin ) );
if isempty( hObj )
    hObj = 0;
end
if strncmpi( class( hObj ), 'uiextras.', 9 )
    hObj = double( hObj );
end
if ~isequal( hObj, 0 ) && ~ishghandle( hObj )
    error( 'GUILayout:InvalidArgument', 'Object must be a valid Handle Graphics object.' );
end
if ~ischar( propName )
    error( 'GUILayout:InvalidArgument', 'Property name must be a string.' )
end

% Make sure the property requested is a default
if ~strncmp( propName, 'Default', 7 )
    error( 'GUILayout:InvalidArgument', 'Property name must begin with ''Default''.' )
end

% Try to remove appdata
while true
    if isappdata( hObj, propName ) % appdata found
        rmappdata( hObj, propName ); % remove
        break % done
    elseif isempty( get( hObj, 'Parent' ) ) % cannot look higher than root
        error( 'GUILayout:get:ItemNotFound', ...
            'Could not find a value for property ''%s'' in the ancestors of this object.', propName );
    else % continue one level up
        hObj = get( hObj, 'Parent' );
        continue
    end
end