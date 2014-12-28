function col = interpretColor(str)
%interpretColor  Interpret a color as an RGB triple
%
%   rgb = uiextras.interpretColor(col) interprets the input color COL and
%   returns the equivalent RGB triple. COL can be one of:
%   * RGB triple of floating point numbers in the range 0 to 1
%   * RGB triple of UINT8 numbers in the range 0 to 255
%   * single character: 'r','g','b','m','y','c','k','w'
%   * string: one of 'red','green','blue','magenta','yellow','cyan','black'
%             'white'
%   * HTML-style string (e.g. '#FF23E0')
%
%   Examples:
%   >> uiextras.interpretColor( 'r' )
%   ans =
%        1   0   0
%   >> uiextras.interpretColor( 'cyan' )
%   ans =
%        0   1   1
%   >> uiextras.interpretColor( '#FF23E0' )
%   ans =
%        1.0000    0.1373    0.8784
%
%   See also: ColorSpec

%   Copyright 2005-2010 The MathWorks Ltd.
%   $Revision: 329 $
%   $Date: 2010-08-26 09:53:44 +0100 (Thu, 26 Aug 2010) $

if ischar( str )
    str = strtrim(str);
    str = dequote(str);
    if str(1)=='#'
        % HTML-style string
        if numel(str)==4
            col = [hex2dec( str(2) ), hex2dec( str(3) ), hex2dec( str(4) )]/15;
        elseif numel(str)==7
            col = [hex2dec( str(2:3) ), hex2dec( str(4:5) ), hex2dec( str(6:7) )]/255;
        else
            error( 'UIExtras:interpretColor:BadColor', 'Invalid HTML color %s', str );
        end
    elseif all( ismember( str, '1234567890.,; []' ) )
        % Try the '[0 0 1]' thing first
        col = str2num( str ); %#ok<ST2NM>
        if numel(col) == 3
            % Conversion worked, so just check for silly values
            col(col<0) = 0;
            col(col>1) = 1;
        end
    else
        % that didn't work, so try the name
        switch upper(str)
            case {'R','RED'}
                col = [1 0 0];
            case {'G','GREEN'}
                col = [0 1 0];
            case {'B','BLUE'}
                col = [0 0 1];
            case {'C','CYAN'}
                col = [0 1 1];
            case {'Y','YELLOW'}
                col = [1 1 0];
            case {'M','MAGENTA'}
                col = [1 0 1];
            case {'K','BLACK'}
                col = [0 0 0];
            case {'W','WHITE'}
                col = [1 1 1];
            case {'N','NONE'}
                col = [nan nan nan];
            otherwise
                % Failed
                error( 'UIExtras:interpretColor:BadColor', 'Could not interpret color %s', num2str( str ) );
        end
    end
elseif isfloat(str) || isdouble(str)
    % Floating point, so should be a triple in range 0 to 1
    if numel(str)==3
        col = double( str );
        col(col<0) = 0;
        col(col>1) = 1;
    else
        error( 'UIExtras:interpretColor:BadColor', 'Could not interpret color %s', num2str( str ) );
    end
elseif isa(str,'uint8')
    % UINT8, so range is implicit
    if numel(str)==3
        col = double( str )/255;
        col(col<0) = 0;
        col(col>1) = 1;
    else
        error( 'UIExtras:interpretColor:BadColor', 'Could not interpret color %s', num2str( str ) );
    end
else
    error( 'UIExtras:interpretColor:BadColor', 'Could not interpret color %s', num2str( str ) );
end


function str = dequote(str)
str(str=='''') = [];
str(str=='"') = [];
str(str=='[') = [];
str(str==']') = [];
