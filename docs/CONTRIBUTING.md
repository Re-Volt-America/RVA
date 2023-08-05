Contribution Guide
===

## Development Team
* [José Benavente](https://github.com/BGMP) - jose@bgm.cl

## Features
This application's aim is to provide Re-Volt America's administrators with the ability to parse session files (.csv)
on-site and render results tables. All users should be able to visualise session results on-site too.

1. The site allows the user to create new Seasons and Rankings for Re-Volt America.
2. The site allows the user to create new Car and Track models and relating them to specific seasons.
3. The site has the capacity of processing an RVGL Session Log (.csv file) uploaded on-site, and rendering its final
table representation to the user.

## Coding Standards

### Code Style
This project's code style must follow the standard recommendations for Ruby programming:

1. All the codebase and documentation must be written in English.
2. In general, the entire project follows Ruby's naming conventions and other useful guides which you may find on the
following site: [RubyStyle website](https://rubystyle.guide/).

### Analyse the Code with RuboCop
This project utilises the [RuboCop](https://docs.rubocop.org/rubocop/1.55/index.html) gem to apply an standard format to
the codebase. All exceptions and directives are listed in the `.rubocop.yml` file.

The RuboCop gem is installed alongside the rest of the project's gems, therefore once you run `bundle install` to
download and install dependencies you will pull RuboCop too and get it ready for use. Once you finish installing,
you may inspect and auto-correct the code using the following commands, respectively:
```bash
rubocop                          # Inspect
rubocop --autocorrect            # Autocorrect
```

### Code Editor Configuration
Before writing your code, verify that the following general configurations in your editor are set to the following:

* Linebreak (EOL - End of Line) CRLF.
* UTF-8 encoding.
* No tabs -- Use 2 spaces.

## Code Development

### System Architecture & Design Patterns
- This project being a Rails application follows the MVC (Model View Controller) pattern.

## Repository Interaction
### Branches
1. The `master` branch is where the main, stable application lives. The code sent to this branch is expected to at least
work stably.
2. The `dev` branch is where all the unstable and experimental code is uploaded to.

### How to Contribute
1. Create an issue and a new branch originating from the master branch.
    - Describe and list all the tasks which will be developed.
2. Develop the code in the newly created branch.
    - Make the commits to the issue branch.
    - Mention the issue number in the commit message.
3. Sending your code to the repository opening a pull request.
    - Describe what will be implemented into the master branch.
    - Describe the acceptance criteria and review of the code and changes.
    - Label the PR with all the related labels.
    - Mention the issue in the PR description.
    - If the PR contains all the changes which complete the tasks for the issue being addressed, add 'Closes Issue #123'.
4. Await approval from one of the project maintainers.

### Version Control
Do **NOT** include any of the following files in the repository (don't commit them):

- `config/*`
- `vendor/*`

You may find a full list of files which are already configured to be ignored by git via the `.gitignore` file. Check it
out to get a better picture of which files should not be version controlled.

Do **NOT** add these files to production environments:

- `docs/`
- `docker/*`
- `composer.lock`
- `README.md`
- `.gitignore`
- `.git/*`