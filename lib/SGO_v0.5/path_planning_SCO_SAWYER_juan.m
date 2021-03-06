%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Max manipulability index ALONG A LINE.
% Use stomp like to optimize along a surface/line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [qq, manips]=path_planning_SCO_SAWYER_juan
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
parameters.N = 25;
%number of particles
parameters.K = 15;
%select the rows of J that should be taken into account when computing
%manipulability
parameters.sel_J = [1 2 3 4 5 6];
%parameters.sel_J = [1 2 3];
parameters.obstacles = [];

parameters.animate = 0;
close all
% hfigures.hpaths = figure;
% hfigures.hcosts = figure;
% hfigures.hee = figure;
% hfigures.htheta = figure;
% hfigures.hbest_costs = figure;
% hfigures.hdtheta = figure;

sph_ctr=[0 0.7 1]';
sph_radio=0.5;
% Define the input grid (in 3D)
[x3, y3, z3] = meshgrid(linspace(-1,1));
% Compute the implicitly defined function (sphere)
f1 = (x3-sph_ctr(1)).^2 + (y3-sph_ctr(2)).^2 + (z3-sph_ctr(3)).^2 - sph_radio^2;

% Next surface is z = 2*y - 6*x^3, which can also be expressed as
% 2*y - 6*x^3 - z = 0.
f2 = 2*y3 - 6*x3.^3 - z3;
% Also compute z = 2*y - 6*x^3 in the 'traditional' way.
[x2, y2] = meshgrid(linspace(-1,1));
z2 = 2*y2 - 6*x2.^3;
% Visualize the two surfaces.

patch(isosurface(x3, y3, z3, f1, 0), 'FaceColor', [1 1 1], 'EdgeColor', 'none');
%patch(isosurface(x3, y3, z3, f2, 0), 'FaceColor', [1.0 0.5 0.0], 'EdgeColor', 'none');
%view(3); camlight; axis vis3d;

% Find the difference field.
f3 = f1 - f2;
% Interpolate the difference field on the explicitly defined surface.
f3s = interp3(x3, y3, z3, f3, x2, y2, z2);
% Find the contour where the difference (on the surface) is zero.
C = contours(x2, y2, f3s, [0 0]);
% Extract the x- and y-locations from the contour matrix C.
xL = C(1, 2:end);
yL = C(2, 2:end);
% Interpolate on the first surface to find z-locations for the intersection
% line.
zL = interp2(x2, y2, z2, xL, yL);
tr=[xL ;yL; zL];
% Visualize the line.
figure(99), hold on
[x,y,z] = sphere;
%surf(x*sph_radio+sph_ctr(1), y*sph_radio+sph_ctr(2), z*sph_radio+sph_ctr(3));
line(xL,yL,zL,'Color','k','LineWidth',3);


parameters.obstacles{1}.center = sph_ctr;
parameters.obstacles{1}.radio = sph_radio;

%define trajectory over sphere
inicio_traj=ceil(uniform(1, size(tr,2)-parameters.N-1, 1, 1));
p0=tr(:,inicio_traj); %first point over the line

parameters.trajectory{1}.line = tr;
parameters.trajectory{1}.p0=p0;
parameters.trajectory{1}.first_pos=inicio_traj;
parameters.trajectory{1}.T0 = build_T_from_obstacle(p0);

%LAUNCH SCO given the stored parameters
pk = SCO_null_space(robot);

%calculate and plot errors in position and orientation
errors_pos=[];
errors_ori=[];
ang_norms=[];
for i=1:size(pk.pathq,2)
    ref_pt=tr(:,inicio_traj+i-1);
    ref_T=build_T_from_obstacle(ref_pt);
    ref_rot=T2quaternion(ref_T);
    ref_n=ref_T(1:3,3);
    figure(99), hold on
    quiver3(ref_pt(1),ref_pt(2),ref_pt(3),ref_n(1),ref_n(2),ref_n(3))
    
    act_T=directkinematic(robot, pk.pathq(:,i));%actual T matrix
    act_pt=act_T(1:3,4);
    act_rot=T2quaternion(act_T);
    act_n=act_T(1:3,3);
    figure(99), hold on
    quiver3(act_pt(1),act_pt(2),act_pt(3),act_n(1),act_n(2),act_n(3))
    
    error_pos=norm(ref_pt-act_pt);
    errors_pos=[errors_pos error_pos];
    
    ori_prod=qprod(qconj(ref_rot/norm(ref_rot)),act_rot/norm(act_rot));
    error_ori= 2*acosd(ori_prod(1));
    ThetaInDegrees = acosd(dot(act_n,ref_n)/(norm(act_n)*norm(ref_n)));
    ang_norms=[ang_norms ThetaInDegrees];
    errors_ori=[errors_ori error_ori];
end   

figure,
plot(errors_pos)
xlabel('Waypoints')
title('Position error')

figure,
plot(errors_ori)
xlabel('Waypoints')
title('Orientation error')

figure,
plot(ang_norms)
xlabel('Waypoints')
title('Orientation error (Angle between normals)')


% Given the normal, we must compute an orientation that is perpendicular
% to the normal
% surface sign indicates whether the Z vector of the end_effector must have
% the same direction as n or opposite.
function T = build_T_from_obstacle(pt)
global robot
global parameters

n=pt-parameters.obstacles{1}.center;

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
T(1:3,4)=pt;
T(4,4)=1;

%constant orientation
%T = eye(4);

%return T in the oposite direction!
%with robot coupling tranformation
T=T*inv(robot.Tcoupling);



 
