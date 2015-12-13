%	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
%	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
%	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
%	All rights reserved.
%	License: http://opensource.org/licenses/BSD-3-Clause
%	----------------------------------------------------------------------
function window = configui
%	Window handler need to be stored in the base workspace.
%   Example: gui = configui;

    % check requirements
    if ~NET.isNETSupported
        error('TE:configui', '.NET Framework is not supported. Install .NET before use this functionality.');
    end
    
    % import classes
    NET.addAssembly([pwd '\bin\configui.exe']);
    window = configui.MainView;
    
    addlistener(window, 'ScriptEvent', @(sender, args) eval(char(args.Script))); 
    window.Show();
    window.Topmost = true;
end