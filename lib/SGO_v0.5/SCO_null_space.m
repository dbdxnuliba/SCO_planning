
function [pk, final_manip] = SCO_null_space(robot)
%global robot
global parameters
global hfigures
 hfigures.hrobot = figure;
 hfigures.hpaths = figure;
 hfigures.hcosts = figure;
% hfigures.hee = figure;
% hfigures.htheta = figure;
 hfigures.hbest_costs = figure;
% hfigures.hdtheta = figure;

%line_work = [p0 pf];
%N waypoints at each trajectory
N = parameters.N;
%K particles
K = parameters.K;

%pathT = build_initial_path();%diferent T matrix forming the trajectory

%generate K different paths
%starting from arbitrary positions.
manips=[];
for k=1:K
  q0 = uniform(-pi, pi, 1, robot.DOF)';
  [pathq, pathT] = plan_path_moore_penrose(robot, q0);
  %generate particle
  G{k}.pathq = pathq;
  G{k}.pathT = pathT;
  manip = compute_manip(robot, pathq);
  manipsum=sum(manip);
  manips=[manips manipsum];
end

%pick the maximum manipulability one to compare with the result
[val, index]=max(manips);
initial_manip=compute_manip(robot, G{index}.pathq);

%animate best particle
animate_local(robot, G{index}.pathq)

