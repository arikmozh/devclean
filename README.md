# devclean

> All-in-one disk cleanup for developers. Reclaim gigabytes in seconds.

Stop running `npkill`, `docker system prune`, `brew cleanup`, and `pip cache purge` separately. One tool. Everything clean.

```
$ devclean scan

  devclean — scanning /Users/you

  Scanning node_modules... found 23 (4.7 GB)
  Scanning Cargo targets... found 2 (1.2 GB)
  Scanning package manager caches... found 2 (890.0 MB)
  Scanning Docker... found 3 item(s)
  Scanning Homebrew cache... 2.1 GB
  Scanning Xcode DerivedData... 3.4 GB

  Total reclaimable: 12.3 GB
  Run devclean clean to free this space
```

## Install

```bash
npm install -g devclean-cli
```

## Usage

### Scan for reclaimable space

```bash
devclean scan                    # scan home directory
devclean scan -p ~/projects      # scan specific directory
devclean scan --no-docker        # skip Docker scan
```

### Clean everything

```bash
devclean clean                   # clean all found items
devclean clean --dry-run         # preview what would be deleted
devclean clean --older-than 30   # only clean items older than 30 days
```

### Clean specific targets

```bash
devclean clean --node-modules    # only node_modules
devclean clean --docker          # only Docker artifacts
devclean clean --brew            # only Homebrew cache
devclean clean --pip             # only pip cache
devclean clean --cargo           # only Cargo target dirs
devclean clean --xcode           # only Xcode DerivedData
devclean clean --caches          # only npm/yarn caches
```

## What it cleans

| Target | What | How |
|--------|------|-----|
| node_modules | Unused dependency folders | `rm -rf` |
| Docker | Dangling images, stopped containers, build cache | `docker system prune` |
| Homebrew | Downloaded package cache | `brew cleanup --prune=all` |
| pip | Python package cache | `pip cache purge` |
| Cargo | Rust build artifacts (`target/`) | `rm -rf` |
| Xcode | DerivedData build cache | `rm -rf` |
| npm/yarn | Package manager download cache | `npm cache clean` |

## Safety

- `devclean scan` is **read-only** — it never deletes anything
- `devclean clean --dry-run` shows what would be deleted
- `devclean clean --older-than 30` protects active projects
- Only deletes well-known cache/build directories, never source code

## License

MIT
