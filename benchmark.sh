#!/usr/bin/env sh
set -euo pipefail

projects=$(find . -name Makefile | cut -d / -f2)

run_make() {
    cd $1
    make clean > /dev/null
    make > /dev/null
    make run > /dev/null
    cd ..
}

export -f run_make
parallel --bar --shuf --joblog /tmp/benchmark.log run_make ::: $projects
cat /tmp/benchmark.log | tail -n +2 | sort -k4 -n | awk '{ printf "%10s: %ss\n", $10, $4 }'
