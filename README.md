# Newsman 


[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.txt)
[![Gem Version](https://img.shields.io/gem/v/newsman.svg)](https://rubygems.org/gems/newsman)

Newsman is a simple script that collects information about a developer's weekly activity on GitHub and creates a human-readable summary of the work done. To create the summary, Newsman asks ChatGPT to handle all the information about a developer's activity, including their pull requests and created issues.

## How it Works

`newsman` sends multiple requests to GitHub to retrieve the following data:

1. **Recently Closed Pull Requests by the Author**  
   The tool fetches pull requests that were closed recently and were created by the specified author.  
   Example query:  

```
is:pr author:volodya-lombrozo created:>=2024-11-29 repo:objectionary/jeo-maven-plugin repo:objectionary/opeo-maven-plugin
```

2. **Open Issues Assigned to the Author with the `soon` Label**  
The tool retrieves issues that:  
- Were opened in the last year  
- Are currently open  
- Are assigned to the specified author  
- Have the label `soon`  

Example query:  
```
is:issue is:open assignee:volodya-lombrozo created:>=2023-12-06 repo:objectionary/jeo-maven-plugin repo:objectionary/opeo-maven-plugin label:soon
```

Once the data is retrieved, the script analyzes it using the model specified with the `--model` option.

## Install

To install [newsman](https://rubygems.org/gems/newsman) from RubyGems.org use the following command:
```shell
gem install newsman
```
The newest version of newsman will be installed on your system.

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
    -p, --position POSITION          Reporter position in a company. Default value is a 'Software Developer'.
    -o, --output OUTPUT              Output type. Newsman prints a report to a stdout by default. You can choose another options like '-o html', '-o txt' or even '-o html'
    -t, --title TITLE                Project Title. Empty by default
    -m, --model MODEL                AI model to use. gpt-3.5-turbo by default
```

### Example
To run `newsman` use the following command:
```shell
newsman --name "Vladimir Lombrozo" --username "volodya-lombrozo" --repository objectionary/jeo-maven-plugin,objectionary/opeo-maven-plugin
```

Don't forget to set your own values for `name`, `username` and `repository` parameters.
Also you can download this repository and run the newsman script directly using the following command:
```shell
./bin/newsman --name "Vladimir Lombrozo" --username "volodya-lombrozo" --repository objectionary/jeo-maven-plugin,objectionary/opeo-maven-plugin
```

Actually, this command is also useful during development process.

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
And you should see a welcome message from newsman.

## Examples

You can find examples of generated reports [here](https://volodya-lombrozo.github.io/newsman/)
