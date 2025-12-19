# Development Best Practices

## Command Usage Philosophy

This project follows a **clarity over cleverness** approach:

### ✅ Preferred Patterns

1. **Use Makefile for common workflows**
   ```bash
   make cache          # Clear cache
   make shell          # Open shell
   make permissions    # Fix permissions
   ```

2. **Use bin/ scripts for Magento/Composer commands**
   ```bash
   ./bin/magento cache:flush
   ./bin/composer require vendor/package
   ```

3. **Use docker compose directly for container operations**
   ```bash
   docker compose ps
   docker compose logs -f app
   docker compose exec app bash
   ```

### ❌ Anti-Patterns to Avoid

1. **Don't create wrapper scripts for single commands**
   ```bash
   # ❌ Bad: Creating bin/cache-flush that just calls bin/magento cache:flush
   # ✅ Good: Use make cache or ./bin/magento cache:flush directly
   ```

2. **Don't add unnecessary abstraction layers**
   ```bash
   # ❌ Bad: make → bin/script → bin/cli → docker
   # ✅ Good: make → docker (or make → bin/magento → docker)
   ```

3. **Don't use cryptic names**
   ```bash
   # ❌ Bad: bin/clinotty
   # ✅ Good: bin/exec-no-tty (or just use docker compose exec -T)
   ```

## When to Add New Scripts

Only add a new script in `bin/` if it meets **at least one** of these criteria:

1. **Complex Logic**: The script contains conditional logic, loops, or multiple steps
   - ✅ Example: `bin/setup` (creates network, copies files, sets permissions)
   - ❌ Example: `bin/cache-flush` (just calls another script)

2. **Environment Handling**: The script needs to parse or manipulate environment variables
   - ✅ Example: `bin/start` (checks for .env, runs setup if missing)
   - ❌ Example: `bin/restart` (just calls docker compose restart)

3. **User Interaction**: The script prompts for user input
   - ✅ Example: `bin/setup-magento` (interactive installation wizard)
   - ❌ Example: `bin/logs` (just displays logs)

4. **Cross-Platform Compatibility**: The script handles OS-specific differences
   - ✅ Example: `bin/setup-ssl` (different SSL cert generation per OS)
   - ❌ Example: `bin/status` (docker compose works everywhere)

## Makefile Guidelines

### Target Naming Conventions

- Use **verbs** for actions: `build`, `start`, `stop`, `clean`
- Use **nouns** for states: `status`, `version`
- Use **clear names** over short names: `clean-all` not `cleanall`
- Use **hyphens** for multi-word targets: `setup-magento` not `setup_magento`

### Target Organization

Group related targets in the `.PHONY` declaration:
```makefile
.PHONY: help init setup-magento uninstall-magento \
        up down restart build logs status clean clean-all \
        shell permissions \
        cache reindex compile upgrade deploy
```

### Help Text

- Use emojis for visual grouping (🚀 📦 🎯 📚 🗄️ 🧪)
- Align descriptions for readability
- Group related commands together
- Keep descriptions concise (under 50 chars)

## Directory Structure Philosophy

```
magento-frankenphp-template/
├── bin/                    # Executable scripts (complex logic only)
├── docker/                 # Docker configurations
│   ├── conf/              # Configuration templates
│   └── images/            # Custom Dockerfiles
├── docs/                   # Documentation
├── env/                    # Environment file templates
├── src/                    # Magento source code
├── Makefile               # Common workflows
└── README.md              # Quick start guide
```

### File Placement Rules

- **bin/**: Only scripts with meaningful logic
- **Makefile**: Common workflows and aliases
- **docs/**: Detailed documentation
- **README.md**: Quick start and overview only

## Code Review Checklist

Before adding new scripts or Makefile targets, ask:

- [ ] Does this add real value or just wrap an existing command?
- [ ] Can this be done with a Makefile target instead?
- [ ] Is the name clear and self-documenting?
- [ ] Does it follow existing naming conventions?
- [ ] Is it documented in the help text?
- [ ] Does it handle errors gracefully?
- [ ] Is it executable (`chmod +x`)?
- [ ] Does it have a proper shebang (`#!/usr/bin/env bash`)?

## Examples of Good vs Bad Additions

### ❌ Bad: Unnecessary Wrapper
```bash
#!/usr/bin/env bash
# bin/clear-cache
./bin/magento cache:flush
```
**Why bad**: Adds no value, just wraps another command

**Better**: Use `make cache` or `./bin/magento cache:flush`

### ✅ Good: Meaningful Logic
```bash
#!/usr/bin/env bash
# bin/fix-permissions
set -e

if [ -z "$1" ]; then
    # Fix ownership
    ./bin/rootnotty chown -R www-data:www-data /var/www/html
    # Fix permissions
    ./bin/clinotty find var vendor pub/static pub/media app/etc \
        \( -type f -or -type d \) -exec chmod u+w {} + 2>/dev/null || true
else
    # Fix specific path
    ./bin/rootnotty chown -R www-data:www-data /var/www/html/"$1"
    ./bin/clinotty find "$1" \( -type f -or -type d \) -exec chmod u+w {} +
fi
```
**Why good**: Handles multiple scenarios, combines related operations, provides flexibility

## Maintenance Guidelines

### Regular Cleanup

Every 6 months, review:
1. Are all scripts in `bin/` still needed?
2. Are there new wrapper scripts that should be removed?
3. Is the Makefile help text up to date?
4. Are there unused Makefile targets?

### Deprecation Process

When removing a script:
1. Update `CLEANUP_SUMMARY.md` with migration path
2. Update Makefile if it references the script
3. Update README.md examples
4. Update docs/ if needed
5. Commit with clear message explaining the change

## Questions to Ask

When someone proposes a new script or command:

1. **"Can this be a Makefile target instead?"**
   - If yes → Use Makefile
   - If no → Continue

2. **"Does this wrap a single command?"**
   - If yes → Don't add it
   - If no → Continue

3. **"Does this contain meaningful logic?"**
   - If yes → Add it to bin/
   - If no → Don't add it

4. **"Will developers use this frequently?"**
   - If yes → Consider adding
   - If no → Document in README instead

## Summary

**The Golden Rule**: Every file should earn its place in the repository.

If a script doesn't add meaningful value beyond what's already available, it's clutter. Keep the codebase lean, clear, and maintainable.
