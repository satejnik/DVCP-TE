% Copyright: N. L. Ricker, 12/98.  ricker@u.washington.edu

% Plots data from TE problem simulation.  Assumes
% that simulation time is in vector "tout", 
% plant outputs are in matrix "simout",
% plant MVs are in matrix "xmv".

TEdata.xy=[tout(:) simout(:,1:41)];
TEdata.iy=cell(1,41);
for i=1:41; TEdata.iy{i}=i; end
TEdata.title=cell(1,41);
TEdata.ylabel=cell(1,41);
TEdata.xlabel=cell(1,41);
for i=1:41; TEdata.xlabel{i}='Hours'; end
TEdata.layout='2x2';
TEdata.title{1}='A Feed';
TEdata.ylabel{1}='kscmh';
TEdata.title{2}='D Feed';
TEdata.ylabel{2}='kg/h';
TEdata.title{3}='E Feed';
TEdata.ylabel{3}='kg/h';
TEdata.title{4}='A and C Feed';
TEdata.ylabel{4}='kscmh';
TEdata.title{5}='Recycle Flow';
TEdata.ylabel{5}='kscmh';
TEdata.title{6}='Reactor Feed Rate';
TEdata.ylabel{6}='kscmh';
TEdata.title{7}='Reactor Pressure';
TEdata.ylabel{7}='kPa gauge';
TEdata.title{8}='Reactor Level';
TEdata.ylabel{8}='%';
TEdata.title{9}='Reactor Temperature';
TEdata.ylabel{9}='Deg C';
TEdata.title{10}='Purge Rate';
TEdata.ylabel{10}='kscmh';
TEdata.title{11}='Product Sep Temp';
TEdata.ylabel{11}='Deg C';
TEdata.title{12}='Product Sep Level';
TEdata.ylabel{12}='%';
TEdata.title{13}='Product Sep Pressure';
TEdata.ylabel{13}='kPa gauge';
TEdata.title{14}='Product Sep Underflow';
TEdata.ylabel{14}='m3/h';
TEdata.title{15}='Stripper Level';
TEdata.ylabel{15}='%';
TEdata.title{16}='Stripper Pressure';
TEdata.ylabel{16}='kPa gauge';
TEdata.title{17}='Stripper Underflow';
TEdata.ylabel{17}='m3/h';
TEdata.title{18}='Stripper Temp';
TEdata.ylabel{18}='Deg C';
TEdata.title{19}='Stripper Steam Flow';
TEdata.ylabel{19}='kg/h';
TEdata.title{20}='Compressor Work';
TEdata.ylabel{20}='kW';
TEdata.title{21}='Reactor Coolant Temp';
TEdata.ylabel{21}='Deg C';
TEdata.title{22}='Separator Coolant Temp';
TEdata.ylabel{22}='Deg C';
for i=23:41, TEdata.ylabel{i}='Mole %'; end
comps=['A','B','C','D','E','F','G','H'];
for i=23:28, TEdata.title{i}=['Component ',comps(i-22),' to Reactor']; end
for i=29:36, TEdata.title{i}=['Component ',comps(i-28),' in Purge']; end
for i=37:41, TEdata.title{i}=['Component ',comps(i-33),' in Product']; end


TEmvs.xy=[tout(:) xmv(:,1:12)];
TEmvs.iy=cell(1,12);
for i=1:12; TEmvs.iy{i}=i; end
TEmvs.title=cell(1,12);
TEmvs.ylabel=cell(1,12);
TEmvs.xlabel=cell(1,12);
for i=1:41; TEmvs.xlabel{i}='Hours'; end
TEmvs.layout='2x2';
TEmvs.title{1}='D feed';
TEmvs.ylabel{1}='%';
TEmvs.title{2}='E Feed';
TEmvs.ylabel{2}='%';
TEmvs.title{3}='A Feed';
TEmvs.ylabel{3}='%';
TEmvs.title{4}='A and C Feed';
TEmvs.ylabel{4}='%';
TEmvs.title{5}='Recycle';
TEmvs.ylabel{5}='%';
TEmvs.title{6}='Purge';
TEmvs.ylabel{6}='%';
TEmvs.title{7}='Separator';
TEmvs.ylabel{7}='%';
TEmvs.title{8}='Stripper';
TEmvs.ylabel{8}='%';
TEmvs.title{9}='Steam';
TEmvs.ylabel{9}='%';
TEmvs.title{10}='Reactor Coolant';
TEmvs.ylabel{10}='%';
TEmvs.title{11}='Condenser Coolant';
TEmvs.ylabel{11}='%';
TEmvs.title{12}='Agitator';
TEmvs.ylabel{12}='%';

if exist('FIg1')
    close(FIg1);
end
if exist('FIg2')
    close(FIg2)
end

if ~exist('FIg1')
   FIg1=figure;
   set(FIg1,'Units','points',...
      'CloseRequestFcn','delete([FIg, FIg1]); clear FIg FIg1');
   Pos=get(gcf,'Position');
end
   figure(FIg1);
   plot(tout,simout(:,7));
   xlabel('Hours'); ylabel(TEdata.ylabel(7)); 
   title(TEdata.title(7));
   
   % Set up GUI
if ~exist('FIg')
   FIg=figure('Units','points',...
   'CloseRequestFcn','delete([FIg, FIg1]); clear FIg FIg1',...
	'MenuBar','none',...
	'Position',[Pos(1:2)+[20 -60] 180 40],...
	'Name','Signal Selection',...
   'NumberTitle','off');			% Figure window
   CALLback=['Sig=get(gcbo,''Value''); figure(FIg1);'...
         'plot(tout,simout(:,Sig)); title(TEdata.title(Sig));',...
         'xlabel(''Hours''); ylabel(TEdata.ylabel(Sig));',...
         'figure(FIg)'];
	uicontrol('Parent',FIg,'Units','points', ...
	'callback',CALLback,...
	'Position',[20 5 150 20],'String',TEdata.title,...
	'Value',7,'Style','popup');	% Inactive block edit box
else
    figure(FIg)
end

if ~exist('FIg2')
   FIg2=figure;
   set(FIg2,'Units','points',...
      'CloseRequestFcn','delete([FIgM, FIg2]); clear FIgM FIg2');
   Pos=get(gcf,'Position');
end
   figure(FIg2)
   plot(tout,xmv(:,10));
   xlabel('Hours'); ylabel(TEmvs.ylabel(10)); 
   title(TEmvs.title(10));

   % Set up GUI
if ~exist('FIgM')   
   FIgM=figure('Units','points',...
   'CloseRequestFcn','delete([FIgM, FIg2]); clear FIgM FIg2',...
	'MenuBar','none',...
	'Position',[Pos(1:2)+[20 -60] 180 40],...
	'Name','MV Selection',...
   'NumberTitle','off');			% Figure window
   CALLback=['Sig=get(gcbo,''Value''); figure(FIg2);'...
         'plot(tout,xmv(:,Sig)); title(TEmvs.title(Sig));',...
         'xlabel(''Hours''); ylabel(TEmvs.ylabel(Sig));',...
         'figure(FIgM)'];
	uicontrol('Parent',FIgM,'Units','points', ...
	'callback',CALLback,...
	'Position',[20 5 150 20],'String',TEmvs.title,...
	'Value',10,'Style','popup');	% Inactive block edit box
end