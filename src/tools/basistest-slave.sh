#! /usr/bin/env bash

##############################################################################
# \file  basistest-slave.sh
# \brief Test execution command.
#
# This shell script runs the tests of a BASIS project. It is a wrapper for
# a CTest script. In particular, the testing master basistest-master uses
# this script by default in order to run a test.
#
# Copyright (c) 2011 University of Pennsylvania. All rights reserved.
# See COPYING file or https://www.rad.upenn.edu/sbia/software/license.html.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ============================================================================
# BASIS functions (automatically generated by BASIS)
# ============================================================================

@BASH_FUNCTION_get_executable_name@
@BASH_FUNCTION_get_executable_directory@
@BASH_FUNCTION_print_version@
@BASH_FUNCTION_print_contact@

# ============================================================================
# settings
# ============================================================================

# executable information
exec_name=$(get_executable_name)
exec_dir=$(get_executable_directory)
exec_version='@VERSION@'
exec_revision='@REVISION@'

# ============================================================================
# help/version
# ============================================================================

# ****************************************************************************
# \brief Print documentation of options.
print_options ()
{
    cat - << EOF-OPTIONS
Required options:
  -p [ --project ]   The name of the BASIS project to be tested.

Options:
  -b [ --branch ]    The branch to be tested, e.g., "tags/1.0.0".
                     Defaults to "trunk".
  -m [ --model ]     The name of the dashboard model, i.e., either "Nightly",
                     "Continuous", or "Experimental". Defaults to "Nightly".
  -S [ --script ]    CTest script which performs the testing.
                     Defaults to the "basistest.ctest" script of BASIS.
  -a [ --args ]      Additional arguments for the CTest script.
  -v [ --verbose ]   Increases verbosity of output messages. Can be given multiple times.
  -h [ --help ]      Print help and exit.
  -u [ --usage ]     Print usage information and exit.
  -V [ --version ]   Print version information and exit.
EOF-OPTIONS
}

# ****************************************************************************
# \brief Print help.
print_help ()
{
    echo "$exec_name (BASIS)"
    echo
    echo "Usage:"
    echo "  $exec_name [options]"
    echo
    cat - << EOF-DESCRIPTION
Description:
  This program performs the testing of specified BASIS project at SBIA.
EOF-DESCRIPTION
    echo
    print_options
    echo
    cat - << EOF-EXAMPLES
Examples:
  $exec_name -p BASIS -a coverage,memcheck

    Performs the testing of the project BASIS itself, including coverage
    analysis and memory checks.
EOF-EXAMPLES
    echo
    print_contact
}

# ****************************************************************************
# \brief Print usage (i.e., only usage and options).
print_usage ()
{
    echo "$exec_name (BASIS)"
    echo
    echo "Usage:"
    echo "  $exec_name [options]"
    echo
    print_options
    echo
    print_contact
}

# ============================================================================
# options
# ============================================================================

# CTest script
ctest_script="$exec_dir/@BASISTEST_CTEST_SCRIPT_DIR@/basistest.ctest"

project=''      # name of the BASIS project
branch='trunk'  # the branch to test
model='Nightly' # the dashboard model
args=''         # additional CTest script arguments
verbosity=0     # verbosity of output messages

while [ $# -gt 0 ]; do
	case "$1" in
        -p|--project)
            shift
            if [ $# -gt 0 ]; then
                project=$1
            else
                echo "Option -c [ --conf ] requires an argument!" 1>&2
                exit 1
            fi
            ;;
        -b|--branch)
            shift
            if [ $# -gt 0 ]; then
                branch=$1
            else
                echo "Option -b [ --branch ] requires an argument!" 1>&2
                exit 1
            fi
            ;;
        -m|--model)
            shift
            if [ $# -gt 0 ]; then
                model=$1
            else
                echo "Option -m [ --model ] requires an argument!" 1>&2
                exit 1
            fi
            ;;
        -S|--script)
            shift
            if [ $# -gt 0 ]; then
                ctest_script=$1
            else
                echo "Option -S [ --script ] requires an argument!" 1>&2
                exit 1
            fi
            ;;
        -a|--args)
            shift
            if [ $# -gt 0 ]; then
                args=$1
            else
                echo "Option -a [ --args ] requires an argument!" 1>&2
                exit 1
            fi
            ;;

        # standard options
		-h|--help)    print_help;    exit 0; ;;
		-u|--usage)   print_usage;   exit 0; ;;
        -V|--version) print_version; exit 0; ;;
        -v|--verbose) ((verbosity++)); ;;

        # invalid option
        *)
            print_usage
            echo
            echo "Invalid option $1!" 1>&2
            ;;
    esac
    shift
done

# check options
if [ -z "$project" ]; then
    print_usage
    echo
    echo "No project specified!" 1>&2
    exit 1
fi

# ============================================================================
# main
# ============================================================================

# see if ctest can be found
which ctest &> /dev/null
if [ $? -ne 0 ]; then
    echo "Could not find the ctest command" 1>&2
    exit 1
fi

# check existence of CTest script
if [ ! -f "$ctest_script" ]; then
    echo "Missing CTest script $ctest_script" 1>&2
    exit 1
fi

# compose command
cmd='ctest'
if [ $verbosity -gt 2 ]; then
    cmd="$cmd -VV"
elif [ $verbosity -gt 0 ]; then
    cmd="$cmd -V"
fi
cmd="$cmd -S $ctest_script,project=$project,branch=$branch,model=$model"
if [ ! -z "$args" ]; then cmd="$cmd,$args"; fi
cmd="$cmd"

# run test
if [ $verbosity -gt 1 ]; then
    echo "Exec $cmd"
fi
exec $cmd
