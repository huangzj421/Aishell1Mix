#!/bin/bash
set -eu  # Exit on error

storage_dir=$1
aishell1_dir=$storage_dir/data_aishell/wav
wham_dir=$storage_dir/wham_noise
aishell1mix_outdir=$storage_dir/aishell1mix

aishell1_md_dir=metadata/aishell1
wham_md_dir=metadata/wham_noise
metadata_outdir=$storage_dir/aishell1mix/metadata

function Aishell1() {
	if ! test -e $aishell1_dir; then
		echo "Download Aishell1 into $storage_dir"
		# If downloading stalls for more than 20s, relaunch from previous state.
		wget -c --tries=0 --read-timeout=20 https://us.openslr.org/resources/33/data_aishell.tgz -P $storage_dir 
		# If slow, try to download at https://www.openslr.org/33 manually
                wget -c --tries=0 --read-timeout=20 https://us.openslr.org/resources/33/resource_aishell.tgz -P $storage_dir 
		# If slow, try to download at https://www.openslr.org/33 manually
		tar -xzf $storage_dir/data_aishell.tgz -C $storage_dir
                tar -xzf $storage_dir/resource_aishell.tgz -C $storage_dir
		for gz in $aishell1_dir/*.tar.gz
	       	do 
			tar -xzf $gz -C $aishell1_dir
			rm -rf $gz
		done
		rm -rf $storage_dir/data_aishell.tgz
                rm -rf $storage_dir/resource_aishell.tgz
	fi
}

function Wham() {
	if ! test -e $wham_dir; then
		echo "Download wham_noise into $storage_dir"
		# If downloading stalls for more than 20s, relaunch from previous state.
		wget -c --tries=0 --read-timeout=20 https://storage.googleapis.com/whisper-public/wham_noise.zip -P $storage_dir
		unzip -qn $storage_dir/wham_noise.zip -d $storage_dir
		rm -rf $storage_dir/wham_noise.zip
	fi
}

Aishell1 &
Wham &
wait

# If you wish to rerun this script in the future please comment this line out.
python scripts/augment_train_noise.py --wham_dir $wham_dir

for n_src in 2 3; do
  metadata_outdir=$metadata_outdir/Aishell1"Mix"$n_src
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
