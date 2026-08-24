---
icon: lucide/folder-tree
status: new
---

# RFC: Overlay Filesystem

!!! info "Request for Comment"

    This document is made with the intent of collecting feedback on the proposed approach. If you have any ideas, concerns, questions, improvements, etc… please do reach out on Discord.

    You can find me on the **Evolve Reunited 2.0** Discord Server.

## Motivation

Evolve, despite being "dead" for near a decade, it still has people joining on a daily basis, inquiring about instructions and asking for support on the steps needed to download the necessary files, patches and configurations.
You need to obtain the legacy files, need to obtain a patch, correct the patch's output directory, merge them, then add a config file; Add the fact that there are two major versions of Evolve being
played — Legacy Evolve Vanilla, and Legacy Evolve Modded — it might become easy to make mistakes when applying patches atop of patches, reverting patches, and so on.

## Abstract

Using an approach inspired by Docker layers, this document tries to present an OS-agnostic (:fontawesome-brands-windows: & :fontawesome-brands-linux:) method to easily create a
file structure derived from multiple layers of patches atop of patches that are easy to regenerate, to revert and to switch between.

The proposed solution is to have any game files _not_ be stored in the game directly, but have all files be present in a "package"
directory, from which OS-level Hardlinks are copied over to the respective location in the actual game directory.

## :octicons-checkbox-16: Requirements

- [x] **Must be compatible with both :fontawesome-brands-windows: Windows and :fontawesome-brands-linux: Linux**
  > While Linux users are a minority, they are still part of the community.
  > As the game runs on Linux without any major issues assuming you have the right Proton version set up, there is no reason to exclude them here.
  >
  > Hardlinks / Multireferences to Inodes are supported by both Window's NTFS and all major Linux Filesystems.

- [x] **Must require minimal permissions**
  > Symbolic Links were a preferred choice over Hardlinks, however, Windows' support for Symlinks limits the use to users with
  > administrative permissions. It would also be very suspicious and annoying if a Launcher were to ask for _administrative_ permissions on the device just to move files.

- [x] **Transparent and Auditable**
  > It should be intuitive to technically savvy users what is happening "under the hood". They should have the option to easily add new patches. Hardcoding how patches are applied is out of question.

- [x] **Resilient to user error**
  >
  > If the user does something stupid, the system should be able to reconcile itself.
  >
  > - if the user **adds** new files into the Game Dir, they are not part of the calculated file tree and the system can mark them for deletion
  > - if the user **removes** files from the Game dir, they are not actually _gone_. The Game directory's hardlink and the file within the Datapack both point to the same Inode (basically the same "file"). So if it's gone in the game directory, we detect it's missing and just create a new hardlink.
  > - if the user **edits** files from the Game dir, the files hash also changes in the Datapack. We can detect this, because the file's name no longer equals the md5sum digest. In this instance, this would cause a refetch from the datasource.

- [x] **Resilient to Change**
  > Given that new versions of Modded will be added and Servers are always at risk of getting retired, the patching logic must be easily redirectable by end users. User must for example be able to override a download location or point to a local archive.

## The Proposal

Establish a concept of "Datapacks". A Datapack consists of one or many **optional** data sources pointing to an archive like a `.zip`, `.tar`, `.tar.gz` and so on.
The Archive's file structure and directories are initially ignored. The downloaded files are named and stored by their `md5` hashed name, without file ending.

The Datapack also contains a set of files it wants to **add**, **drop**, **pull**

### Commands

#### **`@`** source

Defines a data source. If a file is missing, these sources will be refetched.

``` diff
@ "description" https://example.com/file.tgz # this is a comment
@ file://C:/some/location/file.tar 
# multiple sources are allowed. no sources are also allowed
```

The result of that fetch will be **flattened** and all files renamed to their `md5` digest.

#### **`+`** add

