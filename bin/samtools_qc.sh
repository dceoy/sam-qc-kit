#!/usr/bin/env bash
#
# Tiny and portable bash script as a shell command
#
# Usage:
#   samtools_qc.sh [--debug] [--cpus=<int>] <in_dir> <out_dir>
#   samtools_qc.sh -h|--help
#   samtools_qc.sh --version
#
# Options:
#   --debug           Debug mode
#   --cpus=<int>      Limit CPUs for multiprocessing
#   -h, --help        Print usage
#   --version         Print version
#
# Arguments:
#   <in_dir>          Path to an input directory
#   <out_dir>         Path to an output directory

set -ue

if [[ ${#} -ge 1 ]]; then
  for a in "${@}"; do
    [[ "${a}" = '--debug' ]] && set -x && break
  done
fi

COMMAND_PATH=$(realpath "${0}")
COMMAND_NAME=$(basename "${COMMAND_PATH}")
COMMAND_VERSION='v0.0.1'

case "${OSTYPE}" in
  darwin* )
    CPUS=$(sysctl -n hw.ncpu)
    ;;
  linux* )
    CPUS=$(grep -ce '^processor\s\+:' /proc/cpuinfo)
    ;;
  * )
    CPUS=1
    :
    ;;
esac
MAIN_ARGS=()

function print_version {
  echo "${COMMAND_NAME}: ${COMMAND_VERSION}"
}

function print_usage {
  sed -ne '1,2d; /^#/!q; s/^#$/# /; s/^# //p;' "${COMMAND_PATH}"
}

function abort {
  {
    if [[ ${#} -eq 0 ]]; then
      cat -
    else
      COMMAND_NAME=$(basename "${COMMAND_PATH}")
      echo "${COMMAND_NAME}: ${*}"
    fi
  } >&2
  exit 1
}

while [[ ${#} -ge 1 ]]; do
  case "${1}" in
    '--debug' )
      shift 1
      ;;
    '--cpus' )
      CPUS="${2}" && shift 2
      ;;
    --cpus=* )
      CPUS="${1#*\=}" && shift 1
      ;;
    '--version' )
      print_version && exit 0
      ;;
    '-h' | '--help' )
      print_usage && exit 0
      ;;
    -* )
      abort "invalid option: ${1}"
      ;;
    * )
      MAIN_ARGS+=("${1}") && shift 1
      ;;
  esac
done

[[ ${#MAIN_ARGS[@]} -eq 2 ]] || print_usage | abort -
IN_DIR="${MAIN_ARGS[0]}"
OUT_DIR="${MAIN_ARGS[1]}"

[[ -d "${IN_DIR}" ]]
[[ -d "${OUT_DIR}" ]]

SAM_PATHS=()
for x in 'sam' 'bam' 'cram'; do
  paths=$(find "${IN_DIR}" -type f -name "*.${x}")
  SAM_PATHS+=("${paths[@]}")
done

CMDS=()
for p in "${SAM_PATHS[@]}"; do
  [[ -f "${p}" ]]
  name=$(basename "${p}")
  for c in 'idxstats' 'flagstat' 'stats'; do
    CMDS+=("set -x && samtools ${c} ${p} > ${OUT_DIR}/samtools.${c}.${name}.txt")
  done
done

printf '%s\n' "${CMDS[@]}" | xargs -L 1 -P "${CPUS}" -t -i bash -c '{}'
