% This script demonstrates an alternative definition of the target
% points defines the target points by separate fields 

% IN ORDER TO SIMULATE THE PROGRAM:
%   A) FIRST, LOAD A ROBOT
%       robot = load_robot('abb','irb140');
%   B) NEXT, LOAD SOME EQUIPMENT.
%       robot.equipment{1} = load_robot('equipment','tables/table_small');
%       OR
%       robot.equipment{1} = load_robot('equipment','bumper_cutting');
%   C) NOW, LOAD AN END TOOL
%       robot.tool= load_robot('equipment','end_tools/parallel_gripper_0');
%   D) FINALLY, LOAD A PIECE TO GRAB BY THE ROBOT
%       robot.piece=load_robot('equipment','cylinders/cylinder_tiny');
%
%   E) IF NECESSARY, CHANGE THE POSITION AND ORIENTATION OF THE ROBOT'S
%   BASE
%       robot.piece.T0= [1 0 0 -0.35;
%                        0 1 0 -0.55;
%                        0 0 1 0.2;
%                        0 0 0 1]; 
%
% during the simulation, call simulation_open_tool; to open the tool and 
% simulation_close_tool; to close it.
% To grip the piece, call simulation_grip_piece; and
% simulation_release_piece to release it.
% The call to each function must be correct, thus, typically the correct
% sequence is:

% simulation_open_tool;
% approach the piece to grab.
% simulation_close_tool;
% simulation_grip_piece; --> the piece will be drawn with the robot
% move to a different place
% simulation_open_tool;
% simulation_release_piece

function test_packaging
pieza_presente=1;
pieza_correcta=0;

simulation_open_tool;

% ningun eje externo conectado
ejes_ext = [9E9, 9E9, 9E9, 9E9, 9E9, 9E9];

% posicion y orientacion de reposo para el robot
pos_reposo = [0.5, 0.0, 0.35];
ori_reposo = [0.7071, 0.0, 0.7071, 0.0];
conf_reposo = [0, 0, -1, 1];
rob_reposo = [pos_reposo, ori_reposo, conf_reposo, ejes_ext];

%posicion y orientacion de agarre de la pieza sobre la cinta
pos_cinta = [0.7, 0.0, 0.35];
ori_cinta = [0.7071, 0.0, 0.7071, 0.0];
conf_cinta = [0, 0, -1, 1];
rob_cinta = [pos_cinta, ori_cinta, conf_cinta, ejes_ext];

  % posici�n y orientaci�n de descarga de pieza correcta
pos_correcta = [0.3, 0.4, 0.25];
ori_correcta = [0.4, -0.5, 0.5, 0.5];
conf_correcta = [0, 0, -1, 1];
rob_correcta = [pos_correcta, ori_correcta, conf_correcta, ejes_ext];
  
pos_defect = [0.3, -0.4, 0.25];
ori_defect = [0.4, 0.5, 0.5, -0.5];
conf_defect = [-1, -1, 0, 1];
rob_defect = [pos_defect, ori_defect, conf_defect, ejes_ext];

% herramienta utilizada (pinza)
pinza_robhold = 1;%TRUE;
pinza_tframe = [[0.0, 0.0, 0.120], [1, 0, 0, 0]];
pinza_tload = [1.5, [0.0, 0.0, 0.60], [1, 0, 0, 0], 0.01, 0.01, 0.01];
pinza = [pinza_robhold,pinza_tframe, pinza_tload];


simulation_open_tool;
%  PROC main()
MoveJ(rob_reposo,'vmax','z5', pinza, 'wobj0');%v200

% espera hasta tener una pieza disponible
%    WaitDI pieza_presente, 1;

% desplazamiento hacia la pieza, lento y con maxima precision
MoveL(rob_cinta,'vmax','z5', pinza,  'wobj0');%v50

simulation_grip_piece;
simulation_close_tool;
% activa pinza y espera 1 segundos
%Set(do1);
WaitTime(1);
    
if (pieza_correcta==1)
    % desplazamiento a caja piezas correctas, rapido y poco preciso
     MoveL(rob_correcta, 'vmax', 'z5', pinza,  'wobj0'); %v200

else
      % desplazamiento a caja piezas defectuosas, rapido y poco preciso
      MoveL(rob_defect, 'vmax', 'z5', pinza,  'wobj0'); %v200
end

simulation_open_tool;
simulation_release_piece;

% se abre la pinza y se esperan dos segundos
%Reset(cerrar_pinza);
WaitTime(1);
    
