function renamevar(oldname,newname)
% renames a variable in the base workspace
% usage: renamevar oldname newname
% usage: renamevar('oldname','newname')
%
% renamevar is written to be used as a command, renaming a single
% variable to have a designated new name
%
% arguments: (input)
%  oldname - character string - must be the name of an existing
%          variable in the base matlab workspace.
%
%  newname - character string - the new name of that variable
%
% Example:
% % change the name of a variable named "foo", into a new variable
% % with name "bahr". The original variable named "foo" will no
% % longer be in the matlab workspace.
%
% foo = 1:5;
% renamevar foo bahr

% test for errors
if nargin ~= 2
  error('RENAMEVAR:nargin','Exactly two arguments are required')
elseif ~ischar(oldname) || ~ischar(newname)
  error('RENAMEVAR:characterinput','Character input required - renamevar is a command')
end

teststr = ['exist(''',oldname,''',''var'')'];
result = evalin('caller',teststr);
if result ~= 1
  error('RENAMEVAR:doesnotexist', ...
    ['A variable named ''',oldname,''' does not exist in the base workspace'])
end

% create the new variable
str = [newname,' = ',oldname,';'];
try
  evalin('caller',str)
catch
  error('RENAMEVAR:renamefailed','The rename failed')
end

% clear the original variable
str = ['clear ',oldname];
evalin('caller',str)