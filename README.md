# BDT Community Balance Mod
A Natural Selection 2 balance and feature mod developed and maintained by the BDT.

## Building
To build the mod run the create_build.sh script in the project root.

```bash
./create_build.sh [build_target] [build_type]
```

e.g.
```bash
./create_build.sh dev launchpad
```

There are currently two types of builds:
 - launchpad: to be used with the Launchpad utility
 - steamcmd: to be used with steamcmd (or publish.sh)

## Publishing
To publish the mod on the workshop first [build](#building) the mod, then depending on the build you can either run Launchpad or steamcmd.

### Launchpad
To publish the mod with Launchpad open the build directory with Launchpad and click publish

### Steamcmd
To publish the mod with Steamcmd run the ./publish.sh script

## Large File Storage (LFS)
To deal with the sound files (>100 Mbs), we must use LFS. To install LFS use the following commands:
1. sudo apt-get install git-lfs
2. git lfs install

To select files to ignore:
1. git lfs track "FILE EXTENSION (.txt, .fsb, etc.)" -- Ex. git lfs track "*.fsb"
2. git add "FILE PATH" -- Ex. git add /mnt/d/Github/CommunityBalanceMod/src/sound/eem.bank00.fsb

Commit with the chosen files to ignore:
1. git commit -m "COMMIT MESSAGE"
