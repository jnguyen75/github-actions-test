#!/bin/bash
#
# usage:
#   git grep -E "pattern" | ./grep-with-exclude-list.sh .my-exclusions-list

function remove_comments() {
    grep -E -v '^#|^[[:space:]]*$'
}

function remove_whitespace() {
    sed -Ee 's/^[[:space:]]+([0-9]+)[[:space:]]+/\1,/'
}

function escape_regex() {
    sed -e 's/[]\/$*.^[]/\\&/g'
}

# any non-absolute input is converted into regex to match any subdir
function prefix_match_any_path() {
    # uses sed "address" feature to append regex '^[^/]*/' to any string that
    # does NOT start with '/'  (ex, /file.txt):

    sed -e '/^\//! s|^|^[^/]*|'
          # ^^^^^^ tells sed to run the subst only when '$/' is not matched.
}

# any input without a trailing slash is converted into regex which is equivalent
# to a ** glob, ex: we want path/to/dir treated as path/to/dir/**
function postfix_match_any_filename() {
    sed -e 's|$|.*:|'
}

function filter_inputs() {
    prefix_match_any_path |
    postfix_match_any_filename
}

# takes any input list and prints it as "
function format_args_as_egrep_pattern() {
    # trick: $^ in regex matches "nothing" which makes it a good way to start any pipe-delimited list of
    #        regex patterns. This avoids needingot delete spurous '|' from printf output.
    printf "$^"
    printf "|%s" "$@"
}


input_file=$1 && shift

readarray -t inputs < <(cat "$input_file" | remove_comments | remove_whitespace | filter_inputs)

grep -vE "$@" "$(format_args_as_egrep_pattern "${inputs[@]}")"