Adds one of the files added via a [source](#source).

``` diff
# + followed by a md5 hash, followed by the file location and name, relative to the game dir root
+ 738d9b19d71c6736508a82f17493e46e  /bin64_SteamRetail/Evolve.exe
+ 13b51bb57889eb86d31214b29cda0124  /bin64_SteamRetail/EvolveLegacyRebornServer.dll
+ a2d8d927ad696017008567300af0c5ca  /bin64_SteamRetail/EvolveLogging.ini
```

#### **`-`** drop

Removes a files from the desired state.

``` diff
# Example datapack that would drop any languages that are not USA-EN
# Note that no hashes are provided here.
- /Game/Languages/BRA-PT_xml.pak
- /Game/Languages/CHN-ZH-HANS_xml.pak
- /Game/Languages/CHN-ZH_xml.pak
- /Game/Languages/DEU-DE_audio_stage1.pak
- /Game/Languages/DEU-DE_audio_stage3.pak
- /Game/Languages/DEU-DE_xml.pak
- /Game/Languages/ESP-ES_audio_stage1.pak
- /Game/Languages/ESP-ES_audio_stage3.pak
- /Game/Languages/ESP-ES_xml.pak
- /Game/Languages/FRA-FR_audio_stage1.pak
- /Game/Languages/FRA-FR_audio_stage3.pak
- /Game/Languages/FRA-FR_xml.pak
- /Game/Languages/ITA-IT_audio_stage1.pak
- /Game/Languages/ITA-IT_audio_stage3.pak
- /Game/Languages/ITA-IT_xml.pak
- /Game/Languages/JPN-JA_xml.pak
- /Game/Languages/KOR-KO_xml.pak
- /Game/Languages/RUS-RU_audio_stage1.pak
- /Game/Languages/RUS-RU_audio_stage3.pak
- /Game/Languages/RUS-RU_xml.pak
```

??? note "Discussion"

    - I wonder if allowing folders or globs here, akin to this
      would be a useful feature.

    ``` diff
    - /Game/Languages/BRA-*
    - /Game/Languages/CHN-*
    - /Game/Languages/DEU-*
    - /Game/Languages/ESP-*
    - /Game/Languages/FRA-*
    - /Game/Languages/ITA-*
    - /Game/Languages/JPN-*
    - /Game/Languages/KOR-*
    - /Game/Languages/RUS-*
    ```

    - The lack of adding hashes is intentional here. The "effective tree" should be constructed in one operation. Having to recheck md5 sums after _every_ layer would be detrimental to speed.

#### **`*`** pull

Instead of pushing files from the Datapack _to_ the Game Directory, this inverts the flow. This pulls the file from the Game Directory into the Datapack. Use this for example for save files.
Because this is intenteded primarily for files that change over time (=Save Files), we do not track an md5sum. Instead, we just hardlink any files matched by the glob selection.

``` diff
# note that there are no aliases and no hashes
* /bin64_SteamRetail/EvolveCrack/273350/*
# This is a glob (as seen by the suffix *)
# This will cause any file that starts with that path to be treated as pulled.
```

!!! info "Interactions with `drop` and `add`"

    If subsequent layers `drop` your files, they will be removed from the **Game Files**. They will however **remain** in the Datapack directory. So if you remove that Overlay Datapack, your files will still remain.

    If subsequent layers `add` files (or override them), they will **not** be treated as dropped, unless that (or further layers up the chain) mark it as dropped.

#### **`#`** comment

Just for completeness sake:

- If a Line starts with a `#` it is treated as a comment
- If a line has a `#` with a space before it, the rest of the line is also treated as a comment

### Anticipating some questions

**:question: Doesn't this cause at least twice as many files?**

> Yes, but no — while there are at least twice as many files — potentially even more if you have more datapacks e.g. for Modded and Vanilla — these "files" do not each consume the full file's amount of space.
> 
> At it's core, a file is no more than a pointer to an [inode](https://en.wikipedia.org/wiki/Inode). The Inode is where the actual file is "stored" (_heavy_ simplification, but you get the idea).
> Multiple files can point to the same Inode! They then share the same contents and metadata, even after one of the file was modified.

**:question: Isn't hashing slow?**

> Yes it is. The proposed changes should only be run against the entire Game Directory when absolutely necessary.
> 
> In the context of switching between for example Vanilla and Modded, one can look at just the files that are supposed to change.
> Both share the same "base" containing the legacy files. If we deem all those files in sync, we can skip them.
> 
> Besides that, it is much cheaper to just look for extraneuous files, so additional or missing files can be detected near instantly.
> Potentially there are also some optimizations possible by looking at when a file has been last modified.

### Datapacks

I would propose to start with the following datapacks. A description of each pack is defined below the graphic

``` mermaid
graph TD
    EvolveFilesLegacy --> RiceFix;
    RiceFix --> Modded;
    
    RiceFix ---> B:{{NoCutscenes}};
    Modded ---> B:{{NoCutscenes}}
    
    RiceFix ---> A:{{Only$Language}};
    Modded ---> A:{{Only$Language}};

    classDef leaves fill:#522;
    class NoCutscenes leaves;
    class Only$Language leaves;
```

#### EvolveFilesLegacy

Uses Albtraum's Host for obtaining the Legacy Files. This effectively marks the Legacy files without any patches applied.

[`add`](#add)s all files from the archive over, marks the Save directory to be [`pull`](#pull)ed.

#### RiceFix

Uses Albtraum's Host for obtaining the RiceFix. Game is playable at this state (="Vanilla").

[`add`](#add)s all files from the fix, overriding existing files in the process.

#### Modded

Applies patches needed to play modded

[`add`](#add)s all the files from modded, overriding existing files in the process.

!!! note "Source?"

    Need to look at how the patch for Modded works. Is it just the usual overlaying of new files atop existing files?

#### NoCutscenes / Only$Language

These are the final Datapacks.
`Only$Language` is meant to represent all languages. So this is effective `OnlyRU`, `OnlyDE`, etc.

It's hard to represent in the graph, but you can combine them (e.g. `NoCutscenes` and `OnlyDE`)

### Pruning

Now, with `NoCutscenes` and `Only$Language`, we can remove the **Game** files, but the Datapack will still remain.

This is where **File Pruning** is introduced as an additional feature.

Say you want to be able to switch between Legacy and Modded, but you're tight on space. You add the Datapacks, but the problem here is that while the files are gone in the Game dir, they still persist in the Datapack.

The solution here is to let the user optionally define which targets they want to be able to achieve, say for example

- `EvolveFilesLegacy`.`RiceFix`.`Modded`.`NoCutscenes` and
- `EvolveFilesLegacy`.`RiceFix`.`NoCutscenes`

This way the system knows which files it must retain and can prune away any extraneuous files, including the cutscenes, because they are no longer needed in both cases.

If for example the target states look like

- `EvolveFilesLegacy`.`RiceFix`.`Modded`.`NoCutscenes`.`OnlyRU` and
- `EvolveFilesLegacy`.`RiceFix`.`OnlyDE`

we can no longer prune the cutscenes, because the second target still wants them. However, we can prune any language that is not `DE` or `RU`.

## Tree Resolution

When building the tree of files, each file is essentially tracked by

- the desired state of the file (`pushed`, `pulled` or unset/removed)
- the origin datapack (so we know where to hardlink it to)

This in the end gives you a list of files to sync and where to find them.