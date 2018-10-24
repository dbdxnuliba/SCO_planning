%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solve the following exercises:
%   A) Exercise A: Use the Runge-Kutta 4 algorithm to integrate the
%   differential equation:
%            dy/dt = 2*t
%      Integrate from t0=0, to tfinal = 10 s.
%      Compare the solution with the algebraic integration.
%   B) Exercise B: Use the Runge-Kutta 4 algorithm to integrate the
%   second order differential equation:
%            d2y/dt^2+5*dy/dt + 4*y(t) = 0
%
%   C) Exercise C: Use the Runge-Kutta 4 algorithm to simulate the movement
%   of a 1 dof robot arm with friction under the effect of gravity and with
%   zero torque applied.
%
%   D) Exercise D: Use the Runge-Kutta 4 algorithm to simulate the movement
%   of a 2 dof robot arm with friction under the effect of gravity and with
%   zero torques applied.
%
% Help: Function prototype
% [y, t] = runge_kutta(f, y0, [t0 tfinal], timestep)
% where f is the function being integrated as dy/dt = f(t, y).
% y0 are the initial conditions
% t0: initial time
% tfinal: final time.
% h: time step for the calculations.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function runge_kutta_exercises()
close all;

%uncomment to execute each of the exercises
%exerciseA()
%exerciseB()
exerciseC()
%exerciseD()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Integrate a simple time function. dy/dt = 2*t
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function exerciseA()
t0 = 0;
tfinal = 10;
% TODO: define the line function below.
[t, y] = runge_kutta(@line, 0, [t0 tfinal], 0.1);

%Compare with the integral of 2*t
%error = y-t.^2';
%mean(error)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use Runge-Kutta to integrate a second order equation of the form.
% d2y/dt^2+5*dy/dt + 4*y(t) = 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function exerciseB()
t0 = 0;
tfinal = 10;
[t, y] = runge_kutta(@second_order_system, [10 1], [t0 tfinal], 0.1);

%plot results
plot(t, y)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now use Runge-kutta to integrate the movement of a 1 dof robot arm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function exerciseC()
%these variables are shared by the forward_dynamic_robot1 function defined
%below
global robot tau g
t0 = 0;
tfinal = 10;
robot = load_robot('example','1dofplanar')
robot.dynamics.friction=1
tau = [1];
g = [0 -9.81 0]';
[t, y] = runge_kutta(@forward_dynamic_robot1, [0 0]', [t0 tfinal], 0.01);

% Animate the movement. Change speed from 1-30-100-200
speed = 5
animate(robot,[y(1,1:speed:length(y)); y(2,1:speed:length(y))])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now use Runge-Kutta to simulate the movement of a 2 DOF robot arm.
function exerciseD()
global robot tau g

robot = load_robot('example','2dofplanar')
robot.dynamics.friction=1
tau = [0 0];
g = [0 -9.81 0]';
[t, y] = runge_kutta(@forward_dynamic_robot2, [0 0 0 0]', [t0 2], 0.001);
%speed, change to 10, 30, 50, 100
speed = 50
animate(robot,[y(1,1:speed:length(y)); y(2,1:speed:length(y))])




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper function.
% The function returns dy/dt = 2*t. Function called from exerciseA()
%
% Integrate a line in time. dy/dt = 2*t. Obviously, the integration should
% yield. y(t) = t^2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dy = line(t, y)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper function to solve a second order differential equation.
% Called from function exerciseB()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xd = second_order_system(t, y)

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper function to simulate the movement of a 1 DOF robot
% Called from function exerciseC()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xd = forward_dynamic_robot1(t, y)
global tau g robot

qdd = accel(robot, y(1), y(2), tau, g);
%return qd, qdd
xd = [y(2); qdd];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper function to simulate the movement of a 2 DOF robot
% Called from function exerciseD()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xd = forward_dynamic_robot2(t, y)
global tau g robot
%we must return the solution of
% [dx1/dt; dx2/dt]
t
qdd=forwarddynamics_2dofplanar(robot, y(1:2,1), y(3:4,1), tau', -9.81, [0 0 0 0 0 0]);
%return qd, qdd
xd = [y(3:4,1); qdd];


