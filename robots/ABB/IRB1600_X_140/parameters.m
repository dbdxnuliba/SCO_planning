%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   PARAMETERS Returns a data structure containing the parameters of the
%   ABB IRB140.
%
%   Author: Arturo Gil. Universidad Miguel Hern?ndez de Elche. 
%   email: arturo.gil@umh.es date:   09/01/2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2012, by Arturo Gil Aparicio
%
% This file is part of ARTE (A Robotics Toolbox for Education).
% 
% ARTE is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% ARTE is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with ARTE.  If not, see <http://www.gnu.org/licenses/>.
function robot = parameters()

robot.name= 'IRB1600_X_140';

%Path where everything is stored for this robot
robot.path = 'robots/abb/IRB1600_X_140';

robot.DH.theta= '[q(1) q(2)-pi/2 q(3) q(4) q(5) q(6)+pi]';
robot.DH.d='[0.4865 0 0 0.600 0 0.065]';
robot.DH.a='[0.150 0.700 0 0 0 0]';
robot.DH.alpha= '[-pi/2 0 -pi/2 pi/2 -pi/2 0]';
robot.J=[];


robot.inversekinematic_fn = 'inversekinematic_irb1600X_140(robot, T)';

%number of degrees of freedom
robot.DOF = 6;

%rotational: 0, translational: 1
robot.kind=['R' 'R' 'R' 'R' 'R' 'R'];

%minimum and maximum rotation angle in rad
robot.maxangle =[-pi pi; %Axis 1, minimum, maximum
                deg2rad(-90) deg2rad(150); %Axis 2, minimum, maximum
                deg2rad(-245) deg2rad(65); %Axis 3
                deg2rad(-200) deg2rad(200); %Axis 4: Unlimited (400? default)
                deg2rad(-115) deg2rad(115); %Axis 5
                deg2rad(-400) deg2rad(400)]; %Axis 6: Unlimited (800? default)

%maximum absolute speed of each joint rad/s or m/s
robot.velmax = [deg2rad(150); %Axis 1, rad/s
                deg2rad(160); %Axis 2, rad/s
                deg2rad(170); %Axis 3, rad/s
                deg2rad(320); %Axis 4, rad/s
                deg2rad(400); %Axis 5, rad/s
                deg2rad(460)];%Axis 6, rad/s
% end effectors maximum velocity
robot.linear_velmax = 2.5; %m/s
robot.accelmax=robot.velmax/0.1; % 0.1 is here an acceleration time
 
%base reference system
robot.T0 = eye(4);

%INITIALIZATION OF VARIABLES REQUIRED FOR THE SIMULATION
%position, velocity and acceleration
robot=init_sim_variables(robot);

% GRAPHICS
robot.graphical.has_graphics=1;
robot.graphical.color = [255 102 51]./255;
%for transparency
robot.graphical.draw_transparent=0;
%draw DH systems
robot.graphical.draw_axes=1;
%DH system length and Font size, standard is 1/10. Select 2/20, 3/30 for
%bigger robots
robot.graphical.axes_scale=1;
%adjust for a default view of the robot
robot.axis=[-0.75 0.75 -0.75 0.75 0 1.2];
%read graphics files
robot = read_graphics(robot);

%DYNAMICS
robot.has_dynamics=0;