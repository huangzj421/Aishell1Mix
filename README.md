## News
Now you can train models of this dataset with speechbrain [here](https://github.com/speechbrain/speechbrain/tree/develop/recipes/Aishell1Mix/separation).

## Aishell1Mix
Aishell1Mix is a mandarin version of speech separation dataset like WSJMix and LibriMix. It mixes 2 or 3 speaker sources from the open source mandarin speech corpus [Aishell1](http://www.openslr.org/33/) with the noise dataset [WHAM](https://wham.whisper.ai/). The scripts are modified from [LibriMix](https://github.com/JorisCos/LibriMix). Please refer to it for more details.

## How to generate
 Firstly make sure that SoX is installed on your machine.
* For windows :
```
conda install -c groakat sox
```
* For Linux or MacOS:
```
conda install -c conda-forge sox
```
 Then to generate LibriMix, clone the repo and run the main script: [`generate_aishell1mix.sh`](./generate_aishell1mix.sh)
  ```
  git clone https://github.com/huangzj421/Aishell1Mix.git
  cd Aishell1Mix
  pip install -r requirements.txt
  ./generate_aishell1mix.sh storage_dir
  ```

## Features
In Aishell1Mix you can choose :
* The number of sources in the mixtures.
* The sample rate  of the dataset from 16 KHz to any frequency below. 
* The mode of mixtures : min (the mixture ends when the shortest source ends) or max (the mixtures ends with the longest source)
* The type of mixture : mix_clean (utterances only) mix_both (utterances + noise) mix_single (1 utterance + noise)

You can customize the generation by editing ``` generate_aishell1mix.sh ```.
