## Installation

- Copy or clone to any subdirectory
- Import `include/Fastfile.include` from `fastlane/Fastfile`
- Copy `templates/fastlane/*` to `fastlane`
- Copy everything in `templates` except `.env*` to local `templates`

### Environment

- Copy `templates/.env*` to root
- Rename `.env.template.secret*` to `.env.secret*`
- Edit files accordingly
- Make sure to add `.env.secret*` to `.gitignore`

## Usage

### Input

- Environment: `.env*` in root
- App description: `templates/DESCRIPTION.md`
- App changelog: `templates/CHANGELOG.md`
- App beta feedback e-mail: `templates/beta-feedback.txt`

### Output

- Intermediate products: `build/(ios|mac)/(dev|beta)`
- IPA: `dist/(ios|mac)/(dev|beta)`

## Extra

For AppCenter support (`dev-*` scripts), append this to `Gemfile`:

```
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```
