#!/usr/bin/env bash
#
# Usage:
#   test_samspect.sh

set -uex

TEST_DIR=$(dirname "${0}")
SAMTOOLS_QC_SH=$(realpath "${TEST_DIR}/../bin/samtools_qc.sh")
TEST_WORK_DIR="${TEST_DIR}/output"
TEST_SAM_DIR="${TEST_WORK_DIR}/sam"
TEST_STAT_DIR="${TEST_WORK_DIR}/stat"

[[ -d "${TEST_WORK_DIR}" ]] && rm -rf "${TEST_WORK_DIR}"
mkdir -p "${TEST_SAM_DIR}"
mkdir -p "${TEST_STAT_DIR}"

WD="${PWD}" && cd "${TEST_SAM_DIR}"
curl -sSO https://raw.githubusercontent.com/samtools/samtools/develop/examples/toy.sam
curl -sSO https://raw.githubusercontent.com/samtools/samtools/develop/examples/toy.fa
samtools view -bS -o toy.bam toy.sam
samtools view -CS -T toy.fa -o toy.cram toy.sam
samtools index toy.bam
samtools index toy.cram
samtools faidx toy.fa
cd "${WD}"

${SAMTOOLS_QC_SH} "${TEST_SAM_DIR}" "${TEST_STAT_DIR}"
