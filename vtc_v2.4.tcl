###################################################################################################################################################
# File: vtc.tcl
# Author: Lauren Gao
# Company: AMD
# Description: Versal timing closure using ADF
# Step:
# 1) Create Vivado project: RTL-based design or post-synthesis design
# 2) Specify a valid impl run
# 3) Run command: source vtc.tcl 
# 4) vtc::run_stage1
# 5) vtc::run_stage2
# 6) vtc::run_stage3
###################################################################################################################################################
namespace eval vtc {
  # Get Vivado version
  variable VivadoVersion [version -short]
  # Report strategy in stage 1
  variable rptStrtg {UltraFast Design Methodology Reports}
  # Impl strategy in stage 1
  variable s1Strtg {"Vivado Advanced Implementation Defaults" "Performance_Explore" "Performance_AggressiveExplore"} 
  # Arguments of the command run_stage1
  variable s1Args {
    {parent.arg        synth_1 "Parent run"                }
    {opt_design_en.arg 1       "Enable opt_design or not"  }
    {ndw.arg           l       "Values of net_delay_weight"}
    {id.arg            012     "Index of strategy"         }
  }
  # Usage of the command run_stage1
  variable s1Usage { \
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
  }
    
  # Arguments of the command run_stage2
  variable s2Args {
    {ref_run.arg      *S1* "Runs in stage 1"}
    {ndw.arg          ""   "Values of net_delay_weight"}
    {minwhs.arg       0.0  "Set the minimum WHS when getting the best run"}
    {balanced_slr.arg h    "Set the value for subdirective BalancedSLR"}
    {is_pb_ready.arg  1    "For SSI devices drawing pblock has been done"}
  }
  # Usage of the command run_stage2
  variable s2Usage { \
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
  }

  # Arguments of the command run_stage3
  variable s3Args {
    {ref_run.arg     *S2* "Runs in stage 1"}
    {ndw.arg         ""   "Values of net_delay_weight"}
    {level.arg       h    "Choose the value to high for subdirective"}
    {minwhs.arg      0.0  "Set the minimum WHS when getting the best run"}
    {is_pb_ready.arg 1    "For SSI devices drawing pblock has been done"}
  }
  # Usage of the command run_stage3
  variable s3Usage { \
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
  }
  # Part number of current project
  variable curtPart [get_property PART [current_project]]
  # Num of SLRS of current part
  variable numSlr [get_property SLRS [get_parts $curtPart]]
  # Available subdirectives of place_design in Vivado 2024.2
  variable placeSubdir [dict create]
  # dict set placeSubdir RuntimeOptimized {
  #  Phase {Floorplan GPlace DPlace}
  #  Value {}
  #}
  #dict set placeSubdir ExtraTimingUpdate {
  #  Phase {Floorplan GPlace DPlace}
  #  Value {}
  #}
  dict set placeSubdir ExtraTimingOpt {
    Phase {Floorplan GPlace DPlace}
    Value {low med high}
  }
  dict set placeSubdir BalancedSLR {
    Phase {Floorplan}
    Value {low med high}
  }
  dict set placeSubdir ForceSpreading {
    Phase {Floorplan GPlace}
    Value {low med high}
  }
  dict set placeSubdir ReduceCongestion {
    Phase {GPlace}
    Value {low med high}
  }
  dict set placeSubdir WLDrivenBlockPlacement {
    Phase {Floorplan GPlace}
    Value {}
  }
  dict set placeSubdir ReducePinDensity {
    Phase {DPlace}
    Value {low med high}
  }
  dict set placeSubdir EarlyBlockPlacement {
    Phase {Gplace}
    Value {}
  }
  variable s2CandidateSubdir {WLDrivenBlockPlacement EarlyBlockPlacement BalancedSLR}
  # find_free_run_name 
  # pattern: impl_
  # stage: S1, S2, S3
  # tail: 01
  # Legal candidate of subdirectives for stage 2
  # variable s2Subdir {ExtraTimingUpdate WLDrivenBlockPlacement EarlyBlockPlacement ForceSpreading}
  # Find free name in current context
  proc find_free_run_name {pattern stage tail} {
    set id 1
    while {1} {
      if {$id<10} {
        set index 0${id}
      } else {
        set index $id
      }
      set newName "${pattern}_${index}_${stage}_${tail}"
      set obj [get_runs -quiet $newName] 
      if {[llength $obj]==0} { 
        puts "####INFO: impl run name -> $newName"
        break 
      }
      incr id
    }
    return $newName
  }
 
  # check_version
  # Check if Vivado version is legal (2024.2 or later) 
  proc check_version {} {
    variable VivadoVersion
    set v1 [string range $VivadoVersion 0 5]
    if {$v1<2024.2} {
      return -code error "####ERROR: Vivado version should be 2024.2 or later"
    } else {
      puts "####INFO: Vivado version: $VivadoVersion"
    }
  }
 
  # get_cletter 
  # Get the capital letter from the given string
  proc get_cletter {str} {
    set strLen [string length $str]
    set cList {}
    for {set i 0} {$i<$strLen} {incr i} {
      set c [string index $str $i]
      if {[regexp {[A-Z]} $c]} {
        lappend cList $c
      }
    }
    set cListLen [llength $cList]
    for {set i 0} {$i<$cListLen} {incr i} {
      append cstr [lindex $cList $i]
    }
    return $cstr
  }

  # get_short_name
  # Get the short name for subdirective: Floorplan.ExtraTimingOpt.high -> F.ETO.high
  # sd: subdirective
  # Test: get_short_name {Floorplan.ExtraTimingOpt.high GPlace.WLDrivenBlockPlacement Gplace.EarlyBlockPlacement DPlace.ReducePinDensity.low}  
  # F.ETO.high GP.WLDBP G.EBP DP.RPD.low
  proc get_short_name {sd} {
    foreach i_sd $sd {
      set sdChild [split $i_sd .]
      set sdChildCount [llength $sdChild]
      set sdChild0 [lindex $sdChild 0]
      set shortName {}
      switch -exact -- $sdChild0 {
        Floorplan { lappend shortName F }
        GPlace -
        Gplace    { lappend shortName G }
        DPlace -
        Dplace    { lappend shortName D }
      }
      lappend shortName [get_cletter [lindex $sdChild 1]]
      if {$sdChildCount==3} {
        lappend shortName [lindex $sdChild end]
      }
      lappend shortNameStr [join $shortName .]
    }
    return $shortNameStr
  }

