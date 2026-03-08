#!/usr/bin/env node
const { Command } = require('commander');
const chalk = require('chalk');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const program = new Command();

program
  .name('devclean')
  .description('All-in-one disk cleanup for developers')
  .version('0.1.0');

// Utility: format bytes to human-readable
function formatSize(bytes) {
  if (bytes === 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + units[i];
}

// Utility: get directory size
function getDirSize(dirPath) {
  try {
    const out = execSync(`du -sk "${dirPath}" 2>/dev/null`, { encoding: 'utf8', timeout: 10000 });
    const kb = parseInt(out.split('\t')[0], 10);
    return isNaN(kb) ? 0 : kb * 1024;
  } catch {
    return 0;
  }
}

// Utility: get age in days
function getAgeDays(dirPath) {
  try {
    const stat = fs.statSync(dirPath);
    return Math.floor((Date.now() - stat.mtimeMs) / (1000 * 60 * 60 * 24));
  } catch {
    return 0;
  }
}

// Utility: delete directory
function rmDir(dirPath) {
  try {
    fs.rmSync(dirPath, { recursive: true, force: true });
    return true;
  } catch {
    return false;
  }
}

// Scanner: find node_modules directories
function scanNodeModules(root, maxDepth = 5) {
  const results = [];
  function walk(dir, depth) {
    if (depth > maxDepth) return;
    try {
      const entries = fs.readdirSync(dir, { withFileTypes: true });
      for (const entry of entries) {
        if (!entry.isDirectory()) continue;
        if (entry.name === '.git' || entry.name === '.Trash') continue;
        const full = path.join(dir, entry.name);
        if (entry.name === 'node_modules') {
          // Skip if it's inside another node_modules (nested dep)
          if (!dir.includes('node_modules')) {
            results.push(full);
          }
        } else {
          walk(full, depth + 1);
        }
      }
    } catch {}
  }
  walk(root, 0);
  return results;
}

// Scanner: Docker disk usage
function scanDocker() {
  const items = [];
  try {
    // Dangling images
    const dangling = execSync('docker images -f "dangling=true" --format "{{.ID}} {{.Size}}"', { encoding: 'utf8', timeout: 10000 }).trim();
    if (dangling) {
      const count = dangling.split('\n').length;
      items.push({ type: 'docker-dangling', label: `${count} dangling image(s)`, count });
    }

    // Stopped containers
    const stopped = execSync('docker ps -a -f "status=exited" --format "{{.ID}}"', { encoding: 'utf8', timeout: 10000 }).trim();
    if (stopped) {
      const count = stopped.split('\n').length;
      items.push({ type: 'docker-stopped', label: `${count} stopped container(s)`, count });
    }

    // Build cache
    const cacheOut = execSync('docker system df --format "{{.Type}}\t{{.Size}}\t{{.Reclaimable}}"', { encoding: 'utf8', timeout: 10000 }).trim();
    if (cacheOut) {
      items.push({ type: 'docker-system', label: 'Docker system (use docker system prune)', raw: cacheOut });
    }
  } catch {}
  return items;
}

// Scanner: Homebrew cache
function scanBrewCache() {
  try {
    const cachePath = execSync('brew --cache 2>/dev/null', { encoding: 'utf8', timeout: 10000 }).trim();
    if (cachePath && fs.existsSync(cachePath)) {
      const size = getDirSize(cachePath);
      if (size > 1024 * 1024) { // > 1MB
        return { path: cachePath, size };
      }
    }
  } catch {}
  return null;
}

// Scanner: pip cache
function scanPipCache() {
  try {
    const out = execSync('pip cache info 2>/dev/null', { encoding: 'utf8', timeout: 10000 });
    const sizeMatch = out.match(/Size:\s+(.+)/i);
    const locMatch = out.match(/Location:\s+(.+)/i);
    if (sizeMatch && locMatch) {
      return { path: locMatch[1].trim(), label: sizeMatch[1].trim() };
    }
  } catch {}
  try {
    const out = execSync('pip3 cache info 2>/dev/null', { encoding: 'utf8', timeout: 10000 });
    const sizeMatch = out.match(/Size:\s+(.+)/i);
    const locMatch = out.match(/Location:\s+(.+)/i);
    if (sizeMatch && locMatch) {
      return { path: locMatch[1].trim(), label: sizeMatch[1].trim() };
    }
  } catch {}
  return null;
}

// Scanner: Cargo target dirs
function scanCargoTargets(root, maxDepth = 4) {
  const results = [];
  function walk(dir, depth) {
    if (depth > maxDepth) return;
    try {
      const entries = fs.readdirSync(dir, { withFileTypes: true });
      for (const entry of entries) {
        if (!entry.isDirectory()) continue;
        if (entry.name === '.git' || entry.name === 'node_modules' || entry.name === '.Trash') continue;
        const full = path.join(dir, entry.name);
        if (entry.name === 'target' && fs.existsSync(path.join(dir, 'Cargo.toml'))) {
          results.push(full);
        } else {
          walk(full, depth + 1);
        }
      }
    } catch {}
  }
  walk(root, 0);
  return results;
}

// Scanner: Xcode DerivedData
function scanXcode() {
  const derived = path.join(process.env.HOME, 'Library/Developer/Xcode/DerivedData');
  if (fs.existsSync(derived)) {
    const size = getDirSize(derived);
    if (size > 1024 * 1024) {
      return { path: derived, size };
    }
  }
  return null;
}

// Scanner: npm/yarn/pnpm cache
function scanNpmCache() {
  const results = [];
  try {
    const npmCache = execSync('npm config get cache 2>/dev/null', { encoding: 'utf8', timeout: 5000 }).trim();
    if (npmCache && fs.existsSync(npmCache)) {
      const size = getDirSize(npmCache);
      if (size > 10 * 1024 * 1024) results.push({ path: npmCache, size, label: 'npm cache' });
    }
  } catch {}
  try {
    const yarnCache = execSync('yarn cache dir 2>/dev/null', { encoding: 'utf8', timeout: 5000 }).trim();
    if (yarnCache && fs.existsSync(yarnCache)) {
      const size = getDirSize(yarnCache);
      if (size > 10 * 1024 * 1024) results.push({ path: yarnCache, size, label: 'yarn cache' });
    }
  } catch {}
  return results;
}

// ==================== COMMANDS ====================

// SCAN command
program
  .command('scan')
  .description('Scan for reclaimable disk space')
  .option('-p, --path <dir>', 'Directory to scan', process.env.HOME)
  .option('--no-docker', 'Skip Docker scan')
  .option('--no-brew', 'Skip Homebrew cache scan')
  .option('--no-pip', 'Skip pip cache scan')
  .option('--no-xcode', 'Skip Xcode DerivedData scan')
  .action((opts) => {
    const scanPath = path.resolve(opts.path);
    console.log(chalk.bold(`\n  devclean — scanning ${scanPath}\n`));

    let totalSize = 0;
    const findings = [];

    // node_modules
    process.stdout.write(chalk.dim('  Scanning node_modules...'));
    const nodeModules = scanNodeModules(scanPath);
    const nmResults = nodeModules.map(p => ({ path: p, size: getDirSize(p), age: getAgeDays(p) }));
    nmResults.sort((a, b) => b.size - a.size);
    if (nmResults.length) {
      const nmTotal = nmResults.reduce((s, r) => s + r.size, 0);
      totalSize += nmTotal;
      console.log(chalk.green(` found ${nmResults.length} (${formatSize(nmTotal)})`));
      nmResults.forEach(r => {
        const age = r.age > 30 ? chalk.red(`${r.age}d ago`) : chalk.dim(`${r.age}d ago`);
        console.log(chalk.dim(`    ${formatSize(r.size).padStart(9)}  ${age}  ${r.path}`));
        findings.push({ type: 'node_modules', ...r });
      });
    } else {
      console.log(chalk.dim(' none found'));
    }

    // Cargo targets
    process.stdout.write(chalk.dim('  Scanning Cargo targets...'));
    const cargoTargets = scanCargoTargets(scanPath);
    const cargoResults = cargoTargets.map(p => ({ path: p, size: getDirSize(p), age: getAgeDays(p) }));
    if (cargoResults.length) {
      const cTotal = cargoResults.reduce((s, r) => s + r.size, 0);
      totalSize += cTotal;
      console.log(chalk.green(` found ${cargoResults.length} (${formatSize(cTotal)})`));
      cargoResults.forEach(r => {
        console.log(chalk.dim(`    ${formatSize(r.size).padStart(9)}  ${r.path}`));
        findings.push({ type: 'cargo_target', ...r });
      });
    } else {
      console.log(chalk.dim(' none found'));
    }

    // npm/yarn cache
    process.stdout.write(chalk.dim('  Scanning package manager caches...'));
    const pmCaches = scanNpmCache();
    if (pmCaches.length) {
      const pmTotal = pmCaches.reduce((s, r) => s + r.size, 0);
      totalSize += pmTotal;
      console.log(chalk.green(` found ${pmCaches.length} (${formatSize(pmTotal)})`));
      pmCaches.forEach(r => {
        console.log(chalk.dim(`    ${formatSize(r.size).padStart(9)}  ${r.label} — ${r.path}`));
        findings.push({ type: 'pm_cache', ...r });
      });
    } else {
      console.log(chalk.dim(' none found'));
    }

    // Docker
    if (opts.docker) {
      process.stdout.write(chalk.dim('  Scanning Docker...'));
      const docker = scanDocker();
      if (docker.length) {
        console.log(chalk.green(` found ${docker.length} item(s)`));
        docker.forEach(d => {
          console.log(chalk.dim(`    ${d.label}`));
          findings.push({ type: d.type, label: d.label });
        });
      } else {
        console.log(chalk.dim(' clean'));
      }
    }

    // Homebrew
    if (opts.brew) {
      process.stdout.write(chalk.dim('  Scanning Homebrew cache...'));
      const brew = scanBrewCache();
      if (brew) {
        totalSize += brew.size;
        console.log(chalk.green(` ${formatSize(brew.size)}`));
        console.log(chalk.dim(`    ${formatSize(brew.size).padStart(9)}  ${brew.path}`));
        findings.push({ type: 'brew_cache', ...brew });
      } else {
        console.log(chalk.dim(' clean'));
      }
    }

    // pip
    if (opts.pip) {
      process.stdout.write(chalk.dim('  Scanning pip cache...'));
      const pip = scanPipCache();
      if (pip) {
        console.log(chalk.green(` ${pip.label}`));
        console.log(chalk.dim(`    ${pip.path}`));
        findings.push({ type: 'pip_cache', ...pip });
      } else {
        console.log(chalk.dim(' clean'));
      }
    }

    // Xcode
    if (opts.xcode) {
      process.stdout.write(chalk.dim('  Scanning Xcode DerivedData...'));
      const xcode = scanXcode();
      if (xcode) {
        totalSize += xcode.size;
        console.log(chalk.green(` ${formatSize(xcode.size)}`));
        console.log(chalk.dim(`    ${formatSize(xcode.size).padStart(9)}  ${xcode.path}`));
        findings.push({ type: 'xcode', ...xcode });
      } else {
        console.log(chalk.dim(' clean'));
      }
    }

    // Summary
    console.log(chalk.bold(`\n  Total reclaimable: ${chalk.green(formatSize(totalSize))}`));
    if (findings.length) {
      console.log(chalk.dim(`  Run ${chalk.white('devclean clean')} to free this space\n`));
    } else {
      console.log(chalk.dim('  Your system is clean!\n'));
    }
  });

// CLEAN command
program
  .command('clean')
  .description('Clean reclaimable disk space')
  .option('-p, --path <dir>', 'Directory to clean', process.env.HOME)
  .option('--node-modules', 'Clean only node_modules')
  .option('--docker', 'Clean only Docker artifacts')
  .option('--brew', 'Clean only Homebrew cache')
  .option('--pip', 'Clean only pip cache')
  .option('--cargo', 'Clean only Cargo target dirs')
  .option('--xcode', 'Clean only Xcode DerivedData')
  .option('--caches', 'Clean only package manager caches (npm/yarn)')
  .option('--older-than <days>', 'Only clean items older than N days')
  .option('--dry-run', 'Show what would be deleted without deleting')
  .action((opts) => {
    const scanPath = path.resolve(opts.path);
    const specific = opts.nodeModules || opts.docker || opts.brew || opts.pip || opts.cargo || opts.xcode || opts.caches;
    const cleanAll = !specific;
    const minAge = opts.olderThan ? parseInt(opts.olderThan, 10) : 0;
    const dryRun = opts.dryRun;

    console.log(chalk.bold(`\n  devclean — ${dryRun ? 'dry run' : 'cleaning'}${minAge ? ` (older than ${minAge} days)` : ''}\n`));

    let totalFreed = 0;
    let itemsCleaned = 0;

    // node_modules
    if (cleanAll || opts.nodeModules) {
      const dirs = scanNodeModules(scanPath);
      dirs.forEach(dir => {
        const age = getAgeDays(dir);
        if (minAge && age < minAge) return;
        const size = getDirSize(dir);
        if (dryRun) {
          console.log(chalk.dim(`  [dry-run] Would delete ${formatSize(size)}  ${dir}`));
        } else {
          process.stdout.write(chalk.dim(`  Deleting ${dir}...`));
          if (rmDir(dir)) {
            console.log(chalk.green(` freed ${formatSize(size)}`));
            totalFreed += size;
            itemsCleaned++;
          } else {
            console.log(chalk.red(' failed'));
          }
        }
      });
    }

    // Cargo targets
    if (cleanAll || opts.cargo) {
      const dirs = scanCargoTargets(scanPath);
      dirs.forEach(dir => {
        const age = getAgeDays(dir);
        if (minAge && age < minAge) return;
        const size = getDirSize(dir);
        if (dryRun) {
          console.log(chalk.dim(`  [dry-run] Would delete ${formatSize(size)}  ${dir}`));
        } else {
          process.stdout.write(chalk.dim(`  Deleting ${dir}...`));
          if (rmDir(dir)) {
            console.log(chalk.green(` freed ${formatSize(size)}`));
            totalFreed += size;
            itemsCleaned++;
          } else {
            console.log(chalk.red(' failed'));
          }
        }
      });
    }

    // npm/yarn cache
    if (cleanAll || opts.caches) {
      try {
        if (dryRun) {
          console.log(chalk.dim('  [dry-run] Would clean npm cache'));
        } else {
          execSync('npm cache clean --force 2>/dev/null', { timeout: 30000 });
          console.log(chalk.green('  Cleaned npm cache'));
          itemsCleaned++;
        }
      } catch {}
    }

    // Docker
    if (cleanAll || opts.docker) {
      try {
        if (dryRun) {
          console.log(chalk.dim('  [dry-run] Would run docker system prune'));
        } else {
          const out = execSync('docker system prune -f 2>/dev/null', { encoding: 'utf8', timeout: 60000 });
          const match = out.match(/Total reclaimed space:\s+(.+)/);
          console.log(chalk.green(`  Docker pruned${match ? ': ' + match[1] : ''}`));
          itemsCleaned++;
        }
      } catch {}
    }

    // Homebrew
    if (cleanAll || opts.brew) {
      try {
        if (dryRun) {
          console.log(chalk.dim('  [dry-run] Would clean Homebrew cache'));
        } else {
          execSync('brew cleanup --prune=all 2>/dev/null', { timeout: 60000 });
          console.log(chalk.green('  Cleaned Homebrew cache'));
          itemsCleaned++;
        }
      } catch {}
    }

    // pip
    if (cleanAll || opts.pip) {
      try {
        if (dryRun) {
          console.log(chalk.dim('  [dry-run] Would clean pip cache'));
        } else {
          execSync('pip cache purge 2>/dev/null', { timeout: 15000 });
          console.log(chalk.green('  Cleaned pip cache'));
          itemsCleaned++;
        }
      } catch {}
    }

    // Xcode
    if (cleanAll || opts.xcode) {
      const derived = path.join(process.env.HOME, 'Library/Developer/Xcode/DerivedData');
      if (fs.existsSync(derived)) {
        const size = getDirSize(derived);
        if (minAge) {
          const age = getAgeDays(derived);
          if (age < minAge) return;
        }
        if (dryRun) {
          console.log(chalk.dim(`  [dry-run] Would delete ${formatSize(size)}  ${derived}`));
        } else {
          process.stdout.write(chalk.dim(`  Deleting Xcode DerivedData...`));
          if (rmDir(derived)) {
            console.log(chalk.green(` freed ${formatSize(size)}`));
            totalFreed += size;
            itemsCleaned++;
          } else {
            console.log(chalk.red(' failed'));
          }
        }
      }
    }

    // Summary
    if (dryRun) {
      console.log(chalk.bold('\n  Dry run complete. No files were deleted.\n'));
    } else {
      console.log(chalk.bold(`\n  Done! Cleaned ${itemsCleaned} item(s), freed ${chalk.green(formatSize(totalFreed))}\n`));
    }
  });

program.parse(process.argv);
