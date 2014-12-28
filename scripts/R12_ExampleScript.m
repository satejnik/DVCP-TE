% Copyright: N. L. Ricker, 12/98.  ricker@u.washington.edu

u0=[63.53,  53.98, 24.644, 61.302, 22.21, ...
    40.064, 38.1,  46.534, 47.446, 41.106, ...
    18.114, 50];       % Base case inputs (XMV variables).
u0(10)=38;             % Specifies a step in XMV(10)


% Set up for integration:

tspan = [0 0.3];               % Starting and ending time.
ut    = [tspan' [u0;u0] ];     % Specifies constant inputs.

%   Integrate over entire 0.3 hour time period:
options = simset('Solver'                ,'ode45');
options = simset(options,'MaxStep'       ,0.01);
options = simset(options,'MinStep'       ,0.00001);
options = simset(options,'InitialStep'   ,0.01);
[tt,xt,yt]=sim('tesys',tspan,options,ut);

% Plot results: 

figure
subplot(221)
plot(tt,yt(:,6)),title('Reactor Feed'),xlabel('Time (hours)')
subplot(222)
plot(tt,yt(:,7)),title('Reac Pressure'),xlabel('Time (hours)')
subplot(223)
plot(tt,yt(:,8)),title('Reac Level'),xlabel('Time (hours)')
subplot(224)
plot(tt,yt(:,9)),title('Reac Temp'),xlabel('Time (hours)')


figure
subplot(221)
plot(tt,yt(:,11)),title('Prod Sep Temp'),xlabel('Time (hours)')
subplot(222)
plot(tt,yt(:,12)),title('Prod Sep Level'),xlabel('Time (hours)')
subplot(223)
plot(tt,yt(:,10)),title('Purge Rate'),xlabel('Time (hours)')
subplot(224)
plot(tt,yt(:,18)),title('Stripper Temp'),xlabel('Time (hours)')


