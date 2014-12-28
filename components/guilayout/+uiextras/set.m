function set( hObj, propName, propValue )
%uiextras.set  Store a default property value in a parent object
%
%   uiextras.set(hObj,propName,propValue) stores a default property value
%   in the object hObj such that children created inside it of the correct
%   class will use the specified value (propValue) for the specified
%   property by default. The property name should take the form
%   "DefaultClassProperty", for example to set the default "TitleColor" for
%   the class "uiextras.BoxPanel", use "DefaultBoxPanelTitleColor". Note
%   that using the special object handle 0 sets the default for all new
%   figures.
%
%   Examples:
%   >> uiextras.set( gcf(), 'DefaultBoxPanelTitleColor', 'g' )
%   >> uiextras.set( 0, 'DefaultHBoxPadding', 5 )
%
%   See also: uiextras.get
%             uiextras.unset

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1$
%   $Date: 2010-05-18$

% Check inputs
error( nargchk( 3, 3, nargin, 'struct' ) )

if isa( hObj, 'uiextras.Container' )
    hObj = double( hObj );
end
if ~isequal( hObj, 0 ) && ~ishghandle( hObj )
    error( 'GUILayout:InvalidArgument', 'Object must be a valid Handle Graphics object.' )
end
if ~ischar( propName )
    error( 'GUILayout:InvalidArgument', 'Property name must be a string.' )
end

% Make sure the property requested is a default
if ~strncmp( propName, 'Default', 7 )
    error( 'GUILayout:InvalidArgument', 'Property name must begin with ''Default''.' )
end

% All OK, so set it
setappdata( hObj, propName, propValue );