#!/bin/bash
CPUNUM=$(grep -c ^processor /proc/cpuinfo)
LOGDIR="/root/bench_log"
mkdir -p ${LOGDIR}
rm -rf /mnt/tmp
mkdir -p /mnt/tmp
## FILE IO
# rand write
fio --directory=/mnt/tmp --size=5g --rw=randrw --refill_buffers --norandommap --randrepeat=0 --ioengine=libaio --bs=4k --rwmixread=0 --iodepth=32 --numjobs=${CPUNUM} --runtime=60 --group_reporting --name=4ktest | tee ${LOGDIR}/fio_bs4k_randw_$(date +%s).log
rm -rf /mnt/tmp/*
# rand write
fio --directory=/mnt/tmp --size=5g --rw=randrw --refill_buffers --norandommap --randrepeat=0 --ioengine=libaio --bs=4m --rwmixread=0 --iodepth=32 --numjobs=${CPUNUM} --runtime=60 --group_reporting --name=4mtest | tee ${LOGDIR}/fio_bs4m_randw_$(date +%s).log
rm -rf /mnt/tmp/*
# rand read
fio --directory=/mnt/tmp --size=5g --rw=randrw --refill_buffers --norandommap --randrepeat=0 --ioengine=libaio --bs=4k --rwmixread=100 --iodepth=32 --numjobs=${CPUNUM} --runtime=60 --group_reporting --name=4ktest | tee ${LOGDIR}/fio_bs4k_randr_$(date +%s).log
rm -rf /mnt/tmp/*
# rand read
fio --directory=/mnt/tmp --size=5g --rw=randrw --refill_buffers --norandommap --randrepeat=0 --ioengine=libaio --bs=4m --rwmixread=100 --iodepth=32 --numjobs=${CPUNUM} --runtime=60 --group_reporting --name=4mtest | tee ${LOGDIR}/fio_bs4m_randr_$(date +%s).log
rm -rf /mnt/tmp/*
# seq write
fio --directory=/mnt/tmp --size=5g --rw=write --refill_buffers --norandommap --randrepeat=0 --ioengine=libaio --bs=4k --rwmixread=0 --iodepth=32 --numjobs=${CPUNUM} --runtime=60 --group_reporting --name=4ktest | tee ${LOGDIR}/fio_bs4k_seqw_$(date +%s).log
rm -rf /mnt/tmp/*
# seq write
fio --directory=/mnt/tmp --size=5g --rw=write --refill_buffers --norandommap --randrepeat=0 --ioengine=libaio --bs=4m --rwmixread=0 --iodepth=32 --numjobs=${CPUNUM} --runtime=60 --group_reporting --name=4mtest | tee ${LOGDIR}/fio_bs4m_seqw_$(date +%s).log
rm -rf /mnt/tmp/*
# seq read
fio --directory=/mnt/tmp --size=5g --rw=read --refill_buffers --norandommap --randrepeat=0 --ioengine=libaio --bs=4k --rwmixread=100 --iodepth=32 --numjobs=${CPUNUM} --runtime=60 --group_reporting --name=4ktest | tee ${LOGDIR}/fio_bs4k_seqr_$(date +%s).log
rm -rf /mnt/tmp/*
# seq write
fio --directory=/mnt/tmp --size=5g --rw=read --refill_buffers --norandommap --randrepeat=0 --ioengine=libaio --bs=4m --rwmixread=100 --iodepth=32 --numjobs=${CPUNUM} --runtime=60 --group_reporting --name=4mtest | tee ${LOGDIR}/fio_bs4m_seqr_$(date +%s).log
rm -rf /mnt/tmp/*
