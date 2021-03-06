%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Q = INVERSEKINEMATIC_IRB1600X_140(robot, T)	
%   Solves the inverse kinematic problem for the ABB IRB 1600X_140 robot
%   where:
%   robot stores the robot parameters.
%   T is an homogeneous transform that specifies the position/orientation
%   of the end effector.
%
%   A call to Q=INVERSEKINEMATIC_IRB1600X_140 returns 8 possible solutions, thus,
%   Q is a 6x8 matrix where each column stores 6 feasible joint values.
%
%   
%   Example code:
%
%   >>abb=load_robot('ABB', 'IRB1600X_140');
%   >>q = [0 0 0 0 0 0];	
%   >>T = directkinematic(abb, q);
%   %Call the inversekinematic for this robot
%   >>qinv = inversekinematic(abb, T);
%
%   check that all of them are feasible solutions!
%   and every Ti equals T
%   for i=1:8,
%        Ti = directkinematic(abb, qinv(:,i))
%   end
%	See also DIRECTKINEMATIC.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  A partir del inverskinematic.m proporcionado en el robot IRB140 hemos
%  construido el nuestro.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [q] = inversekinematic_irb1600X_140(robot, T)

%initialize q,
%eight possible solutions are generally feasible
q=zeros(6,8);

%Carga el DH del robot
theta = eval(robot.DH.theta);
d = eval(robot.DH.d);
a = eval(robot.DH.a);
alpha = eval(robot.DH.alpha);


%Toma los datos de la geometr???a del robot
L1=d(1);
L2=a(2);
L3=d(4);
L6=d(6);

A1 = a(1);


%T= [ nx ox ax Px;
%     ny oy ay Py;
%     nz oz az Pz];
Px=T(1,4);
Py=T(2,4);
Pz=T(3,4);

%Computa la posici???n del extremo del robot, siendo W la componente Z del sistema
%efector
W = T(1:3,3);

% Pm: Posici???n del extremo del robot
Pm = [Px Py Pz]' - L6*W; 

%para q(1) hay dos posibles soluciones
% si q(1) es una soluci???n, entonces q(1) + pi es tambi???n una soluci???n
q1=atan2(Pm(2), Pm(1));


%soluci???n para q2 a partir de q1 y q1 + pi
q2_1=solve_for_theta2(robot, [q1 0 0 0 0 0 0], Pm);

q2_2=solve_for_theta2(robot, [q1+pi 0 0 0 0 0 0], Pm);

%soluci???n para q3 a partir de q1 y q1 + pi
q3_1=solve_for_theta3(robot, [q1 0 0 0 0 0 0], Pm);

q3_2=solve_for_theta3(robot, [q1+pi 0 0 0 0 0 0], Pm);


% Si q1 es una soluci???n, q1* = q1 + pi es tambi???n una soluci???n 
% para cada (q1, q1*) hay dos posibles soluciones para q2 y q3. 
% Hasta ahora tenemos 4 posibles soluciones. 
% Existen dos posibles soluciones m???s para las tres ???ltimas uniones, 
% llamadas mu???eca arriba y mu???eca abajo. Por eso, 
% la siguiente matriz dobla cada columna. Por cada dos columnas, dos
% configuraciones para theta4, theta 5 y theta 6 ser???n calculadas.
q = [q1         q1         q1        q1       q1+pi   q1+pi   q1+pi   q1+pi;   
     q2_1(1)    q2_1(1)    q2_1(2)   q2_1(2)  q2_2(1) q2_2(1) q2_2(2) q2_2(2);
     q3_1(1)    q3_1(1)    q3_1(2)   q3_1(2)  q3_2(1) q3_2(1) q3_2(2) q3_2(2);
     0          0          0         0         0      0       0       0;
     0          0          0         0         0      0       0       0;
     0          0          0         0         0      0       0       0];

%leave only the real part of the solutions
q=real(q);

%Note that in this robot, the joint q3 has a non-simmetrical range. In this
%case, the joint ranges from 60 deg to -219 deg, thus, the typical normalizing
%step is avoided in this angle (the next line is commented). When solving
%for the orientation, the solutions are normalized to the [-pi, pi] range
%only for the theta4, theta5 and theta6 joints.

%normalize q to [-pi, pi]
q(1,:) = normalize(q(1,:));
q(2,:) = normalize(q(2,:));

% solve for the last three joints
% for any of the possible combinations (theta1, theta2, theta3)
for i=1:2:size(q,2),
    % use solve_spherical_wrist2 for the particular orientation
    % of the systems in this ABB robot
    % use either the geometric or algebraic method.
    % the function solve_spherical_wrist2 is used due to the relative
    % orientation of the last three DH reference systems.
    
    %use either one algebraic method or the geometric 
    %qtemp = solve_spherical_wrist2(robot, q(:,i), T, 1, 'geometric'); %wrist up
    qtemp = solve_spherical_wrist2(robot, q(:,i), T, 1,'algebraic'); %wrist up
    qtemp(4:6)=normalize(qtemp(4:6));
    q(:,i)=qtemp;
    
    %qtemp = solve_spherical_wrist2(robot, q(:,i), T, -1, 'geometric'); %wrist down
    qtemp = solve_spherical_wrist2(robot, q(:,i), T, -1, 'algebraic'); %wrist down
    qtemp(4:6)=normalize(qtemp(4:6));
    q(:,i+1)=qtemp;
end


 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% resuelve para la segunda articulaci???n theta2, dos soluciones diferentes
% son devueltas, codo arriba y codo abajo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q2 = solve_for_theta2(robot, q, Pm)

%Evaluaci???n de los parametros a partir del DH
d = eval(robot.DH.d);
a = eval(robot.DH.a);

%Toma la geometr???a correspondiente a la articulaci???n. 
L2=a(2);
L3=d(4);


%given q1 is known, compute first DH transformation
T01=dh(robot, q, 1);

%Expresa Pm en el sistema de referencia 1
p1 = inv(T01)*[Pm; 1];

r = sqrt(p1(1)^2 + p1(2)^2);

beta = atan2(-p1(2), p1(1));
gamma = (acos((L2^2+r^2-L3^2)/(2*r*L2)));

if ~isreal(gamma)
    disp('WARNING:inversekinematic_irb1600X_140: the point is not reachable for this configuration, imaginary solutions'); 
    %gamma = real(gamma);
end

%Devuelve dos posibles soluciones
q2(1) = pi/2 - beta - gamma; %codo arriba
q2(2) = pi/2 - beta + gamma; %codo abajo


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% resuelve para la tercera articulaci???n theta3, se devuelven dos posibles
% soluciones, codo arriba y codo abajo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function q3 = solve_for_theta3(robot, q, Pm)

%Evaluaci???n de los par???metros a partir del DH
d = eval(robot.DH.d);
a = eval(robot.DH.a);

%Toma la geometr???a
L2=a(2);
L3=d(4);

%Conociendo q1, calcula la primera transformaci???n DH
%given q1 is known, compute first DH transformation
T01=dh(robot, q, 1);

%Expresa Pm en el sistema de referencia 1
p1 = inv(T01)*[Pm; 1];

r = sqrt(p1(1)^2 + p1(2)^2);

eta = (acos((L2^2 + L3^2 - r^2)/(2*L2*L3)));

if ~isreal(eta)
   disp('WARNING:inversekinematic_irb1600X_140: the point is not reachable for this configuration, imaginary solutions'); 
   %eta = real(eta);
end

%Devuelve dos posibles soluciones, codo arriba y codo abajo, el orden es
%importante
q3(1) = pi/2 - eta;
q3(2) = eta - 3*pi/2;


