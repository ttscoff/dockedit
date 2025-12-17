# Required GitHub Secrets

To enable the GitHub Actions workflow for releasing and publishing to RubyGems, you need to add the following secret to your GitHub repository:

## RUBYGEMS_API_KEY

This is your RubyGems API key for publishing gems.

### How to get your RubyGems API key:

1. Go to https://rubygems.org/settings/edit
2. Scroll down to "API Key" section
3. Click "Show API Key" (or create one if you don't have one)
4. Copy the API key

### How to add the secret to GitHub:

1. Go to your repository on GitHub: https://github.com/ttscoff/dockedit
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `RUBYGEMS_API_KEY`
5. Value: Paste your RubyGems API key
6. Click **Add secret**

## GITHUB_TOKEN

The `GITHUB_TOKEN` is automatically provided by GitHub Actions and doesn't need to be manually added. It's used for creating releases.

## Workflow Summary

When you push a tag (e.g., `v1.0.0`), the workflow will:
1. Build the gem
2. Create a GitHub release with the .gem file attached
3. Publish the gem to RubyGems.org

To create a release:
```bash
# Bump version (if needed)
rake version:bump[patch]  # or [minor] or [major]

# Commit and tag
git add lib/dockedit/version.rb
git commit -m "Bump version to X.Y.Z"
git tag -a vX.Y.Z -m "Version X.Y.Z"
git push && git push --tags
```

