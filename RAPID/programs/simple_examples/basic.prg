%%%
VERSION:1
LANGUAGE:ENGLISH
%%%
! IN ORDER TO SIMULATE THE PROGRAM:
!   A) FIRST, LOAD A ROBOT
!       robot = load_robot('ABB','irb140');
!   B) NEXT, LOAD SOME EQUIPMENT.
!       robot.equipment = load_robot('equipment','tables/table_small');
!       OR
!       robot.equipment = load_robot('equipment','bumper_cutting');
!   C) NOW, LOAD AN END TOOL
!       robot.tool= load_robot('equipment','end_tools/parallel_gripper_0');
!   D) FINALLY, LOAD A PIECE TO GRAB BY THE ROBOT
!       robot.piece=load_robot('equipment','cylinders/cylinder_tiny');
!
!   E) IF NECESSARY, CHANGE THE POSITION AND ORIENTATION OF THE ROBOT'S
!   BASE
!       robot.piece.T0= [1 0 0 -0.35;
!                        0 1 0 -0.55;
!                        0 0 1 0.2;
!                        0 0 0 1]; 
!
! during the simulation, call simulation_open_tool; to open the tool and 
! simulation_close_tool; to close it.
! To grip the piece, call simulation_grip_piece; and
! simulation_release_piece to release it.
! The call to each function must be correct, thus, typically the correct
! sequence is:

! simulation_open_tool;
! approach the piece to grab.
! simulation_close_tool;
! simulation_grip_piece; --> the piece will be drawn with the robot
! move to a different place
! simulation_open_tool;
! simulation_release_piece

MODULE BASIC

PERS tooldata TD_gripper:=[TRUE,[[0,0,125],[1,0,0,0]],[0.1,[0,0,0.1],[1,0,0,0],0,0,0]];
CONST robtarget RT_tp1:=[[541,117,713],[0.727812,-0.115363,0.676004,-0.000468],[0,0,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
CONST robtarget RT_tp2:=[[515,-200,712],[0.7071,0,0.7071,0],[-1,-2,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
CONST robtarget RT_tp3:=[[515,0,912],[0.7071,0,0.7071,0],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
CONST robtarget RT_tp4:=[[515,0,512],[0.7071,0,0.7071,0],[0,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];


PROC main()

ConfJ \Off;
ConfL \Off;


MoveJ      RT_tp1    ,vmax      ,fine      ,TD_gripper\WObj:=wobj0     ;
MoveJ      RT_tp2    ,vmax      ,fine      ,TD_gripper\WObj:=wobj0     ;
MoveJ      RT_tp3    ,vmax      ,fine      ,TD_gripper\WObj:=wobj0     ;
MoveL      RT_tp4    ,vmax      ,fine      ,TD_gripper\WObj:=wobj0;
ENDPROC

ENDMODULE