# Validation record

Prepared and checked on 2026-10-23.

Verified locally:

- All 31 selected original files still match their recorded source hashes after packaging; no original files were changed by this task.
- Core installer preview made no directories or files in an empty fixture.
- Core installer copied 21 files and every copied file matched the bundle bytes.
- Optional Playwright installation copied 30 total files and included the license.
- Repeating an installation refused conflicts. A conflict in the later agent group was detected before any copy; existing fixture contents were preserved.
- Installer did not install config.toml or AGENTS.md.
- Standard-library verifier passed manifest hashes, TOML syntax, required skill frontmatter fields, all eight role names, local Markdown links, and a heuristic credential/personal-path scan.
- Final ZIP was extracted into an isolated fixture and verified again. A deliberate README modification in that fixture was detected as a hash mismatch.
- After GitHub preparation, the verifier was updated to ignore a clone's root `.git` metadata. A separate fixture with representative `.git` files passed; a deliberate toolkit README change still failed. README sharing instructions now refer to the private repository.

Verification commands used the bundled Python 3 runtime and PowerShell in the task workspace. Intermediate build scripts and fixtures remain outside this shareable bundle. `Verify-Toolkit.py` is included for recipients to repeat the structural checks with Python 3.11+.

Not verified:

- Fresh Codex skill discovery or custom-role loading on another installation.
- A complete engineering-pipeline run or behavioral quality of its existing prompts.
- Optional Playwright downloads, browser launching, Bash compatibility or browser automation.
- Every desktop setting, account connection or operating-system configuration.

The manifest detects accidental changes; it is not a digital signature. The heuristic secret scan covers common credential formats and personal Windows paths, not every possible secret. Public reuse terms for the personal content remain an owner decision.
