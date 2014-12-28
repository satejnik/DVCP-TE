function varargout = callCallback( callback, varargin )
%callCallback  Try to call a callback function or method
%
%   uiextras.callback(@FCN,ARG1,ARG2,...) calls the function
%   specified by the supplied function handle @FCN, passing it the supplied
%   extra arguments.
%
%   uiextras.callback(FCNCELL,ARG1,ARG2,...) calls the function
%   specified by the first item in cell array FCNCELL, passing the extra
%   arguments ARG1, ARG2 etc before any additional arguments in the cell
%   array.
%
%   uiextras.callback(FUNCNAME,ARG1,ARG2,...) calls the function
%   specified by the string FUNCNAME, passing the supplied extra arguments.
%
%   [OUT1,OUT2,...] = uiextras.callback(...) also captures return
%   arguments. Note that the function called must provide exactly the right
%   number of output arguments.
%
%   Use this function to handle firing callbacks from widgets.
%
%   Examples:
%   >> callback = {@horzcat, 5, 6};
%   >> c = uiextras.callCallback( callback, 1, 2, 3, 4 )
%   c =
%       1  2  3  4  5  6
%
%   See also: function_handle

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 361 $
%   $Date: 2011-02-07 15:40:44 +0000 (Mon, 07 Feb 2011) $

if isempty( callback ) % empty
    
    return
    
elseif iscell( callback ) % cell array
    
    inargs = [callback(1), varargin, callback(2:end)];
    
elseif ischar( callback ) && any( ismember( callback, ' =' ) ) % expression
    
    eval( callback );
    return
    
else % function handle or string
    
    inargs = [{callback}, varargin];
    
end

% Call callback
[varargout{1:nargout}] = feval( inargs{:} );

end % callCallback