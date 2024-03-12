# Newsman 

Newsman is a simple script that collects information about a developer's weekly activity on GitHub and creates a human-readable summary of the work done. To create the summary, Newsman asks ChatGPT to handle all the information about a developer's activity, including their pull requests and created issues.

## How to Use

To use newsman, you need to perfom several actions. 

### Retrieve `GITHUB_TOKEN`

First of all, you need to [retrieve your GitHub token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

### Retrieve `OPENAI_TOKEN`

Then, you need to [set up your OpenAI key](https://platform.openai.com/docs/quickstart?context=curl).

## Run the script

To run the newsman script you should pass `GITHUB_TOKEN` and `OPENAI_TOKEN` environment variables together with `name`, `username` and `repository` parameters.
If you have some problems you can use `--help` option to get more info about newsman usage:
```shell
Usage: newsman [options]
    -n, --name NAME                  Reporter name. Human readable name that will be used in a report
    -u, --username USERNAME          GitHub username. For example, 'volodya-lombrozo'
    -r, --repository REPOSITORIES    Specify which repositories to include in a report. You can specify several repositories using a comma separator, for example: '-r objectionary/jeo-maven-plugin,objectionary/opeo-maven-plugin'
    -p, --position                   Reporter position in a company. Default value is a 'Software Developer'.
```

### Example

You can download this repository and run the newsman script directly using the following command:
```shell
./bin/newsman --name "Vladimir Zakharov" --username "volodya-lombrozo" --repository objectionary/jeo-maven-plugin,objectionary/opeo-maven-plugin
```

Don't forget to set your own values for `name`, `username` and `repository` parameters.

## How to build a gem from sources

To create a newsman gem from sources first of all you need to build it:
```shell
gem build newsman.gemspec
```
Then, in the folder you might find a newly created gem file, e.g `newsman-0.1.0.gem`.
To use it in any place of your system you need to install it:
```shell
gem install newsman-0.1.0.gem
```
To check that everythis is fine, just run the following command:
```
newsman --help
```
Annd you should see a welcome message from newsman.