  # print_impl_run_settings
  # Print impl run settings
  # runName: names of impl run
  # stage: S1 S2 S3
  # S1: no subdirective
  # S2 and S3: subdirectives are available
  proc print_impl_run_settings {runName {stage S2}} {
    set implRun [get_runs $runName]
    set implRunLen [list $implRun]
    if {$implRunLen==0} {
      return -code error "####ERROR: No Run Available"
    }
    set steps {OPT_DESIGN PLACE_DESIGN PHYS_OPT_DESIGN ROUTE_DESIGN POST_ROUTE_PHYS_OPT_DESIGN}
    set ppt {}
    foreach i_steps $steps {
      if {[string equal $i_steps OPT_DESIGN]} {
        lappend ppt STEPS.OPT_DESIGN.IS_ENABLED
        lappend ppt STEPS.OPT_DESIGN.ARGS.DIRECTIVE
      } elseif {[string equal $i_steps PLACE_DESIGN]} {
        lappend ppt STEPS.PLACE_DESIGN.ARGS.DIRECTIVE
        if {[string equal $stage S1]==0} {
          lappend ppt STEPS.PLACE_DESIGN.ARGS.SUBDIRECTIVE
        }
        lappend ppt STEPS.PLACE_DESIGN.ARGS.NET_DELAY_WEIGHT
        lappend ppt STEPS.PLACE_DESIGN.ARGS.CLOCK_VTREE_TYPE
      } elseif {[regexp {(POST_ROUTE_)?PHYS_OPT_DESIGN} $i_steps]} { 
        lappend ppt STEPS.${i_steps}.IS_ENABLED
        lappend ppt STEPS.${i_steps}.ARGS.DIRECTIVE
      } elseif {[string equal $i_steps "ROUTE_DESIGN"]} {
        lappend ppt STEPS.${i_steps}.ARGS.DIRECTIVE
        if {[string equal $stage S1]==0} {
          lappend ppt "STEPS.${i_steps}.ARGS.MORE OPTIONS"
        }
      } else {
        lappend ppt STEPS.${i_steps}.ARGS.DIRECTIVE
      }
    }
    if {[string equal $stage S1]==1} {
      set pptName {opt_design_en opt_design place_design net_delay_weight clock_vtree_type \
        post_phys_opt_en phys_opt_design route_design post_route_phys_opt_en phys_opt_design}
    } else {
      set pptName {opt_design_en opt_design place_design place.subdirective net_delay_weight clock_vtree_type \
        post_phys_opt_en phys_opt_design route_design MoreOptions post_route_phys_opt_en phys_opt_design}
    }
    set tb [xilinx::designutils::prettyTable]
    set header [list ID Runs {*}$pptName]
    $tb header $header
    set id 0
    foreach i_implRun $implRun {
      set tmp {}
      foreach i_ppt $ppt {
        set pptv [get_property $i_ppt $i_implRun]
        if {[string match {*MORE OPTIONS} $i_ppt]} {
          set pptv [string range $pptv 1 end]
        } elseif {[string match {*SUBDIRECTIVE} $i_ppt]} {
          if {[llength $pptv]>0} {
            set pptv [get_short_name $pptv]
          } else {
            set pptv ""
          }
        }
        lappend tmp $pptv
      }
      set row  [list [expr {$id+1}] $i_implRun {*}$tmp]
      $tb addrow $row
      incr id
    }
    puts [$tb print]
    puts "INFO: Table of impl settings is successfully created"
    set dir [get_property DIRECTORY [current_project]]
    cd $dir
    set systemTime [clock seconds]
    set fnTail [clock format $systemTime -format %d_%m_%Y_%H%M%S]
    puts "####INFO: The time is: [clock format $systemTime -format %d_%m_%Y_%H%M%S]"
    set fn impl_settings_${fnTail}.csv
    $tb export -format csv -file $fn
    set p [file normalize $fn]
    set str "####INFO: file location -> $p"
    set strLen [string length $str]
    puts [string repeat # $strLen]
    puts "####INFO: $fn is successfully exported"
    puts "####INFO: file location -> $p"
    puts [string repeat # $strLen]
  }

  # ndw2str
  # Convert values to string
  # l|L -> low, m|M -> medium, h|H -> high
  proc ndw2str {ndw} {
    set v {}
    set strLen [string length $ndw]
    if {$strLen>3} {
      return -code error "####ERROR: input string length should less than 4"
    }
    for {set i 0} {$i<$strLen} {incr i} {
      set c [string index $ndw $i]
      if {[regexp {[LMHlmh]} $c]} {
        switch -exact -- $c {
          l -
          L { lappend v low }
          m -
          M { lappend v medium }
          h -
          H { lappend v high }
        }
      } else {
        return -code error "####ERROR: valid letters are l,L,m,M,h and H"
      }
    }
    set v [lsort -unique $v]
    return $v
  }

  proc value_short2long {val} {
    set strLen [string length $val]
    if {$strLen>3} {
      return -code error "####ERROR: input string length should less than 4"
    }
    for {set i 0} {$i<$strLen} {incr i} {
      set c [string index $val $i]
      if {[regexp {[LMHlmh]} $c]} {
        switch -exact -- $c {
          l -
          L { lappend v low }
          m -
          M { lappend v med }
          h -
          H { lappend v high }
        }
      } else {
        return -code error "####ERROR: valid letters are l,L,m,M,h and H"
      }
    }
    set v [lsort -unique $v]
    return $v
  }

  proc get_target_strategy {id inList} {
    if {[string is digit $id]==0} {
      return -code error "####ERROR: index must be digit"
    } else {
      set outList {}
      set idLen [string length $id] 
      for {set i 0} {$i<$idLen} {incr i} {
        set idx [string index $id $i]
        if {$i>2} {
          return -code error "####ERROR: index must be less than 2"
        } else {
          lappend outList [lindex $inList $idx]
        }
      }
      puts "####INFO: get target strategies -> $outList"
      return $outList
    }
  }

  proc remove_duplicates {str} {
    set seen [dict create]  
    set result ""          
    foreach char [split $str ""] {
      if {![dict exists $seen $char]} {
        dict set seen $char 1  
        append result $char
      }
    }
    return $result
  }
  # run_stage1
  # run_stage1 -parent synth_2
  # run_stage1 -opt_design_en 0
  # run_stage1 -ndw lmh
  # run_stage1 -parent synth_2 -ndw mh
  proc run_stage1 {args} {
    variable rptStrtg 
    variable s1Args
    variable s1Usage
    array set params [::cmdline::getoptions args $s1Args $s1Usage]
    #array set params [::cmdline::getoptions args $s1Args]
    puts "####INFO: parameters array displayed as follows"
    parray params
    set synRun $params(parent)
    puts "####INFO: -parent -> $synRun"
    set ndw    $params(ndw)
    puts "####INFO: -ndw -> $ndw"
    set enOpt  $params(opt_design_en)
    puts "####INFO: -opt_design_en -> $enOpt"
    set ids    $params(id)
    puts "####INFO: -id -> $ids"
    variable VivadoVersion
    variable s1Strtg
    check_version
    set vL [split $VivadoVersion .]
    set year [lindex $vL 0]
    set availSynRun [get_runs -filter {IS_SYNTHESIS} -quiet]
    set numAvailSynRun [llength $availSynRun]
    # Set acceptable values for NET_DELAY_WEIGHT 
    set ndw [ndw2str $ndw]
    puts "####INFO: -net_delay_weight -> $ndw"
    set idsCheck [remove_duplicates $ids]
    puts "####INFO: -id -> $idsCheck"
    set targetStrtg [get_target_strategy $idsCheck $s1Strtg]
    puts "####INFO: target impl strategy -> $targetStrtg"
    set id 1
    set s1Runs {}
    if {$numAvailSynRun>0} {
      set synRun [get_runs $synRun]
      if {[llength $synRun]>0} {
        puts "####INFO: Parent run of all impl runs -> $synRun"
        if {$enOpt==0} {
          puts "####WARNING: This is a RTL-based project, so -opt_design_en is ignored"
        } 
        foreach i_ndw $ndw {
          foreach i_strtg $targetStrtg {
            if {$id<10} {
              set tail 0${id}
            } else {
              set tail $id
            }
            set runName [find_free_run_name impl S1 $tail] 
            create_run $runName -parent_run $synRun -flow "Vivado Advanced Implementation $year" -strategy "$i_strtg"
            set_property STEPS.PLACE_DESIGN.ARGS.NET_DELAY_WEIGHT $i_ndw [get_runs $runName] 
            set_property report_strategy $rptStrtg [get_runs $runName]
            puts "####INFO: [get_runs $runName] is successfully created"
            puts "####INFO: $runName -> Strategy -> $i_strtg"
            puts "####INFO: $runName -> NET_DELAY_WEIGHT -> $i_ndw"
            puts "####INFO: $runName -> Report strategy -> $rptStrtg"
            puts "####INFO: $runName settings done"
            incr id
            lappend s1Runs $runName
          }
        }
      } else {
        return -code error "####ERROR: No valid syn run specified"
      }
    } else {
      foreach i_ndw $ndw {
        foreach i_strtg $targetStrtg {
          if {$id<10} {
            set tail 0${id}
          } else {
            set tail $id
          }
          set runName [find_free_run_name impl S1 $tail] 
          create_run $runName -flow "Vivado Advanced Implementation $year" -strategy "$i_strtg"
          set_property STEPS.PLACE_DESIGN.ARGS.NET_DELAY_WEIGHT $i_ndw [get_runs $runName] 
          set_property STEPS.OPT_DESIGN.IS_ENABLED $enOpt [get_runs $runName] 
          set_property report_strategy $rptStrtg [get_runs $runName]
          lappend s1Runs $runName
          puts "####INFO: [get_runs $runName] is successfully created"
          puts "####INFO: $runName -> Strategy -> $i_strtg"
          puts "####INFO: $runName -> NET_DELAY_WEIGHT -> $i_ndw"
          puts "####INFO: $runName -> Report strategy -> $rptStrtg"
          puts "####INFO: $runName settings done"
          incr id
        }
      }
    }
    puts [string repeat # 100]
    puts "####INFO: Run settings for these 3 runs in stage 1 as follows"
    print_impl_run_settings $s1Runs S1
    puts [string repeat # 100]
  }

  # display_dict
  # Display dictionary
  proc display_dict {mydict} {
    set mydictLen [dict size $mydict]
    if {$mydictLen==0} {
      return -code error "####ERROR: the given dictionary is empty"
    }
    puts "[string repeat # 100]"
    puts "####INFO: there are $mydictLen keys in the given dictionary"
    dict for {k v} $mydict {
      puts [format {|%s %s|} $k $v]
    } 
    puts "[string repeat # 100]"
  }

  # change_frac_len
  # Change the fractional length to the specified value 
  proc change_frac_len {fracVar fracLen} {
    if {[string is double -strict $fracVar]} {
      return [format "%.${fracLen}f" $fracVar]
    } else {
      return $fracVar
    }
  }

  # get_run_perf
  # implRuns: impl runs available in current project
  # Get performance metrics WNS/TNS/WHS/THS/FAILED_NETS of given runs
  proc get_run_perf {implRuns} {
    set activeImplRun [get_runs $implRuns]
    set runCount [llength $activeImplRun]
    puts "####INFO: $runCount available impl runs: $activeImplRun"
    if {$runCount==0} {
      return -code error "####ERROR: No valid impl run specified"
    }
    set runPerf [dict create]
    set ppt {STATS.WNS STATS.TNS STATS.WHS STATS.THS STATS.FAILED_NETS}
    foreach i_activeImplRun $activeImplRun {
      foreach i_ppt $ppt {
        set v [change_frac_len [get_property $i_ppt $i_activeImplRun] 3]
        dict set runPerf $i_activeImplRun $i_ppt $v
        puts "####INFO: $i_activeImplRun -> $i_ppt : $v" 
      }
    }
    display_dict $runPerf
    return $runPerf
  }

  # remove_element
  # Remove elements from given list based on IDs
  proc remove_element {mylist id} {
    if {[llength $id]==0} {
      return $mylist
    } else {
      set newList {}
      for {set i 0} {$i<[llength $mylist]} {incr i} {
        if {$i ni $id} {
          lappend newList [lindex $mylist $i]
        }
      }
      return $newList
    }
  }

  # print_table
  proc print_table {runName wns tns whs ths failedNets} {
    set tb [xilinx::designutils::prettyTable]
    set header [list RunName WNS TNS WHS THS FailedNets]
    $tb header $header
    foreach i_runName $runName i_wns $wns i_tns $tns i_whs $whs i_ths $ths i_failedNets $failedNets {
      set row [list $i_runName $i_wns $i_tns $i_whs $i_ths $i_failedNets]
      $tb addrow $row
    }
    puts [$tb print]
    #$tb destroy
  }

  # get_max_id
  # Get the ID of maximum value for given list
  proc get_max_id {mylist} {
    if {[llength $mylist]==0} {
      return -code error "####ERROR: the given list is empty"
    }
    set maxV [tcl::mathfunc::max {*}$mylist]
    set id [lsearch -exact -all $mylist $maxV]
    return $id
  }

  # get_min_id
  # Get the ID of minimum value for given list
  proc get_min_id {mylist} {
    if {[llength $mylist]==0} {
      return -code error "####ERROR: the given list is empty"
    }
    set minV [tcl::mathfunc::min {*}$mylist]
    set id [lsearch -exact -all $mylist $minV]
    return $id
  }

  # get_target_values
  # Get values based on the given IDs
  proc get_target_values {mylist id} {
    set newDict [dict create]
    foreach i_id $id {
      dict append newDict $i_id [lindex $mylist $i_id]
    }
    return $newDict
  }

  # get_target_id
  # Get expected index whose value can meet conditions
  proc get_target_id {mylist target} {
    set id {}
    set i 0
    foreach i_mylist $mylist {
      if {$i_mylist<$target} {
        lappend id $i
      }
      incr i
    }
    return $id
  }

  # get_best_run
  # Get best run 
  # minWHS : default 0, the threshold of minimum WHS
  # Step 1 : check failed nets -> number of failed nets == 0
  # Step 2 : check WHS -> WHS >= minWHS (defalut 0)
  # Step 3 : Get max value of WNS
  # Step 4 : For same WNS, check TNS. max WNS and min TNS -> best
  proc get_best_run {implRunDict {minWHS 0.0}} {
    set runName {}
    set tns {}
    set wns {}
    set whs {}
    set ths {}
    set failedNets {}
    dict for {id subDict} $implRunDict {
      lappend runName $id
      dict with subDict {
        lappend tns ${STATS.TNS}
        lappend wns ${STATS.WNS}
        lappend whs ${STATS.WHS}
        lappend ths ${STATS.THS}
        lappend failedNets ${STATS.FAILED_NETS}
      }
    }
    set runCount [llength $runName]
    puts "[string repeat # 100]"
    puts "####INFO: there are $runCount impl runs available"
    print_table $runName $wns $tns $whs $ths $failedNets
    puts "[string repeat # 100]"
    puts "####INFO: Available Runs"
    puts "####INFO: Run Name -> $runName"
    puts "####INFO: WNS -> $wns"
    puts "####INFO: TNS -> $tns"
    puts "####INFO: WHS -> $whs"
    puts "####INFO: THS -> $ths"
    puts "####INFO: Failed Nets -> $failedNets"
    puts "[string repeat # 100]"
    # Get the number of runs with failed nets greater than 0
    set idPos [lsearch -regexp -all $failedNets {^[1-9]}]
    set idPosCount [llength $idPos]
    if {$idPosCount==$runCount} {
      return -code error "####ERROR: No best run available and further optimization required"
    } 
    if {$idPosCount<$runCount && $idPosCount>0} {
      set runName    [remove_element $runName    $idPos]  
      set tns        [remove_element $tns        $idPos]   
      set wns        [remove_element $wns        $idPos]      
      set whs        [remove_element $whs        $idPos]      
      set ths        [remove_element $ths        $idPos]            
      set failedNets [remove_element $failedNets $idPos]
    }
    # runCount1: #N of runs with failed nets equal to 0
    set runCount1 [expr {$runCount-$idPosCount}]
    puts "[string repeat # 100]"
    puts "####INFO: there are $runCount1 impl runs with failed nets equal to 0"
    print_table $runName $wns $tns $whs $ths $failedNets
    puts "[string repeat # 100]"
    puts "####INFO: Runs with failed nets equal to 0"
    puts "####INFO: Run Name -> $runName"
    puts "####INFO: WNS -> $wns"
    puts "####INFO: TNS -> $tns"
    puts "####INFO: WHS -> $whs"
    puts "####INFO: THS -> $ths"
    puts "####INFO: Failed Nets -> $failedNets"
    puts "[string repeat # 100]"
    # Filter WHS>=minWHS
    # set idNegWhs [lsearch -regexp -all $whs {^-}]
    set idNegWhs [get_target_id $whs $minWHS]
    set idNegWhsCount [llength $idNegWhs]
    if {$idNegWhsCount==$runCount1} {
      return -code error "####ERROR: No best run available"
    }
    if {$idNegWhsCount<$runCount1 && $idNegWhsCount>0} {
      set runName    [remove_element $runName    $idNegWhs]  
      set tns        [remove_element $tns        $idNegWhs]   
      set wns        [remove_element $wns        $idNegWhs]      
      set whs        [remove_element $whs        $idNegWhs]      
      set ths        [remove_element $ths        $idNegWhs]            
      set failedNets [remove_element $failedNets $idNegWhs]
    }
    # runCount2: #N of runs with positive WHS
    set runCount2 [expr {$runCount1-$idNegWhsCount}]
    puts "[string repeat # 100]"
    puts "####INFO: there are $runCount2 impl runs with whs greater than or equal to 0"
    print_table $runName $wns $tns $whs $ths $failedNets
    puts "[string repeat # 100]"
    puts "####INFO: Runs with WHS equal to or greater than 0"
    puts "####INFO: Run Name -> $runName"
    puts "####INFO: WNS -> $wns"
    puts "####INFO: TNS -> $tns"
    puts "####INFO: WHS -> $whs"
    puts "####INFO: THS -> $ths"
    puts "####INFO: Failed Nets -> $failedNets"
    puts "[string repeat # 100]"
    # maxWNSId: ID of the greatest WNS
    set maxWNSId [get_max_id $wns]
    puts "####INFO: ID of maximum WNS -> $maxWNSId"
    # maxWNSCount: #N of the same max WNS
    set maxWNSCount [llength $maxWNSId]
    if {$maxWNSCount>1} { 
      set tnsDict [get_target_values $tns $maxWNSId] 
      set tnsDictValues [dict values $tnsDict]
      set maxTNS [tcl::mathfunc::max {*}$tnsDictValues]
      set maxTNSDict [dict filter $tnsDict value $maxTNS]
      set maxTNSKeys [dict keys $maxTNSDict]
      set maxWNSId [lindex $maxTNSKeys 0]
    }
    set bestRunName [lindex $runName   $maxWNSId]
    set runName     [lindex $runName   $maxWNSId]
    set wns         [lindex $wns       $maxWNSId]
    set tns         [lindex $tns       $maxWNSId]
    set whs         [lindex $whs       $maxWNSId]
    set ths         [lindex $ths       $maxWNSId]
    set failedNets [lindex $failedNets $maxWNSId]
    puts "####INFO: Best run"
    print_table $runName $wns $tns $whs $ths $failedNets
    puts "[string repeat # 100]"
    puts "####INFO: Best run"
    puts "####INFO: Run Name -> $runName"
    puts "####INFO: WNS -> $wns"
    puts "####INFO: TNS -> $tns"
    puts "####INFO: WHS -> $whs"
    puts "####INFO: THS -> $ths"
    puts "####INFO: Failed Nets -> $failedNets"
    puts "[string repeat # 100]"
    #print_impl_run_settings $bestRunName $stage
    return $bestRunName
  }

  # get_s2_sd
  # Get subdirective of place_design for stage 2
  proc get_s2_sd {is_pb_ready balanced_slr} {
    variable numSlr
    variable placeSubdir
    variable s2CandidateSubdir 
    set sd {}
    foreach i_candidate $s2CandidateSubdir {
      puts "####INFO: current candidate -> $i_candidate"
      set subDict [dict get $placeSubdir $i_candidate]
      set mykey [get_cletter $i_candidate]
      puts "####INFO: subdirect name -> $i_candidate -> short name -> $mykey"
      set p [dict get $subDict Phase]
      puts "####INFO: valid phases -> $p"
      set v [dict get $subDict Value]
      puts "####INFO: valid values -> $v"
      switch -exact -- $i_candidate {
        WLDrivenBlockPlacement {
          set tmp {}
          foreach ip $p {
            lappend tmp ${ip}.${i_candidate} 
          }
          lappend sd $tmp
          puts "####INFO: current sd -> $sd"
        }
        EarlyBlockPlacement {
          set p0 [lindex $p 0]
          lappend sd ${p0}.${i_candidate}
          puts "####INFO: current sd -> $sd"
        }
        BalancedSLR {
          if {$numSlr>1 && $is_pb_ready==0} {
            set val [value_short2long $balanced_slr]
            set p0 [lindex $p 0]
            foreach iv $v {
              if {$iv in $val} {
                lappend sd ${p0}.${i_candidate}.${iv}
                puts "####INFO: current sd -> $sd"
              } else {
                continue
              }
            }
          } else { 
            puts "####INFO: #N SLR -> $numSlr, is pblock ready -> $is_pb_ready"
            continue
          }
        }
      }
    }
    set tb [xilinx::designutils::prettyTable]
    set header [list ID subdirective]
    $tb header $header
    set i 1
    foreach i_sd $sd {
      $tb addrow [list $i $i_sd]
      incr i
    }
    puts [string repeat # 100]
    puts "Available Subdirectives in Stage 2"
    puts [$tb print]
    puts [string repeat # 100]
    return $sd
  }
  # get_run_info
  # Get specified properties for specified run
  # runName: a single impl run
  # ppt: property
  proc get_run_info {runName ppt} {
    set runCount [get_runs $runName]
    if {$runCount==0} {
      return -code error "####ERROR: $runName does not exist in current project"
    } else {
      if {[llength $ppt]==0} {
        return -code error "####ERROR: A property name should be assigned"
      } else {
        set allPpt [list_property [get_runs impl_1]]
        set pptV {}
        foreach i_ppt $ppt {
          if {$i_ppt ni $allPpt} {
            lappend pptV {}
          } else {
            puts "####INFO: Property name -> $i_ppt"
            set tmp [get_property $i_ppt [get_runs $runName]]
            puts "####INFO: $runName -> $i_ppt -> $tmp"
            lappend pptV $tmp
          }
        }
        return $pptV
      }
    }
  }

  proc get_tail {id} {
    if {$id<10} {
      set tail 0${id}
    } else {
      set tail $id
    }
    return $tail
  }

  # Create impl runs for stage 2
  # For non-SSI devices
  # run_stage2 
  # run_stage2 -ref_run *_01_S1*
  # run_stage2 -ndw lmh
  # run_stage2 -ndw m
  # run_stage2 -minwhs -0.2
  # For SSI devices
  # run_stage2 -is_pb_ready 0 -balanced_slr mh
  # run_stage2 -is_pb_ready 1
  proc run_stage2 {args} {
    variable rptStrtg
    variable s2Args
    variable VivadoVersion
    variable s2Usage
    check_version
    set vL [split $VivadoVersion .]
    set year [lindex $vL 0]
    array set params [::cmdline::getoptions args $s2Args $s2Usage]
    puts "####INFO: parameters array displayed as follows"
    parray params
    set s1Runs      $params(ref_run)
    puts "####INFO: -ref_run -> $s1Runs"
    set ndw         $params(ndw)
    puts "####INFO: -ndw -> $ndw"
    set balancedSlr $params(balanced_slr)
    puts "####INFO: -balanced_slr -> $balancedSlr"
    set minWHS      $params(minwhs)
    puts "####INFO: -minwhs -> $minWHS"
    set isPbReady   $params(is_pb_ready)
    puts "####INFO: -is_pb_ready -> $isPbReady"
    set ndwLen    [llength $ndw]
    puts "####INFO: #net_delay_weight -> $ndwLen"
    set s1RunsLen [llength [get_runs $s1Runs]]
    puts "####INFO: Available impl run count -> $s1RunsLen"
    if {$s1RunsLen==0} {
      return -code error "####ERROR: There is no run available"
    } elseif {$s1RunsLen==1} {
      puts "####INFO: Only one reference run is available"
      set s1BestRun $s1Runs
    } else { 
      puts "####INFO: More than one reference runs are available"
      set s1RunInfo [get_run_perf $s1Runs]
      set s1BestRun [get_best_run $s1RunInfo $minWHS]
    }
    puts "####Summary: impl run settings for runs in stage 1"
    puts [string repeat # 100]
    print_impl_run_settings $s1Runs S1
    puts [string repeat # 100]
    puts "####INFO: settings for best run in stage 1"
    print_impl_run_settings $s1BestRun S1
    # Get legal subdirectives for stage 2
    set placeDir [get_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE [get_runs $s1BestRun]]
    puts "####INFO: Stage 1 Best Run -> $s1BestRun -> place_design -> directive -> $placeDir"
    set s2Subdir [get_s2_sd $isPbReady $balancedSlr]
    # Set acceptable values for NET_DELAY_WEIGHT 
    if {$ndwLen>0} {
      set ndwu [ndw2str $ndw]
      puts "####INFO: ndw_en is set to 1"
    } else {
      set ndwu [get_property STEPS.PLACE_DESIGN.ARGS.NET_DELAY_WEIGHT [get_runs $s1BestRun]] 
      puts "####INFO: ndw_en is set to 0"
    }
    puts "####INFO: Available values of net_delay_weight -> $ndw"
    set s2Runs {}
    set tb [xilinx::designutils::prettyTable]
    set header [list ID RunName place_design.directive place_design.subdirective]
    $tb header $header
    set id 1
    foreach i_ndw $ndwu {
      set tmpRun {}
      foreach svalue $s2Subdir {
        set tail [get_tail $id]
        if {[string equal $svalue Floorplan.BalancedSLR.high]} {
          foreach pd {Default Explore} {
            set runName [find_free_run_name impl S2 $tail] 
            copy_run -name $runName [get_runs $s1BestRun] 
            set_property STEPS.PLACE_DESIGN.ARGS.SUBDIRECTIVE $svalue [get_runs $runName]
            set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE $pd [get_runs $runName]
            puts "####INFO: $runName -> place_design subdirective -> $svalue"
            puts "####INFO: $runName -> place_design directive -> $pd"
            puts "####INFO: copy run -> $runName -> done"
            lappend tmpRun [get_runs $runName]
            $tb addrow [list $id $runName $pd $svalue]
            incr id
            set tail [get_tail $id]
            lappend s2Runs $runName
          }
        } else {
          set runName [find_free_run_name impl S2 $tail] 
          copy_run -name $runName [get_runs $s1BestRun] 
          set pd [get_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE [get_runs $s1BestRun]]
          set_property STEPS.PLACE_DESIGN.ARGS.SUBDIRECTIVE $svalue [get_runs $runName]
          puts "####INFO: $runName -> place_design subdirective -> $svalue"
          puts "####INFO: $runName -> place_design directive -> $pd"
          puts "####INFO: copy run -> $runName -> done"
          lappend tmpRun [get_runs $runName]
          $tb addrow [list $id $runName $pd $svalue]
          incr id
        #  set tail [get_tail $id]
          lappend s2Runs $runName
        }
      }
      set_property STEPS.PLACE_DESIGN.ARGS.NET_DELAY_WEIGHT $i_ndw [get_runs $tmpRun] 
      puts "####INFO: $tmpRun -> NET_DELAY_WEIGHT -> $i_ndw"
      set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE NoTimingRelaxation [get_runs $tmpRun]
      puts "####INFO: $tmpRun -> route_design directive -> NoTimingRelaxation"
      set_property -name {STEPS.ROUTE_DESIGN.ARGS.MORE OPTIONS} -value {-tns_cleanup} -objects [get_runs $tmpRun]
      puts "####INFO: $tmpRun -> rout more options -> tns_cleanup"
      set_property report_strategy $rptStrtg [get_runs $tmpRun]
      puts "####INFO: $tmpRun -> Report strategy -> $rptStrtg"
    }
    puts [$tb print]
    puts [string repeat # 100]
    puts "####Summary: Information of Best Run from stage 1"
    print_impl_run_settings $s1BestRun S1
    puts "####Summary: Impl run settings in stage 2"
    print_impl_run_settings $s2Runs S2
  }

  # extract_subdir
  # Extract the name of subdirective
  # Example: Floorplan.ForceSpreading.med Gplace.ForceSpreading.med Dplace.ReducePinDensity.high
  # Output: ForceSpreading ReducePinDensity
  proc extract_subdir {subdir} {
    set subdirName {}
    foreach i_subdir $subdir {
      set tmp [split $i_subdir .]
      lappend subdirName [lindex $tmp 1]
    }
    set subdirName [lsort -unique $subdirName]
    return $subdirName
  }

  # get_untouched_subdir
  # Get subdirectives that have not been used for a given impl run
  # usedSubdir: Subdirectives that have been applied to one or more impl runs
  # availSubdir: All available subdirectives
  proc get_untouched_subdir {usedSubdir availSubdir isPbReady} {
    variable numSlr
    set res {}
    foreach i_availSubdir $availSubdir {
      if {$i_availSubdir ni $usedSubdir} {
        lappend res $i_availSubdir
      }
    }
    if {[string equal $usedSubdir BalancedSLR]==0} {
      set idx [lsearch $res BalancedSLR]
      if {$idx>-1} {
        if {$numSlr==1} { 
          set res [lreplace $res $idx $idx]
        } elseif {$numSlr>1 && $isPbReady==1} {
          set res [lreplace $res $idx $idx]
        }
      }
    }
    return $res
  }

  # get_s3_sd
  # Create subdirective for stage 3
  # s2BestRun: best run from stage 2
  # level: high, med or both. both -> med and high. Default: high
  proc get_s3_sd {s2BestRun isPbReady {level h}} {
    variable numSlr
    variable placeSubdir
    set s2PlaceDir    [get_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE [get_runs $s2BestRun]]
    set s2PlaceSubdir [get_property STEPS.PLACE_DESIGN.ARGS.SUBDIRECTIVE [get_runs $s2BestRun]]
    puts "####INFO: Best run -> directive of place_design: $s2PlaceDir"
    puts "####INFO: Best run -> subdirective of place_design: $s2PlaceSubdir"
    set s2SubdirName [extract_subdir $s2PlaceSubdir]
    puts "####INFO: name of subdirective -> $s2SubdirName"
    set availSubdir [dict keys $placeSubdir]
    puts "####INFO: Available subdirectives -> $availSubdir"
    set unusedSubdir [get_untouched_subdir $s2SubdirName $availSubdir $isPbReady]
    puts "####INFO: unused subdirectives in this run (stage 2) -> $unusedSubdir"
    set val [value_short2long $level]
    puts "####INFO: values for specified subdirective -> $val"
    set s3Subdir {}
    foreach i_unusedSubdir $unusedSubdir {
      set p [dict get $placeSubdir $i_unusedSubdir Phase]
      set v [dict get $placeSubdir $i_unusedSubdir Value]
      puts "####INFO: $s2PlaceDir -> $i_unusedSubdir -> Phase: $p -> Value: $v"
      if {[llength $v]>0} {
        set v $val
        puts "####INFO: $s2PlaceDir -> $i_unusedSubdir -> Phase: $p -> updated value: $v"
        if {[string equal $i_unusedSubdir ExtraTimingOpt]} {
          switch -exact -- $s2PlaceDir {
            Default {
              set v {med high}
            }
            Explore { 
              set v {high}
              puts "####INFO: $s2PlaceDir -> $i_unusedSubdir -> Phase: $p -> updated value: $v"
            }
            AggressiveExplore {
              #set v {low med}
              puts "####INFO: $s2PlaceDir -> $i_unusedSubdir -> Break out of this loop"
              continue
            }
          }
        }
        foreach i_v $v {
          set tmp {}
          foreach i_p $p {
            lappend tmp ${i_p}.${i_unusedSubdir}.${i_v}
            if {[string equal $i_unusedSubdir ExtraTimingOpt]} {
              lappend tmp ${i_p}.ExtraTimingUpdate
              puts "####INFO: add $i_p -> ExtraTimingUpdate"
            }
            puts "####INFO: Qualified subdir -> $tmp"
          }
          lappend s3Subdir [linsert $s2PlaceSubdir end {*}$tmp]
          puts "####INFO: updated s3Subdir -> $s3Subdir"
        }
      } else {
        set tmp {}
        foreach i_p $p {
          lappend tmp ${i_p}.${i_unusedSubdir}
          puts "####INFO: Qualified subdir -> $tmp"
        }
          lappend s3Subdir [linsert $s2PlaceSubdir end {*}$tmp]
          puts "####INFO: updated s3Subdir -> $s3Subdir"
        }
    }
    set s1 Floorplan.WLDrivenBlockPlacement
    set s2 GPlace.WLDrivenBlockPlacement
    if {"WLDrivenBlockPlacement" in $s2SubdirName} {
      switch -glob -- $s2BestRun {
        *S2* {
          puts "####INFO: Current stage -> stage 2"
          lappend s3Subdir [lindex $s2PlaceSubdir 0]
          lappend s3Subdir [lindex $s2PlaceSubdir 1]
          puts "####INFO: Divide the subdirective into two parts Floorplan.WLDrivenBlockPlacement GPlace.WLDrivenBlockPlacement"
        }
        *S3* {
          puts "####INFO: Current stage -> stage 3"
        }
      }
    } else {
      lappend s3Subdir [linsert $s2PlaceSubdir end $s1]
      lappend s3Subdir [linsert $s2PlaceSubdir end $s2]
      puts "####INFO: Add Floorplan.WLDrivenBlockPlacement" 
      puts "####INFO: Add GPlace.WLDrivenBlockPlacement"
    }
    set tb [xilinx::designutils::prettyTable]
    set header [list ID place_design.subdirective]
    $tb header $header
    set id 1
    foreach i_s3Subdir $s3Subdir {
      $tb addrow [list $id $i_s3Subdir]
      incr id
    }
    puts [string repeat # 100]
    puts "INFO: subdirectives in stage 3"
    puts [$tb print]
    puts [string repeat # 100]
    return $s3Subdir
  }

  # run_stage3
  # Based on stage 2, more subdirectives will be added in stage 3
  # s2runs: impl runs in stage 2
  # ndw: values of net_delay_weight, type: string. case insensitive
  #      acceptable value is the combination of l m h
  #      l: low, m: medium, h: high
  #      Example: -ndw lm -ndw lmh -ndw h 
  #      if the value is llh, then only one l is valid. 
  #      String length must be less than or equal to 3
  # level: some subdirectives have the value low, med and high
  #      This argument is to set the value of the specified subdirective
  #      Legal values: med, high, both
  #      Default value: high
  #      both -> med + high 
  # is_pb_ready: For SSI-based design, if pblocks are created, then Floorplan.BalancedSLR will be ignored
  #              Default value: 1
  # Usage:
  # run_stage3 -s2runs [get_runs impl_01_S2*]
  # run_stage3 -s2runs [get_runs impl_01_S2*] -ndw lmh 
  # run_stage3 -s2runs [get_runs impl_01_S2*] -ndw mh -level high
  # run_stage3 -s2runs [get_runs impl_01_S2*] -ndw mh -level high -is_pb_ready 0
  proc run_stage3 {args} {
    variable rptStrtg
    variable s3Args
    variable s3Usage
    variable placeSubdir
    variable numSlr
    array set params [::cmdline::getoptions args $s3Args $s3Usage]
    puts "####INFO: parameters array displayed as follows"
    parray params
    set s2Runs    $params(ref_run)
    puts "####INFO: -ref_run -> $s2Runs"
    set ndw       $params(ndw)
    puts "####INFO: -ndw -> $ndw"
    set level     $params(level)
    puts "####INFO: -level -> $level"
    set minWHS    $params(minwhs)
    puts "####INFO: -minwhs -> $minWHS"
    set isPbReady $params(is_pb_ready)
    puts "####INFO: -is_pb_ready -> $isPbReady"
    set ndwLen    [llength $ndw]
    puts "####INFO: #net_delay_weight -> $ndwLen"

    set s2RunsLen [llength [get_runs $s2Runs]]
    puts "####INFO: Available impl run count -> $s2RunsLen"
    if {$s2RunsLen==0} {
      return -code error "####ERROR: There is no run available"
    } elseif {$s2RunsLen==1} {
      puts "####INFO: Only one reference run is available"
      set s2BestRun $s2Runs
    } else { 
      puts "####INFO: More than one reference runs are available"
      set s2RunInfo [get_run_perf $s2Runs]
      set s2BestRun [get_best_run $s2RunInfo $minWHS]
    }
    puts "####Summary: impl run settings for runs in stage 2"
    puts [string repeat # 100]
    print_impl_run_settings $s2Runs S2
    puts [string repeat # 100]
    puts "####INFO: settings for best run in stage 2"
    print_impl_run_settings $s2BestRun S2
    set s3Subdir [get_s3_sd $s2BestRun $isPbReady $level] 
    set s2PlaceDir [get_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE [get_runs $s2BestRun]]
    if {$ndwLen>0} {
      set ndwv [ndw2str $ndw]
      puts "####INFO: Available values for -net_delay_weight: $ndwv"
    } else {
      set ndwv [get_property STEPS.PLACE_DESIGN.ARGS.NET_DELAY_WEIGHT [get_runs $s2BestRun]] 
      puts "####INFO: Available values for -net_delay_weight: $ndwv"
    }
    puts "####INFO: Available values of net_delay_weight -> $ndwv"
    set s3Runs {}
    set tb [xilinx::designutils::prettyTable]
    set header [list ID RunName place_design.directive place_design.subdirective]
    $tb header $header
    set id 1
    foreach i_ndw $ndwv {
      set tmpRun {}
      foreach i_s3Subdir $s3Subdir {
        set tail [get_tail $id]
        set runName [find_free_run_name impl S3 $tail] 
        puts "####INFO: Run name -> $runName"
        copy_run -name $runName [get_runs $s2BestRun] 
        puts "####INFO: $runName is created successfully"
        set_property STEPS.PLACE_DESIGN.ARGS.SUBDIRECTIVE $i_s3Subdir [get_runs $runName]
        puts "####INFO: $runName -> subdirective -> $i_s3Subdir"
        puts "####INFO: $runName settings done"
        set updatePlaceDir $s2PlaceDir
        set idx [lsearch $i_s3Subdir Floorplan.BalancedSLR.high]
        if {$idx>-1} {
          set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs $runName]
          set updatePlaceDir Explore
        }
        $tb addrow [list $id $runName $updatePlaceDir $i_s3Subdir]
        puts "####INFO: copy run $runName -> end"
        puts "####INFO: add this line to specified table"
        lappend tmpRun $runName
        incr id
        lappend s3Runs $runName
        puts "####INFO: add this run to specified run list"
      }
      set_property STEPS.PLACE_DESIGN.ARGS.NET_DELAY_WEIGHT $i_ndw  [get_runs $tmpRun] 
      puts "####INFO: $tmpRun -> NET_DELAY_WEIGHT -> $i_ndw"
      set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE NoTimingRelaxation [get_runs $tmpRun]
      puts "####INFO: $tmpRun -> routing directive -> NoTimingRelaxation"
      set_property -name {STEPS.ROUTE_DESIGN.ARGS.MORE OPTIONS} -value {-tns_cleanup} -objects [get_runs $tmpRun]
      puts "####INFO: $tmpRun -> routing more options -> tns_cleanup"
      set_property report_strategy $rptStrtg [get_runs $tmpRun]
      puts "####INFO: $tmpRun -> Report strategy -> $rptStrtg"
    }
    puts "####INFO: Available subdirectives in stage 3"
    puts [$tb print]
    print_impl_run_settings $s3Runs
  }
  
  # read_timing_info 
  # Read timing info from the specified timing summary report
  # rpt: timing report
  # enWHS: 1 -> Get WHS and THS
  #        0 -> Only get WNS and TNS
  proc read_timing_info {rpt {enWHS 1}} {
    set fid [open $rpt r]
    set key_word "WNS(ns)"
    while {[gets $fid line] != -1} {
      set myline [regexp -inline -all -- {\S+} $line]
      if {[lindex $myline 0] == $key_word} {
        break
      }
    }
    gets $fid line
    gets $fid line
    puts $line
    close $fid
    set myline [regexp -inline -all -- {\S+} $line]
    set wns  [lindex $myline 0]
    set tns  [lindex $myline 1]
    set whs  [lindex $myline 4]
    set ths  [lindex $myline 5]
    #set wpws [lindex $myline 8]
    #set tpws [lindex $myline 9]
    #set timingInfo [list $wns $tns $whs $ths $wpws $tpws]
    if {$enWHS==1} {
      set timingInfo [list $wns $tns $whs $ths]
      puts "####INFO: timing report -> $rpt -> timing info $timingInfo"
    } else {
      set timingInfo [list $wns $tns]
      puts "####INFO: timing report -> $rpt -> timing info $timingInfo"
    }
    return $timingInfo
  }

  # get_timing_info
  # rpt: timing summary report generated by enabling UltraFast report strategy
  # enWHS: default value 1, means WHS and THS will be captured
  #        0 : Only WNS and TNS are captured
  proc get_timing_info {rpt {enWHS 1}} {
    if {[file exists $rpt]==1} {
      set timingInfo [read_timing_info $rpt $enWHS]
      puts "####INFO: timing report -> $rpt Done"
    } else {
      if {$enWHS==1} {
        set timingInfo {X X X X}
        puts "####INFO: No timing report -> $timingInfo"
      } else {
        set timingInfo {X X}
        puts "####INFO: No timing report -> $timingInfo"
      }
    }
    return $timingInfo
  }

  # print_timing_info
  # implRun: values returned by get_runs
  # init_design/opt_design: timing info (WNS, TNS)
  # others: timing info (WNS, TNS, WHS, THS)
  # Directive of each step is also included
  # Subdirective/net_delay_weight/Clock vtree type is contained as well
  proc print_timing_info {implRun} {
    set implRunCount [llength [get_runs $implRun]]
    if {$implRunCount==0} {
      return -code error "####ERROR: No valid impl run available"
    }
    set header {init.WNS init.TNS opt.Directive opt.WNS opt.TNS place.Directive place.Subdirective \
      place.ndw place.vtree place.WNS place.TNS place.WHS place.THS \
      phys_opt(P).Directive phys_opt(P).WNS phys_opt(P).TNS phys_opt(P).WHS phys_opt(P).THS \
      route.Directive route.More route.WNS route.TNS route.WHS route.THS  \
      phys_opt(R).Directive phys_opt(R).WNS phys_opt(R).TNS phys_opt(R).WHS phys_opt(R).THS } 
    set tb [xilinx::designutils::prettyTable]
    set header [list ID Runs {*}$header]
    $tb header $header
    set i 1
    foreach i_implRun $implRun {
      set status [get_property STATUS [get_runs $i_implRun]]
      puts "####INFO: $i_implRun -> STATUS -> $status"
      if {[string equal $status "Not started"]} {
        puts "####INFO: Break out of the loop"
        continue
      }
      set row {}
      lappend row $i
      lappend row $i_implRun
      set dir [get_property DIRECTORY [get_runs $i_implRun]]
      cd $dir 
      set initTimingInfo [get_timing_info init_report_timing_summary_0.rpt 0]
      puts "####INFO: init_design -> $initTimingInfo"
      lappend row {*}$initTimingInfo
      set optDir [get_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE $i_implRun]
      puts "####INFO: opt_design -> Directive -> $optDir"
      lappend row $optDir
      set optTimingInfo [get_timing_info opt_report_timing_summary_0.rpt 0]
      puts "####INFO: opt_design -> Timing info -> $optTimingInfo"
      lappend row {*}$optTimingInfo
      set placeDir [get_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE $i_implRun]
      puts "####INFO: place_design -> Directive -> $placeDir"
      lappend row $placeDir
      set placeSubdir [get_property STEPS.PLACE_DESIGN.ARGS.SUBDIRECTIVE $i_implRun]
      if {[llength $placeSubdir]==0} {
        puts "####INFO: place_design -> Subdirective -> No subdirective"
        lappend row ""
      } else {
        puts "####INFO: place_design -> Subdirective -> $placeSubdir"
        set subdirSn [get_short_name $placeSubdir]
        lappend row $subdirSn
        puts "####INFO: place_design -> Subdirective (short name) -> $subdirSn"
      }
      set ndw [get_property STEPS.PLACE_DESIGN.ARGS.NET_DELAY_WEIGHT $i_implRun]
      puts "####INFO: place_design -> net_delay_weight -> $ndw"
      lappend row $ndw
      set vt [get_property STEPS.PLACE_DESIGN.ARGS.CLOCK_VTREE_TYPE $i_implRun]
      puts "####INFO: place_design -> Clock vtree type -> $vt"
      lappend row $vt
      set placeTimingInfo [get_timing_info place_report_timing_summary_0.rpt 1]
      puts "####INFO: place_design -> Timing info -> $placeTimingInfo"
      lappend row {*}$placeTimingInfo
      set physOptDir [get_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE $i_implRun]
      puts "####INFO: phys_opt_design -> Directive -> $physOptDir"
      lappend row $physOptDir
      set physOptTimingInfo [get_timing_info phys_opt_report_timing_summary_0.rpt 1]
      puts "####INFO: phys_opt_design -> Timing info -> $physOptTimingInfo"
      lappend row {*}$physOptTimingInfo
      set routeDir [get_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE $i_implRun]
      puts "####INFO: route_design -> Directive -> $routeDir"
      lappend row $routeDir
      set routeMore [get_property {STEPS.ROUTE_DESIGN.ARGS.MORE OPTIONS} $i_implRun]
      puts "####INFO: route_design -> More options -> $routeMore"
      lappend row [string range $routeMore 1 end]
      set routeTimingInfo [get_timing_info route_report_timing_summary_0.rpt 1]
      puts "####INFO: route_design -> Timing info -> $routeTimingInfo"
      lappend row {*}$routeTimingInfo
      set postRoutePhysOptDir [get_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE $i_implRun]
      puts "####INFO: phys_opt_design(post-route) -> Directive -> $postRoutePhysOptDir"
      lappend row $postRoutePhysOptDir
      set postRoutePhysOptTimingInfo [get_timing_info post_route_phys_opt_report_timing_summary_0.rpt 1]
      puts "####INFO: phys_opt_design(post-route) -> Timing info -> $postRoutePhysOptTimingInfo"
      lappend row {*}$postRoutePhysOptTimingInfo
      $tb addrow $row
      incr i
    }
    cd ..
    puts [$tb print]
    puts "####INFO: Table of timing info is successfully created"
    set systemTime [clock seconds]
    set fnTail [clock format $systemTime -format %d_%m_%Y_%H%M%S]
    puts "####INFO: The time is: [clock format $systemTime -format %d_%m_%Y_%H%M%S]"
    set fn timing_info_${fnTail}.csv
    $tb export -format csv -file $fn
    set p [file normalize $fn]
    set str "####INFO: file location -> $p"
    set strLen [string length $str]
    puts [string repeat # $strLen]
    puts "####INFO: $fn is successfully exported"
    puts "####INFO: file location -> $p"
    puts [string repeat # $strLen]
  }
}




