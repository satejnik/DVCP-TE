function folder = layoutRoot()
%layoutRoot  returns the folder containing the layout toolbox
%
%   folder = layoutRoot() returns the full path to the folder containing
%   the layout toolbox.
%
%   Examples:
%   >> folder = layoutRoot()
%   folder = 'C:\Temp\LayoutToolbox1.0'
%
%   See also: layoutVersion

%   Copyright 2009-2010 The MathWorks Ltd.
%   $Revision: 199 $    
%   $Date: 2010-06-18 15:55:16 +0100 (Fri, 18 Jun 2010) $

folder = fileparts( mfilename( 'fullpath' ) );