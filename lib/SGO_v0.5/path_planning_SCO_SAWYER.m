%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Max manipulability index ALONG A LINE.
% Use stomp like to optimize along a surface/line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [qq, manips]=path_planning_SCO_SAWYER
close all;
global robot
global parameters
global hfigures

%STOMP PARAMETERS
%conversion from cost to Prob factor
%parameters.lambda = .4;
parameters.lambda_obstacles = 2;
parameters.lambda_manip = 3;
%cost function starts at this distance
%must be below 0.3 for the 4 DOF robot
parameters.epsilon_distance = 0.1;
%height of the obstacle
%parameters.yo = 2.5;



%parameters.noise_sigma_null_space = 0.01;
parameters.alpha=0.05;
parameters.step_time=0.1;
%Error in XYZ to stop inverse kinematics
parameters.epsilonXYZ=0.01;
%Error in Quaternion to stop inverse kinematics.
parameters.epsilonQ=0.01;
parameters.stop_iterations=500;

%number of waypoints
parameters.N = 15;
%number of particles
parameters.K = 15;
%select the rows of J that should be taken into account when computing
%manipulability
parameters.sel_J = [1 2 3 4 5 6];
%parameters.sel_J = [1 2 3];
parameters.obstacles = [];

parameters.animate = 0;
close all
hfigures.hpaths = figure;
hfigures.hcosts = figure;
hfigures.hee = figure;
hfigures.htheta = figure;
hfigures.hbest_costs = figure;
hfigures.hdtheta = figure;

%Obstacle generation
%LINE 1
x1 = -0.5;
y1 = 0.3; %m
z1 = 0;
x2 = 0;
y2 = 0.4; %m
z2 = 0;
p0 = [x1 y1 z1]';
pf = [x2 y2 z2]';
p3 = [0 0 0]';

%normal
n = compute_plane([p3 pf p0]);
parameters.obstacles{1}.n = n;
parameters.obstacles{1}.p = p0;
%points defining surface. %define obstacles using point and normal
parameters.obstacles{1}.points = [p3 pf p0];
%define trajectory from plane
parameters.trajectory{1}.line = [p0 pf];
parameters.trajectory{1}.T0 = build_T_from_obstacle(parameters.obstacles{1}, p0);

%LINE 2
x1 = 0;
y1 = 0.4; %m
z1 = 0;
x2 = 0.4;
y2 = 0.4; %m
z2 = 0.4;
p0 = [x1 y1 z1]';
pf = [x2 y2 z2]';
p3 = [0 0 0]';
%normal
n = compute_plane([p3 pf p0]);
parameters.obstacles{2}.n = n;
parameters.obstacles{2}.p = p0;
parameters.obstacles{2}.points = [p3 pf p0];
%define trajectory from plane
parameters.trajectory{2}.line = [p0 pf];
parameters.trajectory{2}.T0 = build_T_from_obstacle(parameters.obstacles{2}, p0);

% 
% %LINE 3
x1 = 0.4;
y1 = 0.4; %m
z1 = 0.4;
x2 = 0.4;
y2 = 0.0; %m
z2 = 0.0; %m
p0 = [x1 y1 z1]';
pf = [x2 y2 z2]';
p3 = [0 0 0]';
%normal
n = compute_plane([p3 pf p0]);
parameters.obstacles{3}.n = n;
parameters.obstacles{3}.p = p0;
parameters.obstacles{3}.points = [p3 pf p0];
%define trajectory from plane
parameters.trajectory{3}.line = [p0 pf];
parameters.trajectory{3}.T0 = build_T_from_obstacle(parameters.obstacles{3}, p0);

%LAUNCH SCO given the stored parameters
pk = SCO_null_space(robot);


function T = build_T_4dof(p, phi)
T = [cos(phi) -sin(phi) 0 p(1);
     sin(phi) cos(phi) 0 p(2);
     0            0     1  p(3);
     0             0    0   1];
 
 function T = build_T_sawyer(p, phi)
% T = [-sin(phi)  cos(phi)     0         p(1);
%      cos(phi)   sin(phi)      0         p(2);
%      0             0         -1         p(3);
%      0             0         0          1];
 
T = [0     1     0         p(1);
     1      0      0         p(2);
     0      0       -1         p(3);
     0      0      0          1];
 
function [n] = compute_plane(points)
p1 = points(:,1);
p2 = points(:,2); 
p3 = points(:,3); 
n = cross(p2-p1, p3-p1);
n = n/norm(n);
    
% Use Quaternion algebra
% the angle is dificult to find
function T = build_T_from_obstacleQ(p0, n)
global robot
nx = n(1);
ny = n(2);
nz = n(3);
%convert from normal n to quaternion asuming angle of rotation is zero
%surface sign
angle = pi/4;
qx = nx * sin(angle/2);
qy = ny * sin(angle/2);
qz = nz * sin(angle/2);
qw = cos(angle/2);
Q = [qw qx qy qz];

%this
T = quaternion2T(Q, p0);
%return T in the oposite direction!
T=T*inv(robot.Tcoupling);

% Given the normal, we must compute an orientation that is perpendicular
% to the normal
% surface sign indicates whether the Z vector of the end_effector must have
% the same direction as n or opposite.
function T = build_T_from_obstacle(obstacle, p0)
global robot
n = obstacle.n;
nx = n(1);
ny = n(2);
nz = n(3);

%this is vector z7 of the end effector
z7 = n;
x0=[1 0 0]';
%x7 points in the direction of the first line
x7 = cross(x0, n);

%y7 to form rotation matrix
y7 = cross(z7,x7);

T = zeros(4,4);
R = [x7 y7 z7];
T(1:3,1:3)=R;
T(1:3,4)=p0;
T(4,4)=1;

%constant orientation
T = eye(4);

%return T in the oposite direction!
%with robot coupling tranformation
T=T*inv(robot.Tcoupling);



 
