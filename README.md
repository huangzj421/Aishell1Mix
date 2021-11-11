# Aishell1Mix
Aishell1Mix is a mandarin version of speech separation dataset like WSJMix and LibriMix. It mixes 2 or 3 speaker wavs from open source mandarin speech corpus aishell1 and WHAM noise. The scripts are modified from https://github.com/JorisCos/LibriMix. Please reference it for more details.

# How to generate
* Firstly download aishell1(http://www.openslr.org/33/) and uncompress the data_aishell&resource_aishell in your aishell1 path.
* Then download WHAM noise(https://wham.whisper.ai/) and unzip WHAM! noise dataset in your wham path.
* Lastly clone the repo, specify the correct path in [`generate_aishell1mix.sh`](./generate_aishell1mix.sh) and run it:

  ```
  git clone https://github.com/huangzj421/Aishell1Mix.git
  cd Aishell1Mix
  (Specify the download dataset path and output aishell1mix path in the main script)
  ./generate_aishell1mix.sh
  ```
