#!/bin/bash
set -e
pegasus_lite_version_major="5"
pegasus_lite_version_minor="0"
pegasus_lite_version_patch="6"
pegasus_lite_enforce_strict_wp_check="false"
pegasus_lite_version_allow_wp_auto_download="false"
pegasus_lite_log_file="pegasus-plan_gw-finalization.pre.err"

 # set for pegasus-plan invocation 
export PEGASUS_HOME="/home/kkacanja/pegasus-5.0.6"

. pegasus-lite-common.sh

pegasus_lite_init

# cleanup in case of failures
trap pegasus_lite_signal_int INT
trap pegasus_lite_signal_term TERM
trap pegasus_lite_unexpected_exit EXIT

printf "\n########################[Pegasus Lite] Setting up workdir ########################\n"  1>&2
# work dir
pegasus_lite_setup_work_dir

pegasus_lite_section_start stage_in
printf "\n###################### Staging in input data and executables ######################\n"  1>&2
# stage in data and executables
pegasus-transfer --threads 1  --symlink  1>&2 << 'eof'
[
 { "type": "transfer",
   "linkage": "input",
   "lfn": "gw-finalization.map",
   "id": 1,
   "src_urls": [
     { "site_label": "local", "url": "file:///home/kkacanja/pycbc/examples/search/output_shared/gw-finalization.map", "priority": 0, "checkpoint": "false" }
   ],
   "dest_urls": [
     { "site_label": "local", "url": "symlink://$PWD/gw-finalization.map" }
   ] }
]
eof

pegasus_lite_section_end stage_in
set +e
job_ec=0
pegasus_lite_section_start task_execute
printf "\n######################[Pegasus Lite] Executing the user task ######################\n"  1>&2
pegasus-kickstart  -n pegasus-plan_gw-finalization.pre.sh -N gw-finalization -R local  -L gw.dax -T 2024-02-19T14:25:21-05:00 /home/kkacanja/pegasus-5.0.6/bin/pegasus-plan $@
job_ec=$?
pegasus_lite_section_end task_execute
set -e
pegasus_lite_section_start stage_out
pegasus_lite_section_end stage_out

set -e


# clear the trap, and exit cleanly
trap - EXIT
pegasus_lite_final_exit

