function doc( funcname )
%DOC  a wrapper for the built-in "doc" that also finds user documentation
%
%   DOC(FUNCNAME) tries to find HTML help for the function, class or
%   method FUNCNAME. It first searches the MATLAB path for FUNCNAME.html,
%   and if this is not found calls the built-in "doc" function to scan the
%   built-in help files. This is needed because the "doc" command in R2007a
%   and above no longer searches the MATLAB path for help files (it did for
%   R14 up to R2006b). Once this is fixed this hack should be removed.

%   Copyright 2007 The MathWorks Ltd.
%   $Revision: 71 $    
%   $Date: 2010-07-07 08:21:55 +0100 (Wed, 07 Jul 2010) $

if nargin
    if ischar( funcname )
        w = which( [funcname,'.html'] );
    elseif ishandle( funcname )
        switch upper( get( funcname, 'type' ) )
            case 'BLOCK'
                funcname = iResolveSimulinkBlockType( funcname );
            otherwise
                error( 'doc:BadArg', 'Cannot find documentation for object of type ''%s''', get( funcname, 'type' ) );
        end
        if isempty(funcname)
            error( 'doc:BadArg', 'Object returned empty type description' );
        else
            w = which( [funcname,'.html'] );
        end
    end
else
    w = [];
end
if isempty(w)
    % To get a function handle to the original function we first have to CD
    % to its directory, then get a handle, then return to where we were.
    % Urgh! Just horrible.
    olddir = pwd();
    origpath = fullfile( matlabroot(), 'toolbox', 'matlab', 'helptools' );
    cd(origpath);
    orig_doc = str2func( 'doc' );
    cd(olddir);
    
    % OK, we have the handle, so call it
    if nargin
        feval( orig_doc, funcname );
    else
        feval( orig_doc );
    end
else
    web(w, '-helpbrowser'); % was helpview(w) but gave Java issues - DJA
end

function type = iResolveSimulinkBlockType( block )
% Simulink block. The block type can be in many places
% according to how the block was constructed so we need to
% check the type
block_type = get( block, 'BlockType' );
switch upper( block_type )
    case 'SUBSYSTEM'
        type = get( block, 'MaskType' );
    otherwise
        error( 'doc:BadArg', 'Simulink block type ''%s'' is not yet supported', block_type );
end

