#!/bin/bash
set -eu  # Exit on error

librispeech_dir=/mnt/huangzijian/aishell1/wav
librispeech_md_dir=/mnt/huangzijian/aishell1/metadata
wham_dir=/mnt/huangzijian/librimix/wham_noise
wham_md_dir=/mnt/huangzijian/librimix/LibriMix-master/metadata/Wham_noise
metadata_dir=/mnt/huangzijian/aishellmix/metadata
librimix_outdir=/mnt/huangzijian/aishellmix

# If you wish to rerun this script in the future please comment this line out.
python scripts/augment_train_noise.py --wham_dir $wham_dir

for n_src in 2 3; do
  metadata_outdir=$metadata_dir/Libri$n_src"Mix"
  python scripts/create_aishellmix_metadata.py --librispeech_dir $librispeech_dir \
    --librispeech_md_dir $librispeech_md_dir \
    --wham_dir $wham_dir \
    --wham_md_dir $wham_md_dir \
    --metadata_outdir $metadata_outdir \
    --n_src $n_src

  python scripts/create_aishellmix_from_metadata.py --librispeech_dir $librispeech_dir \
    --wham_dir $wham_dir \
    --metadata_dir $metadata_outdir \
    --librimix_outdir $librimix_outdir \
    --n_src $n_src \
    --freqs 8k 16k \
    --modes max min \
    --types mix_clean mix_both mix_single
done
