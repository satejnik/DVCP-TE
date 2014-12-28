function dockexample()
%DOCKEXAMPLE: An example of using the panelbox dock/undock functionality

%   Copyright 2009-2013 The MathWorks Ltd.

% Create the window and main layout
fig = figure( 'Name', 'Dockable GUI example', ...'
    'NumberTitle', 'off', ...
    'Toolbar', 'none', ...
    'MenuBar', 'none', ...
    'CloseRequestFcn', @nCloseAll );
box = uiextras.HBox( 'Parent', fig );

% Add three panels to the box
panel{1} = uiextras.BoxPanel( 'Title', 'Panel 1', ...
    'DockFcn', {@nDock, 1}, ...
    'Parent', box );
panel{2} = uiextras.BoxPanel( 'Title', 'Panel 2', ...
    'DockFcn', {@nDock, 2}, ...
    'Parent', box );
panel{3} = uiextras.BoxPanel( 'Title', 'Panel 3', ...
    'DockFcn', {@nDock, 3}, ...
    'Parent', box );

% Add some contents
uicontrol( 'Style', 'PushButton', 'String', 'Button 1', 'Parent', panel{1} );
uicontrol( 'Style', 'PushButton', 'String', 'Button 2', 'Parent', panel{2} );
box1 = uiextras.VBox( 'Parent', panel{3} );
box2 = uiextras.HBox( 'Parent', box1 );
uicontrol( 'Style', 'PushButton', 'String', 'Button 3', 'Parent', box1 );
uicontrol( 'Style', 'PushButton', 'String', 'Button 4', 'Parent', box2 );
uicontrol( 'Style', 'PushButton', 'String', 'Button 5', 'Parent', box2 );

% Set the dock/undock callback
set( panel{1}, 'DockFcn', {@nDock, 1} );
set( panel{2}, 'DockFcn', {@nDock, 2} );
set( panel{3}, 'DockFcn', {@nDock, 3} );

%-------------------------------------------------------------------------%
    function nDock( eventSource, eventData, whichpanel ) %#ok<INUSL>
        % Set the flag
        panel{whichpanel}.IsDocked = ~panel{whichpanel}.IsDocked;
        if panel{whichpanel}.IsDocked
            % Put it back into the layout
            newfig = get( panel{whichpanel}, 'Parent' );
            set( panel{whichpanel}, 'Parent', box );
            delete( newfig );
        else
            % Take it out of the layout
            pos = getpixelposition( panel{whichpanel} );
            newfig = figure( ...
                'Name', get( panel{whichpanel}, 'Title' ), ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Toolbar', 'none', ...
                'CloseRequestFcn', {@nDock, whichpanel} );
            figpos = get( newfig, 'Position' );
            set( newfig, 'Position', [figpos(1,1:2), pos(1,3:4)] );
            set( panel{whichpanel}, 'Parent', newfig, ...
                'Units', 'Normalized', ...
                'Position', [0 0 1 1] );
        end
    end % nDock

%-------------------------------------------------------------------------%
    function nCloseAll( ~, ~ )
        % User wished to close the application, so we need to tidy up
        
        % Delete all windows, including undocked ones. We can do this by
        % getting the window for each panel in turn and deleting it.
        for ii=1:numel( panel )
            if isvalid( panel{ii} ) && ~strcmpi( panel{ii}.BeingDeleted, 'on' )
                figh = ancestor( panel{ii}, 'figure' );
                delete( figh );
            end
        end
        
    end % nCloseAll

end % Main function
