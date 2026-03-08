---
title: I freed 12GB of disk space in 10 seconds with one CLI command
published: true
tags: node, javascript, productivity, devtools
cover_image:
---

You know that "disk almost full" notification that pops up right when you're in the middle of something important? Yeah. That one.

I used to spend 20 minutes hunting down what was eating my disk. Turns out, the answer was almost always the same: **my own dev tools**.

## Your dev machine is silently hoarding gigabytes of junk

Here is a dirty secret nobody talks about at standup: every project you have ever cloned, built, and forgotten about is still sitting on your disk, quietly consuming space.

That side project from January? Its `node_modules` is still there. That Rust experiment you tried for a weekend? The `target/` folder is 800MB. Those three Docker tutorials? Dangling images galore.

And the worst part is that **every tool has its own cleanup command**:

```
rm -rf node_modules          # per project, manually
docker system prune           # Docker
brew cleanup --prune=all      # Homebrew
pip cache purge               # Python
cargo clean                   # Rust, per project
rm -rf ~/Library/Developer/Xcode/DerivedData  # Xcode
npm cache clean --force       # npm
```

Seven different commands. Some need to be run per-project. Some you forget exist. None of them give you a clear picture of how much space you are actually wasting.

I got tired of this, so I built something.

## Meet devclean: one CLI that scans and cleans everything

[devclean](https://github.com/arikmozh/devclean) is a single command that finds all the reclaimable space across your entire dev environment and lets you clean it in one shot.

Install it:

```bash
npm install -g devclean-cli
```

Then run a scan:

```bash
devclean scan
```

That is it. No config, no setup, no flags required. It walks your home directory and finds everything.

## What a real scan looks like

Here is what I saw the first time I ran it on my machine:

```
$ devclean scan

  devclean — scanning /Users/you

  Scanning node_modules... found 23 (4.7 GB)
      1.2 GB  142d ago  ~/old-client-project/node_modules
    891.0 MB   98d ago  ~/freelance-2024/node_modules
    620.3 MB   67d ago  ~/hackathon-app/node_modules
    ... 20 more

  Scanning Cargo targets... found 2 (1.2 GB)
      803.4 MB  ~/rust-playground/target
      421.1 MB  ~/cli-tool-experiment/target

  Scanning package manager caches... found 2 (890.0 MB)
      540.2 MB  npm cache — ~/.npm
      349.8 MB  yarn cache — ~/Library/Caches/Yarn

  Scanning Docker... found 3 item(s)
      5 dangling image(s)
      2 stopped container(s)
      Docker system (use docker system prune)

  Scanning Homebrew cache... 2.1 GB
        2.1 GB  ~/Library/Caches/Homebrew

  Scanning Xcode DerivedData... 3.4 GB
        3.4 GB  ~/Library/Developer/Xcode/DerivedData

  Total reclaimable: 12.3 GB
  Run devclean clean to free this space
```

**12.3 GB.** Just sitting there. Doing nothing.

Twenty-three `node_modules` folders from projects I had not touched in months. Cargo build artifacts from a language I was "just trying out." Homebrew downloads for packages I installed six months ago.

## Preview before you delete

Not ready to pull the trigger? Use `--dry-run`:

```bash
$ devclean clean --dry-run

  devclean — dry run

  [dry-run] Would delete 1.2 GB  ~/old-client-project/node_modules
  [dry-run] Would delete 891.0 MB  ~/freelance-2024/node_modules
  [dry-run] Would delete 620.3 MB  ~/hackathon-app/node_modules
  ...
  [dry-run] Would delete 803.4 MB  ~/rust-playground/target
  [dry-run] Would clean npm cache
  [dry-run] Would run docker system prune
  [dry-run] Would clean Homebrew cache
  [dry-run] Would delete 3.4 GB  ~/Library/Developer/Xcode/DerivedData

  Dry run complete. No files were deleted.
```

Nothing gets touched. You see exactly what would happen.

## Clean only what you want

Maybe you only care about `node_modules` right now. No problem:

```bash
devclean clean --node-modules
```

Or just Docker:

```bash
devclean clean --docker
```

Or a specific directory:

```bash
devclean clean -p ~/projects/2024
```

Every target has its own flag, so you stay in control.

## Protect active projects with --older-than

This is my favorite flag. If you are worried about cleaning `node_modules` for a project you are actively working on, just add an age filter:

```bash
devclean clean --older-than 30
```

This only deletes items that have not been modified in 30+ days. Your current projects are untouched. That project from three months ago that you will "definitely get back to"? Gone. You can always `npm install` again in 15 seconds.

I run this on a cron job every week:

```bash
devclean clean --older-than 60
```

Set it and forget it. My disk never fills up anymore.

## What it cleans

| Target | What it finds | How it cleans |
|--------|--------------|---------------|
| node_modules | All `node_modules/` folders across your projects | `rm -rf` |
| Docker | Dangling images, stopped containers, build cache | `docker system prune` |
| Homebrew | Downloaded package cache | `brew cleanup --prune=all` |
| pip | Python package download cache | `pip cache purge` |
| Cargo | Rust `target/` build directories | `rm -rf` |
| Xcode | DerivedData build cache | `rm -rf` |
| npm/yarn | Package manager download caches | `npm cache clean` / `yarn cache clean` |

Important: `devclean scan` is always **read-only**. It never deletes anything. You have to explicitly run `devclean clean` to remove files. And it only touches well-known cache and build directories, never your source code.

## Install

```bash
npm install -g devclean-cli
```

Then:

```bash
devclean scan             # see what's eating your disk
devclean clean --dry-run  # preview the cleanup
devclean clean            # free the space
```

Works on macOS and Linux. Requires Node.js 16+.

## Why I built this

I have been a developer for years and I still catch myself running out of disk space every few months. The fix is always the same: delete a bunch of `node_modules`, prune Docker, clear some caches. It takes 10-20 minutes of typing commands I have to look up every time.

devclean turns that into one command that takes 10 seconds.

If this sounds useful to you, give it a try. And if you like it, a star on [GitHub](https://github.com/arikmozh/devclean) goes a long way.

**Links:**
- GitHub: [github.com/arikmozh/devclean](https://github.com/arikmozh/devclean)
- npm: [npmjs.com/package/devclean-cli](https://www.npmjs.com/package/devclean-cli)

---

How much space did `devclean scan` find on your machine? Drop the number in the comments. I bet it is more than you think.
