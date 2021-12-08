import os
import argparse
from urllib.request import urlretrieve
import tarfile
import zipfile
import glob
import tqdm.contrib.concurrent
import soundfile as sf
import functools
from pysndfx import AudioEffectsChain


parser = argparse.ArgumentParser(description="storage path")
parser.add_argument('path', type=str, help="Path to the aishell1mix")
args = parser.parse_args()
print(args.path)

aishell1_dir=os.path.join(args.path, 'data_aishell')
wham_dir=os.path.join(args.path, 'wham_noise')
aishell1mix_outdir=os.path.join(args.path, 'aishell1mix')

def extracttar(filename):
    tar = tarfile.open(filename)
    tar.extractall(path=os.path.dirname(filename))
    tar.close()
    os.remove(filename)

def augment_noise(sound_paths, speed):
    print(f"Change speed with factor {speed}")
    tqdm.contrib.concurrent.process_map(
        functools.partial(apply_fx, speed=speed),
        sound_paths,
        chunksize=10
    )

def apply_fx(sound_path, speed):
    # Get the effect
    fx = (AudioEffectsChain().speed(speed))
    s, rate = sf.read(sound_path)
    # Get 1st channel
    s = s[:, 0]
    # Apply effect
    s = fx(s)
    # Write the file
    sf.write(f"""{sound_path.replace(
        '.wav',f"sp{str(speed).replace('.','')}" +'.wav')}""", s, rate)


def reporthook(blocknum, blocksize, totalsize): 
      print("\rdownloading: %5.1f%%"%(100.0*blocknum * blocksize/totalsize), end='')

if not os.path.exists(aishell1_dir):
    print("Download Aishell1 into %s"%args.path)
    urlretrieve("https://us.openslr.org/resources/33/data_aishell.tgz",
        os.path.join(args.path, "data_aishell.tgz"), reporthook=reporthook)
    urlretrieve("https://us.openslr.org/resources/33/resource_aishell.tgz",
        os.path.join(args.path, "resource_aishell.tgz"), reporthook=reporthook)
    extracttar(os.path.join(args.path, 'data_aishell.tgz'))
    files = glob.glob(os.path.join(aishell1_dir, "wav/*.gz"))
    for f in files: extracttar(f)
    extracttar(os.path.join(args.path, 'resource_aishell.tgz'))

if not os.path.exists(wham_dir):
    print("Download Wham noise dataset into %s"%args.path)
    urlretrieve("https://storage.googleapis.com/whisper-public/wham_noise.zip",
        os.path.join(args.path, "wham_noise.zip"), reporthook=reporthook)
    file = zipfile.ZipFile(os.path.join(args.path, 'wham_noise.zip'))
    file.extractall(path=args.path)
    os.remove(os.path.join(args.path, 'wham_noise.zip'))

# Get train dir
subdir = os.path.join(wham_dir, 'tr')
# List files in that dir
sound_paths = glob.glob(os.path.join(subdir, '**/*.wav'), recursive=True)
# Avoid running this script if it already have been run
if len(sound_paths) == 60000:
    print("It appears that augmented files have already been generated.\n" "Skipping data augmentation.")
elif len(sound_paths) != 20000:
    print("It appears that augmented files have not been generated properly\n" "Resuming augmentation.")
    originals = [x for x in sound_paths if 'sp' not in x]
    to_be_removed_08 = [x.replace('sp08','') for x in sound_paths if 'sp08' in x]
    to_be_removed_12 = [x.replace('sp12','') for x in sound_paths if 'sp12' in x ]
    sound_paths_08 = list(set(originals) - set(to_be_removed_08))
    sound_paths_12 = list(set(originals) - set(to_be_removed_12))
    augment_noise(sound_paths_08, 0.8)
    augment_noise(sound_paths_12, 1.2)
else:
    print(f'Augmenting {subdir} files')
    # Transform audio speed
    augment_noise(sound_paths, 0.8)
    augment_noise(sound_paths, 1.2)

from scripts.create_aishell1_metadata import create_aishell1_metadata
aishell1_md_dir = os.path.join(aishell1_dir, 'metadata')
if not os.path.exists(aishell1_md_dir):
    os.makedirs(aishell1_md_dir, exist_ok=True)
    create_aishell1_metadata(aishell1_dir, aishell1_md_dir)

from scripts.create_wham_metadata import create_wham_noise_metadata
wham_md_dir = os.path.join(wham_dir, 'meta')
if not os.path.exists(wham_md_dir):
    os.makedirs(wham_md_dir, exist_ok=True)
    create_wham_noise_metadata(wham_dir, wham_md_dir)

n_spks = 2
from scripts.create_aishell1mix_metadata import create_aishell1mix_metadata
aishell1mix_md_outdir = os.path.join(aishell1mix_outdir,'metadata','Aishell1Mix%i'%n_spks)
if not os.path.exists(aishell1mix_md_outdir):
    os.makedirs(aishell1mix_md_outdir, exist_ok=True)
    create_aishell1mix_metadata(os.path.join(aishell1_dir, "wav"), aishell1_md_dir, 
                                wham_dir, wham_md_dir, aishell1mix_md_outdir, n_spks)

freqs=['8k', '16k']
modes=['max', 'min']
types=['mix_clean', 'mix_both', 'mix_single']
from scripts.create_aishell1mix_from_metadata import create_aishell1mix
aishell1mix_outdir = os.path.join(aishell1mix_outdir,'Aishell1Mix%i'%n_spks)
if not os.path.exists(aishell1mix_outdir):
    create_aishell1mix(os.path.join(aishell1_dir, "wav"), wham_dir, aishell1mix_outdir, 
                        aishell1mix_md_outdir, freqs, n_spks, modes, types)
