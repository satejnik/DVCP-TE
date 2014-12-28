function propValue = get( hObj, propName )
%uiextras.get  Retrieve a default property value from a parent object
%
%   propValue = uiextras.get(hObj,propName) retrieves a default property
%   value from the object hObj. Note that the hObj must be a valid graphics
%   container object such as a uipanel, figure or the special flag 0 (the
%   overall environment). The property name should take the form
%   "DefaultClassProperty", for example to get the default "TitleColor" for
%   the class "uiextras.BoxPanel", use "DefaultBoxPanelTitleColor". If no
%   default has been set for the specified property an error is thrown.
%
%   Examples:
%   >> p = uiextras.get( gcf(), 'DefaultBoxPanelTitleColor' )
%   
%   >> p = uiextras.get( 0, 'DefaultHBoxPadding' )
%
%   See also: uiextras.set

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

% All OK, so set it
propValue = getappdata( hObj, propName );

% If not found, try the parent
while isempty( propValue ) && ~isequal( hObj, 0 )
    hObj = get( hObj, 'Parent' );
    propValue = getappdata( hObj, propName );
end

if isempty( propValue )
    error( 'GUILayout:get:ItemNotFound', ...
        'Could not find a value for property ''%s'' in the ancestors of this object.', propName );
end