#!/bin/bash
set -eu  # Exit on error

aishell1_dir=/youraishell1path/aishell1/data_aishell/wav
aishell1_md_dir=/metadata/aishell1
wham_dir=/yourwhampath/wham_noise
wham_md_dir=/metadata/wham_noise
metadata_dir=/youraishell1mixpath/aishell1mix/metadata
aishell1mix_outdir=/youraishell1mixpath/aishell1mix

# If you wish to rerun this script in the future please comment this line out.
python scripts/augment_train_noise.py --wham_dir $wham_dir

for n_src in 2 3; do
  metadata_outdir=$metadata_dir/Aishell1"Mix"$n_src
  python scripts/create_aishell1mix_metadata.py --aishell1_dir $aishell1_dir \
    --aishell1_md_dir $aishell1_md_dir \
    --wham_dir $wham_dir \
    --wham_md_dir $wham_md_dir \
    --metadata_outdir $metadata_outdir \
    --n_src $n_src

  python scripts/create_aishell1mix_from_metadata.py --aishell1_dir $aishell1_dir \
    --wham_dir $wham_dir \
    --metadata_dir $metadata_outdir \
    --aishell1mix_outdir $aishell1mix_outdir \
    --n_src $n_src \
    --freqs 8k 16k \
    --modes max min \
    --types mix_clean mix_both mix_single
done
