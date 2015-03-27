%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function addpaths(paths, option)
    
    messages = messagesConstructor();
   	    
    recursive = false;
    if nargin > 1
        switch option
            case 'recursive'
                recursive = true;
            otherwise
                warning(messages('notKnownOption'), option);
        end
    end
    if recursive
        for dd=1:numel(paths)
            addRecursive(paths{dd});
        end        
    else
        for dd=1:numel(paths)
            if isPackage(paths{dd})
                continue
            end
            addpath(paths{dd});
        end
    end
end

function addRecursive(directory)
    if isXternals(directory)
       	return;
    end
    addpath(directory);
    dirs = subfolders(directory);
    for dd=1:numel(dirs)
        addRecursive(fullfile(directory, dirs{dd}));
    end
end

function messages = messagesConstructor()
    keys = {'notKnownOption','motKnownError'};
	values = {'Option "%s" not available','An unknown error occurred'};
    messages = containers.Map(keys,values);
end

function result = isPackage(fullname)
    result = startsWith(filename(fullname), '+');
end

function result = isXternal(fullname)
    result = startsWith(filename(fullname), '-');
end

function result = isHidden(fullname)
    result = startsWith(fileext(fullname), '.');
end

function result = isXternals(fullname)
    result =  isPackage(fullname) ...
           || isXternal(fullname) ...
           || isHidden(fullname)  ...
           || endsWith(fullname, 'deprecated');         
end

