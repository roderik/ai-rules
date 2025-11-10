# Conventional Commits Reference

## Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

## Types

- **feat**: New feature for the user
- **fix**: Bug fix for the user
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (white-space, formatting, missing semi-colons)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes affecting the build system or external dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files
- **revert**: Reverts a previous commit

## Scope

Optional contextual information. Examples:
- `feat(auth): add OAuth login`
- `fix(api): handle null response`
- `docs(readme): update installation steps`

## Description

- Use imperative, present tense: "change" not "changed" nor "changes"
- Don't capitalize first letter
- No period (.) at the end
- Keep under 72 characters

## Body

- Use imperative, present tense
- Include motivation for the change and contrast with previous behavior
- Wrap at 72 characters

## Footer

- Reference issues: `Fixes #123` or `Closes #456`
- Breaking changes: `BREAKING CHANGE: description`

## Examples

### Simple feature

```
feat(user): add profile picture upload
```

### Bug fix with scope

```
fix(api): prevent race condition in data fetch
```

### Breaking change

```
feat(api): change authentication flow

BREAKING CHANGE: OAuth tokens now expire after 1 hour instead of 24 hours.
Users must refresh tokens more frequently.
```

### With issue reference

```
fix(payment): handle failed stripe webhooks

Fixes #789
```

### Using HEREDOC for multi-line messages

```bash
git commit -m "$(cat <<'EOF'
feat(auth): implement OAuth2 flow

Add OAuth2 authentication with Google and GitHub providers.
Includes token refresh mechanism and secure storage.
EOF
)"
```
