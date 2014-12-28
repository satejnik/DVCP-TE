% Copyright 2009-2013 The MathWorks Ltd.

f = figure(); 

% Box Panel 
p = uiextras.BoxPanel( 'Parent', f, 'Title', 'A BoxPanel', 'Padding', 5 ); 

% HBox 
b = uiextras.HBox( 'Parent', p, 'Spacing', 5, 'Padding', 5 ); 

% uicontrol 
uicontrol( 'Style', 'listbox', 'Parent', b, 'String', {'Item 1','Item 2'} ); 

% Grid Flex 
g = uiextras.GridFlex( 'Parent', b, 'Spacing', 5 ); 
uicontrol( 'Parent', g, 'Background', 'r' );
uicontrol( 'Parent', g, 'Background', 'b' );
uicontrol( 'Parent', g, 'Background', 'g' );
uiextras.Empty( 'Parent', g );
uicontrol( 'Parent', g, 'Background', 'c' );
uicontrol( 'Parent', g, 'Background', 'y' );
set( g, 'ColumnSizes', [-1 100 -2], 'RowSizes', [-1 -2] ); 

% set HBox elements sizes 
set( b, 'Sizes', [100 -1] ); 
