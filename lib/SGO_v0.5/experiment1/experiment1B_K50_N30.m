%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Max manipulability index ALONG A LINE.
% Use stomp like to optimize along a surface/line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function experiment1B
close all;
global robot
global parameters
global hfigures

%STOMP PARAMETERS
%conversion from cost to Prob factor
parameters.lambda = .4;
parameters.lambda_obstacles = .2;
%height of the obstacle
parameters.yo = 2.5;
%cost function starts at this distance
%must be below 0.3 for the 4 DOF robot
parameters.epsilon = 0.2;
%multiply noise by this facto
%parameters.noise_k = 5;
%parameters.noise_sigma_null_space = 0.01;
parameters.alpha=0.02;
parameters.time_step=0.01;

%number of waypoints
parameters.N = 12;
%number of particles
parameters.K = 50;
parameters.n_repeat = 30;
parameters.experiment_name = 'experiment1B_K50_N30.mat';

parameters.animate = 0;

parameters.obstacles = [];


%LINE 1
x1 = -1.5;
y1 = .5; %m
x2 = 0;
y2 = 2; %m
phi = 3*pi/4; 
p0 = [x1 y1 0]';
pf = [x2 y2 0]';
T0 = build_T_4dof(p0, phi);
parameters.obstacles{1}.line = [p0 pf];
parameters.obstacles{1}.T0 = T0;

%repeat the experiment E times
random_manips=[];
Gout = [];
for i=1:parameters.n_repeat
    close all
    [pk, final_manip] = stomp_null_space(robot);
    Gout{i}=pk;
    random_manips = [random_manips; final_manip];
    save(parameters.experiment_name)
end



function T = build_T_4dof(p, phi)
T = [cos(phi) -sin(phi) 0 p(1);
     sin(phi) cos(phi) 0 p(2);
     0            0     1  p(3);
     0             0    0   1];
 
 function T = build_T_sawyer(p, phi)
T = [1  -sin(phi) 0 p(1);
     0  cos(phi) 0 p(2);
     0            0     1  p(3);
     0             0    0   1];
 



 
