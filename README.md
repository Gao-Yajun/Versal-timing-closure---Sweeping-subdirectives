In Vivado 2024.2, it is recommended to go along with the following flow to do timing closure for Versal-based design.
![Screenshot 2025-03-18 105251](https://github.com/user-attachments/assets/7906d009-9fd7-410e-98a3-e5804bf2e722)
The tcl scripts contain 3 commands to run each stage respectively. Here are some steps to use these commands.

Step 1: Create Vivado project and run the following command in Vivado tcl console.

source vtc_2.4.tcl

Step 2: Run the following command
vtc::run_stage1
The usage of this command is as follows. 
 run_stage1
    Description: 
    Run stage 1 for Versal timing closure. In this stage, there will be 3 runs created.
    More runs can be created by setting -ndw with lmh or mh.

    Syntax:
    run_stage1 [-parent] [-ndw] [-id]
    run_stage1 [-opt_design_en] [-ndw] [-id]

    Usage: 
      Name                          
      [-parent]        Only for RTL-based project, set the parent run for impl run.
                       Default value: synth_1
      [-opt_design_en] Enable opt_design or not. 1: enable, 0: Disable
                       Only for post-synthesis project with post-opt dcp as source file. 
                       Defalut value: 1
                       if -parent is set, this opiton will be ignored.
      [-ndw]           Set the value of -net_delay_weight of placement.
                       Legal values are single letter of <l m h> or <L M H>.
                       The combination of these letters are also acceptable.
                       For example: lmh lm mh
                       Default value: l
      [-id]            Index of strategies that need to run.
                       0 -> Default, 1 -> Performance_Explore, 2 -> Performance_AggressiveExplore
                       The combination of 0/1/2 is acceptable, like 01 or 12.
                       Default value: 012

    Example:
      RTL-based project: 
      vtc::run_stage1 -parent synth_1 -ndw lmh
      Post-syntheis project:
      vtc::run_stage1 -ndw lmh -opt_design_en 0 

Step 3: If the timing is not closed, then enter the stage 2 and run the following command
vtc::run_stage1.
The usage of this command is as follows.

  run_stage2
    Description: 
    Run stage 2 for Versal timing closure. In this stage, some impl runs will be created. The number of runs depends
    on the option setting. 

    Syntax:
    run_stage2 [-ref_run] [-ndw] [-balanced_slr] [minwhs] [is_pb_ready]

    Usage: 
      Name                          
      [-ref_run]       Reference run for stage 2.  
                       Default value: *S1*
      [-ndw]           Set the value of -net_delay_weight of placement.
                       Legal values are single letter of <l m h> or <L M H>.
                       The combination of these letters are also acceptable.
                       For example: lmh lm mh
                       Default value: same with the best run from reference run in stage 1. 
      [-balanced_slr]  When subdirective is BalancedSLR, the candidate values are low, med and high 
                       Legal values are single letter of <l m h> or <L M H>.
                       The combination of these letters are also acceptable.
                       For example: lmh lm mh
                       l | L -> low, m | M -> med, h | H -> high
                       Default value: h
      [-minwhs]        Set the minimum WHS when getting the best run.
                       Default value: 0.0 
      [-is_pb_ready]   0 or 1, for SSI devices 1 means drawing pblock has been done, so the subdirective BalancedSLR will be ignored.
                       0 implies the subdirective BalancedSLR will be valid.
                       Default value: 1

    Example:
      #Set ndw to medium and high
      vtc::run_stage2 -ndw mh
      #Set minwhs to -0.1
      vtc::run_stage2 -ndw mh -minwhs -0.1
      #Set is_pb_ready to 0
      vtc::run_stage2 -ndw mh -minwhs -0.1 -is_pb_ready 0
      #Set is_pb_read to 0, balanced_slr to lmh 
      vtc::run_stage2 -ndw mh -minwhs -0.1 -is_pb_ready 0 -balanced_slr mh

Step 4: If the timing is not closed yet, then enter the stage 3 and run the following command.
vtc::run_stage3
The usage of this command is as follows.
run_stage3
    Description: 
    Run stage 3 for Versal timing closure. In this stage, some impl runs will be created. The number of runs depends
    on the option setting. 

    Syntax:
    run_stage3 [-ref_run] [-ndw] [-level] [minwhs] [is_pb_ready]

    Usage: 
      Name                          
      [-ref_run]     Reference run for stage 2.  
                     Default value: *S2*
      [-ndw]         Set the value of -net_delay_weight of placement.
                     Legal values are single letter of <l m h> or <L M H>.
                     The combination of these letters are also acceptable.
                     For example: lmh lm mh
                     Default value: same with the best run from reference run in stage 1. 
      [-level]       med, high, both 
                     If there are two values for subdirectives (med and high), the -level is used to control which one is 
                     applied to current impl run.
                     Default value: high
      [-minwhs]      Set the minimum WHS when getting the best run.
                     Default value: 0.0 
      [-is_pb_ready] 0 or 1, for SSI devices 1 means drawing pblock has been done, so the subdirective BalancedSLR will be ignored.
                     0 implies the subdirective BalancedSLR will be valid.
                     Default value: 1

    Example:
      #Set ndw to medium and high
      run_stage3 -ndw mh
      #Set minwhs to -0.1
      run_stage3 -ndw mh -minwhs -0.1
      #Set is_pb_ready to 0
      run_stage3 -ndw mh -minwhs -0.1 -is_pb_ready 0

You can continue to run stage 3 and then more subdirectives will be combined.

Here is an example by using this Tcl script.

![1](https://github.com/user-attachments/assets/8056ed73-1724-44f4-ba51-b0025c205640)

By running the following comand, you can print implementation settings for specified runs. A csv file will alos be created. 

vtc::print_impl_run_settings [get_runs]

![2](https://github.com/user-attachments/assets/4e5aad81-f743-4aed-a3c2-ed9e1abd72ca)


By running the following comand, you can print timing information in each step like opt_design, place_design, etc. of specified runs. A csv file will also be created. 

vtc::print_timing_info [get_runs]

![3](https://github.com/user-attachments/assets/97ca58f2-9b3f-432a-90c9-0223810b61e6)











