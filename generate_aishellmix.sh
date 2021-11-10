#!/bin/bash
set -eu  # Exit on error

aishell1_dir=/youraishell1path/aishell1/wav
aishell1_md_dir=/youraishell1path/aishell1/metadata
wham_dir=/yourwhampath/wham_noise
wham_md_dir=/metadata/Wham_noise
metadata_dir=/youraishellmixpath/aishellmix/metadata
aishellmix_outdir=/youraishellmixpath/aishellmix

# If you wish to rerun this script in the future please comment this line out.
python scripts/augment_train_noise.py --wham_dir $wham_dir

for n_src in 2 3; do
  metadata_outdir=$metadata_dir/Aishell1"Mix"$n_src
  python scripts/create_aishellmix_metadata.py --aishell1_dir $aishell1_dir \
    --aishell1_md_dir $aishell1_md_dir \
    --wham_dir $wham_dir \
    --wham_md_dir $wham_md_dir \
    --metadata_outdir $metadata_outdir \
    --n_src $n_src

  python scripts/create_aishellmix_from_metadata.py --aishell1_dir $aishell1_dir \
    --wham_dir $wham_dir \
    --metadata_dir $metadata_outdir \
    --aishellmix_outdir $aishellmix_outdir \
    --n_src $n_src \
    --freqs 8k 16k \
    --modes max min \
    --types mix_clean mix_both mix_single
done
