function currentState = enableDisableFig(hFig, newState)
% enableDisableFig enable or disable an entire figure window
%
% Syntax:
%    currentState = enableDisableFig(hFig, newState)
%
% Description:
%    enableDisableFig sets the figure hFig's enable/disable state, which
%    is otherwise supported by Matlab only for specific components but not
%    figures. Using this function, the entire figure window, including all
%    internal menus, toolbars and components, is enabled/disabled in a
%    single call. Valid values for newState are true, false, 'on' & 'off'
%    (case insensitive). hFig may be a list of figure handles.
%
%    Note 1: when the state is enabled, internal figure components may
%    remain disabled if their personal 'enabled' property is 'off'.
%
%    Note 2: in disabled state, a figure cannot be moved, resized, closed
%    or accessed. None of its menues, toolbars, buttons etc. are clickable.
%
%    enableDisableFig(newState) sets the state of the current figure (gcf).
%    Note 3: this syntax (without hFig) might cause unexpected results if
%    newState is a numeric value (interpreted as a figure handle), instead
%    of a string or logical value.
%
%    state = enableDisableFig(hFig) returns the current enabled/disabled
%    state of figure hFig, or of the current figure (gcf) if hFig is not
%    supplied. The returned state is either 'on' or 'off'.
%
% Examples:
%    state = enableDisableFig;
%    state = enableDisableFig(hFig);
%    oldState = enableDisableFig(hFig, 'on');
%    oldState = enableDisableFig(hFig, result>0);
%    oldState = enableDisableFig(true);  % on current figure (Note 3 above)
%
% Technical description:
%    http://UndocumentedMatlab.com/blog/disable-entire-figure-window
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Warning:
%    This code heavily relies on undocumented and unsupported Matlab
%    functionality. It works on Matlab 7+, but use at your own risk!
%
% Change log:
%    2007-08-10: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do?objectType=author&mfx=1&objectId=1096533#">MathWorks File Exchange</a>
%    2007-08-11: Fixed sanity checks for illegal list of figure handles
%    2011-02-18: Remove Java warnings in modern Matlab releases
%    2011-10-14: Fix for R2011b
%
% See also:
%    gcf, findjobj, getJFrame (last two on the File Exchange)

% Programmed by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.3 $  $Date: 2011/10/14 03:24:32 $

  try
      % Default figure = current (gcf)
      if nargin < 1 || ~all(ishghandle(hFig))
          if nargin && ~all(ishghandle(hFig))
              if nargin < 2
                  newState = hFig;
              else
                  error('hFig must be a valid GUI handle or array of handles');
              end
          end
          hFig = gcf;
      end

      % Require Java engine to run
      if ~usejava('jvm')
          error([mfilename ' requires Java to run.']);
      end

      % Loop over all requested figures
      for figIdx = 1 : length(hFig)

          % Get the root Java frame
          jff = getJFrame(hFig(figIdx));

          % Get the current frame's state
          currentState{figIdx} = get(jff,'Enabled');  %#ok loop

          % Set the new figure enabled state, if requested
          if exist('newState','var')
              if ischar(newState)
                  newState = lower(newState);
                  if ~any(strcmp(newState,{'on','off'}))
                      error('newState must be one of: ''on'', ''off'', true, false')
                  end
              end
              try
                  oldWarn = warning('off','MATLAB:hg:JavaSetHGProperty');
                  set(jff,'Enabled',newState);          % accepts 'on'/'off'
                  warning(oldWarn)
              catch
                  set(handle(jff),'Enabled',newState);  % accepts true/false
              end
          end
      end

      % De-cell a single value
      if length(currentState) == 1
          currentState = currentState{1};
      end

  % Error handling
  catch
      v = version;
      if v(1)<='6'
          err.message = lasterr;  % no lasterror function...
      else
          err = lasterror;
      end
      try
          err.message = regexprep(err.message,'Error using ==> [^\n]+\n','');
      catch
          try
              % Another approach, used in Matlab 6 (where regexprep is unavailable)
              startIdx = findstr(err.message,'Error using ==> ');
              stopIdx = findstr(err.message,char(10));
              for idx = length(startIdx) : -1 : 1
                  idx2 = min(find(stopIdx > startIdx(idx)));  %#ok ML6
                  err.message(startIdx(idx):stopIdx(idx2)) = [];
              end
          catch
              % never mind...
          end
      end
      if isempty(findstr(mfilename,err.message))
          % Indicate error origin, if not already stated within the error message
          err.message = [mfilename ': ' err.message];
      end
      if v(1)<='6'
          while err.message(end)==char(10)
              err.message(end) = [];  % strip excessive Matlab 6 newlines
          end
          error(err.message);
      else
          rethrow(err);
      end
  end

%% Get the root Java frame (up to 10 tries, to wait for figure to become responsive)
function jframe = getJFrame(hFig)

  % Ensure that hFig is a figure handle...
  hFig = ancestor(hFig,'figure');
  if isempty(hFig)
      error(['Cannot retrieve the figure handle for handle ' num2str(hFigHandle)]);
  end

  jframe = [];
  maxTries = 10;
  while maxTries > 0
      try
          % Get the figure's underlying Java frame
          jf = get(handle(hFig),'javaframe');

          % Get the Java frame's root frame handle
          %jframe = jf.getFigurePanelContainer.getComponent(0).getRootPane.getParent;
          try
              jframe = jf.fFigureClient.getWindow;  % equivalent to above...
          catch
              jframe = jf.fHG1Client.getWindow;  % equivalent to above...
          end
          if ~isempty(jframe)
              break;
          else
              maxTries = maxTries - 1;
              drawnow; pause(0.1);
          end
      catch
          maxTries = maxTries - 1;
          drawnow; pause(0.1);
      end
  end
  if isempty(jframe)
      error('Cannot retrieve figure''s java frame');
  end