figure,
plot(G{index}.pathq')
xlabel('Waypoints')
ylabel('Angle')
title('IK non-optimized path')

i=0;
best_probs = [];
%Main loop
%till convergence of trajectory cost function
while i < 20
    i=i+1;
    G = add_noise_to_particle_set(G, pathT);
    
    %best particle
    fprintf('Iteration No: %d\n', i)
    [pk, best_prob] = best_particle(G);
    best_probs = [best_probs, best_prob];
    plot_info(G, pk, best_probs, i)
end

%plot particle info
best_particle_info(pk)
figure, 
plot(best_probs)
xlabel('Iteration')
title('best PROB at each iteration (sum of probs-weights along trajectory)')
%animate best particle
animate_local(robot, pk.pathq)
final_manip = compute_manip(robot, pk.pathq);

figure, hold
plot(initial_manip)
plot(final_manip)
legend('Non-opt','Opt')
title('Manipulabilities for optimized and initial trajectory')
xlabel('Waypoints')


figure, hold
title('Manipulability for best candidate in each iteration')
xlabel('Waypoints')
for k=1:K
    plot(compute_manip(robot, G{k}.pathq))
end

% function plot_particles_costs(G)
% K = size(G,2);
% figure, hold
% for k=1:K
%   pk = G{k};
%   plot(pk.P)
% end
% title('Probabilities')



function plot_info(G, best_pk, best_probs, iter)
global hfigures parameters
K = size(G,2);
figure(hfigures.hpaths),
title('Robot articular configuration for each trajectory position')
str = sprintf('Trajectory point (Iteration %d)', iter);
xlabel(str)
ylabel('Angle (Degrees)')
clf
%hold on


pp=[];
for k=1:K
    pk = G{k};
    plot(pk.pathq')
    pp(k) = sum(pk.P);
end

figure(hfigures.hcosts)
plot(sort(pp))
title('Sum of probabilities for all candidates')
str = sprintf('Candidate (Iteration %d)', iter);
xlabel(str)
ylabel('prob-weights')

figure(hfigures.hbest_costs), clf, hold on
plot(best_probs)
title('Best trajectory probability at each time step (sum of prob-weights)')
    

function best_particle_info(pk)
figure,
title('Joint Values of Best Trajectory')
xlabel('Waypoints')
subplot(7,1,1)
plot(pk.pathq(1,:))
title('q1')
subplot(7,1,2)
plot(pk.pathq(2,:))
title('q2')
subplot(7,1,3)
plot(pk.pathq(3,:))
title('q3')
subplot(7,1,4)
plot(pk.pathq(4,:))
title('q4')
subplot(7,1,5)
plot(pk.pathq(5,:))
title('q5')
subplot(7,1,6)
plot(pk.pathq(6,:))
title('q6')
subplot(7,1,7)
plot(pk.pathq(7,:))
title('q7')

figure, 
plot(pk.P)
xlabel('Waypoints')
ylabel('Prob-Weight')
title('Prob at traj. point of best particle SHOULD BE >0')

figure,
plot(pk.pathq')
xlabel('Waypoints')
ylabel('Angle')
title('BEST PARTICLE PATH')


function animate_robot(pk)
global robot
N = size(pk.path,2);
for i=1:N
   qi = pk.path(:,i);
   drawrobot3d(robot, qi)
end

%generate a prior path for the particles
function path = generate_path(robot, q0, qN, N)
deltaq=(qN-q0)/(N-1);
path = [];
for i=0:N-1
    qi = q0 + i*deltaq;
    path = [path qi];
    %drawrobot3d(robot, qi)
end


function mcost = mean_cost(G)
pk = G{1};
K = size(G,2);
N = size(pk.path,2);
cc = [];
for k=1:K
    pk = G{k};
    cc(k) = sum(pk.costs);
end
mcost = mean(cc);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBTAIN the best particle according to the defined cost function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pk, best_prob] = best_particle(G)
%global robot
pk = G{1};
K = size(G,2);
N = size(pk.pathq,2);
probs = [];

for k=1:K
    pk = G{k};
    probs(k) = sum(pk.P);
end
%we must minimize costs
%[val, index]=min(costs);
%alternatively maximize our defined weigths
[val, index]=max(probs);
fprintf('Best particle is index: k=%d\n', index)
pk = G{index};
best_prob = val;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute cost function to encode manipulability.
% Return:
% P: likelihood function
% q: the cost function it self
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [P, cost] = cost_function_manipulability(q)
global robot parameters
%compute nil-space!!
% J = manipulator_jacobian(robot, q);
% % moving on vx, vy and wz!!!
% J = [J(1:2,:); J(6,:)];
%manip = sqrt(det(J*J'));
manip = compute_manip(robot, q);
%define cost: cost is lower as manipulability is higher
cost = 1/(manip+0.01);
lambda = parameters.lambda_manip;
%return likelihood
P = exp(-(1/lambda)*cost);




function V = compute_link_velocity_1(theta, thetad)
V = 1*thetad(1)^2;

function V = compute_link_velocity_2(theta, thetad)
th1 = theta(1);
th2 = theta(2);

J = [-sin(th1)  -sin(th1+th2);
    cos(th1)    cos(th1+th2)];
V = J*[thetad(1) thetad(1)+thetad(2)]';
V = norm(V);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate a noisy particle set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G=generate_initial_particle_set(K, path)
for k=1:K
    G{k} = generate_particle(path);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a path for each particle without noise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pk = generate_particle(path)
global robot
%each path is in each row for qi
DOF = robot.DOF;
for i = 1:DOF
    pk.path(i,:) = path(i,:); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add noise to the
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G=add_noise_to_particle_set(G, pathT)
K = size(G,2);
%for every particle in the set
for k=1:K
    pk = G{k};
    pathT = pk.pathT;
    pk = add_noise_to_particle_null_space(pk, pathT);
    G{k} = pk;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !! Add noise along the null space!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pk = add_noise_to_particle_null_space(pk, pathT)
global parameters robot
N = size(pk.pathq, 2);
%each path is in each row for qi
DOF = robot.DOF;

% at each particle add some noise!
%move along the path of the particle
for i = 1:N
    %current joint position
    q1 = pk.pathq(:,i);
    %generate some samples along the nulls space
    qq = sample_from_null_space(q1);
    %populate with the current pose!!!
    qq = [qq q1];
    p = [];
    costs = [];
    %for all the new samples!
    for j=1:size(qq,2)
        %weight the samples,
        %compute cost of obstacles and manipulability
        [Pm, costm] = cost_function_manipulability(qq(:,j));
        if robot.DOF == 4
            [Po] = cost_function_distance_4dof(qq(:,j));
        else
            %[Po] = cost_function_distance_7dof(qq(:,j));
        end
        %p(j)=Pm*Po;
        p(j)=Pm;
        
    end
    %select the best one
    %from the sample performed based on probability
    %max probatility!
    [prob, index] = max(p);
    q = qq(:,index);
    pk.pathq(:,i) = q;
    %and current probability
    pk.P(i) = prob;
end

%obtain samples from the null space
%near to q
function qq=sample_from_null_space(q1)
global robot
global parameters
%sigma_noise = parameters.noise_sigma_null_space;
alpha = parameters.alpha;
time_step = parameters.step_time;

q = q1;
the = 0;
qq=[];
%sigma_noise = 0.3;
%alpha = mvnrnd(0, sigma_noise);
%alpha = 0.3;
ss = +1;
%iterate at each time step: forward movement
while the < abs(alpha)
    %compute null_space
    if robot.DOF==4
        qdnull = null_space_4dof(robot, q);
    else
        qdnull = null_space_7dof(robot, q);
    end
    if norm(qdnull) < 0.01
        break
    end
    qdnull = qdnull/norm(qdnull);
    dq = ss*time_step*qdnull;
    the = the + norm(dq);
    q = q  + dq;
    qq = [qq q];
end

ss = -1;
q = q1;
the = 0;
%backward movement
while the < abs(alpha)
    %compute null_space
        %compute null_space
    if robot.DOF==4
        qdnull = null_space_4dof(robot, q);
    else
        qdnull = null_space_7dof(robot, q);
    end
    if norm(qdnull) < 0.01
        break
    end
    qdnull = qdnull/norm(qdnull);
    dq = ss*time_step*qdnull;
    the = the + norm(dq);
    q = q  + dq;
    qq = [qq q];
end





