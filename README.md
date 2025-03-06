In Vivado 2024.2, it is recommended to go along with the following flow to do timing closure for Versal-based design.
![ADF](https://github.com/user-attachments/assets/d4e33cc5-00de-4afe-97f0-c5f61a452400)
The tcl scripts contain 3 commands to run each stage respectively. Here are some steps to use these commands.
Step 1: Create Vivado project and run the following command in Vivado tcl console.

source vtc_2.3.tcl

Step 2: No matter what type of the project is, RTL-based or post-synthesis, then run the following command.

vtc::run_stage1 

This command will create 3 implementation runs, just like the figure below.

![1](https://github.com/user-attachments/assets/f852b34d-bfb8-4f41-93ef-768c5f6b8f50)

If the project is a RTL-based project, then the option -parent can be set to specify the parent run of the implementation run.

vtc::run_stage1 -parent synth_2 

If the project is a post-synthesis project and the source file is a post-opt dcp, then the option -opt_design_en can be set to 0.

vtc::run_stage1 -opt_design_en 0

![2](https://github.com/user-attachments/assets/5f8762bf-49fc-47cf-91de-0f174a7c7f7c)

Besides, by setting the values of -ndw, you can create more runs. For instance, if -ndw is set to mh, then 6 runs will be created.

vtc::run_stage1 -ndw mh -opt_design_en 0 

![3](https://github.com/user-attachments/assets/c0f7bd55-db61-4aaf-9ed9-74294651b387)

In some scenarios, developers make sure the implementation strategy 'Default' will not be the best run. Then Performance_Explore and
Performance_AggressiveExplore can be specified by setting the option -id to '12'. The command below will create 4 implementation runs.

![4](https://github.com/user-attachments/assets/6d8b4ac6-d778-4812-8cdc-658e2d101311)

Step 3: Get the best run from stage 1 and choose different subdirectives.
This can be done by the command vtc::run_stage2. Let's take the following picture as an example.

![5](https://github.com/user-attachments/assets/849ac435-1a8c-4b2b-a0ce-be15594a2c17)

It is clear that impl_01_S1_06 is the best run. By running the command below, we can get more detailed message and create 10 implementation runs.

vtc::run_stage2 -level both

Here 'both' means 'med' and 'high' are enabled for subdirectives with different values, like ReducePinDensity which has 3 values low, med and high.

The command above will print both timing metrics and implementation settings like figures below.

![6](https://github.com/user-attachments/assets/8d5d9117-1e6f-4def-8c17-b570f01154e0)
![7](https://github.com/user-attachments/assets/0d15f1e5-6eca-4d70-8b5f-4363ce2bf50a)

Also, valid subdirectives for place_designed are printed. 

![8](https://github.com/user-attachments/assets/bfa245a0-5045-4b5d-9fe9-afa6a9b6219e)

10 runs are created. 

![9](https://github.com/user-attachments/assets/c4507781-9af9-4603-abba-11ba9d53bde9)

-net_delay_weight: All these 10 runs have same values with the best run, but it can be changed by setting the value of -ndw.
For example:

vtc::run_stage2 -ndw mh -level high

This command will create 14 implementation runs. 

![10](https://github.com/user-attachments/assets/9a57522f-d4c2-4f9b-a609-d53f0c65f2d0)

If you don't want to use the best run automatically captured by the command, you can manually specify the expected run no matter what status
it is, 'running' or 'Not started'. In this situation, only a single run can be specified. 

vtc::run_stage2 -ref_run impl_01_S1_05 -ndw mh -level both

Since the place_design -directive of impl_01_S1_05 is Explore, then the ExtraTimingOpt will be chosen.

![11](https://github.com/user-attachments/assets/b1845111-c867-4588-a021-2fb8517637ed)

![12](https://github.com/user-attachments/assets/2420ba5b-c5b4-4db9-b6a4-7c992f674ef5)

Step 4: Get the best run from stage 2 and add more subdirectives
If the best run in stage 2 is impl_01_S2_06 whose subdirective is  Floorplan.WLDrivenBlockPlacement GPlace.WLDrivenBlockPlacement, then run the following command and 5 runs will be created.

vtc::run_stage3 -ref_run impl_01_S2_06

![13](https://github.com/user-attachments/assets/4e43c4cf-964e-41b7-b997-4d4bdc99b586)

![14](https://github.com/user-attachments/assets/a80d022a-15f6-42a1-a6ff-27db53a397e4)

Actually, you can continue to run the command run_stage3 to add more subdirectives. For example, if the best run in stage 3 is impl_01_S3_05 whose subdirective is 
Floorplan.WLDrivenBlockPlacement GPlace.WLDrivenBlockPlacement Gplace.EarlyBlockPlacement. Then run the following command and 4 implementation runs will be created.

vtc::run_stage3 -ref_run impl_01_S3_05

![15](https://github.com/user-attachments/assets/382a98d9-c116-441d-8c50-106b44382d9f)

![16](https://github.com/user-attachments/assets/2c85f523-e6e0-4675-b732-af3df9a46cc8)

If you want to check the implementation settings for the specified runs, you can run the following command.

vtc::print_impl_run_settings [get_runs impl_02_S3*]

A table will be displayed in Vivado Tcl Console and a csv file will also be created at the same time. 

![17](https://github.com/user-attachments/assets/af377453-ba11-41dd-a4de-9dfd202abd98)

If you want to compare the timing metrics among specified runs, you can run the following command.

vtc::print_timing_info  [get_runs impl_02_S3*]

Both a table and csv file are created. 

![18](https://github.com/user-attachments/assets/5447a9ad-e8d2-4c41-a41a-c6fa1b4b8557)





















