function [version, versionDate] = layoutVersion()
%layoutVersion  get the toolbox version and date
%
%   V = layoutVersion() returns just the version string
%
%   [V,D] = layoutVersion() returns both the version string and the date of
%   creation (format is ISO8601, i.e. YYYY-MM-DD)
%
%   Examples:
%   >> [v,d] = layoutVersion()
%   v = '1.0'
%   d = '2010-05-28'
%
%   See also: layoutRoot

%   Copyright 2009-2013 The MathWorks Ltd.

% True version number comes from layout/Contents.m
v = ver('layout');
if isempty(v)
    error('Layouts:NotInstalled', 'GUI Layout Toolbox is not installed.');
end
version = v.Version;
versionDate = datestr(datenum(v.Date), 'yyyy-mm-dd'); % Convert to ISO standard format
