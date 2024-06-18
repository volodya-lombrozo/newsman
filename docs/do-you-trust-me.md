# Do you trust me?

We have lived in a period of AI shift for the past few years.
AI is everywhere: searching, learning, text processing, code review, code writing assistance, and many other systems have arisen in recent years. 
It seems everybody is trying to apply AI where it's possible and impossible. 
I'm not an exception. 
Under the influence of this wave, I decided to try to create something on my own that would help me in everyday life. 
So here I will tell you my own story of writing an application with the use of AI, along with some thoughts about it, of course, which are rather contradictory.

## Where to apply?

I'm a developer in a distributed team, and like any other member, I sometimes need to explain what I did in the last week to my colleagues. 
Our team actually prefers text-based reports instead of face-to-face communication for many reasons. 
I know that for some it might look contradictory, but all the benefits of this approach have been mentioned many times already, and it’s just how we prefer to do it.
So, after a while, we came up with a particular document format and structure for our weekly reports. 
It is called [SIMBA](https://www.yegor256.com/2021/09/09/simba.html). 
This format is extremely simple:


```md
From: Team Coordinator
To: Big Boss
CC: Programmer #1, Programmer #2, Friend #1, etc.
Subject: WEEK13 Dataset, Requirements, XYZ 

Hi all,

Last week achievements:
- Added 100 new files to the Dataset [100%]
- Fixed the deployment of XYZ [50%]
- Refined the requirements [80%]
Next week plans:
- To publish ABC package draft
- To review first draft of the report
Risks:
- The server is weak, we may fail the delivery
  of the dataset, report milestone will be missed.

Bye.
```

As you can see, there are three distinguishing parts that should be summarized based on the results you achieved during the previous week.
This report is usually short and very simple. 
However, if you need to create this report every week, it might become tedious. 
Extremely tedious. 
Sometimes it's just hard to remember what you were doing at the beginning of the previous week.
Moreover, people with lots of projects suffer because they switch their context almost every day and easily forget things. 
Things that should be noted. 
So why don't we generate this report automatically?
Since we use GitHub for our projects, we have access to developer activity. 
And since we have access to the activity, we can utilize that information to build a report.

However, all this activity is usually poorly formatted: we don't have any rigid conventions for commits, issues, and pull request formatting. 
Moreover, if this formatting existed, it might differ between projects. 
And, to be honest, we don't want to invent these rigid rules, restrictions, and style guidelines. 
It's boring. 
We have AI that will extract and format all these parts of the report for us.

## Can you generate it for me?

I don't have much time to write a complex script or an application to perform this task. 
I just don't have time for it.
So let's take the first naive attempt to generate a report in the most straightforward way.

At first, we will concentrate on the 'Last Week Achievements' part only and delegate as much work as possible to AI.
In most cases, we can measure the work done by a developer by finished Pull Requests - the real code provided. 

So, long story short, I got a list of closed Pull Requests for the previous week by using the GitHub API, converted their titles and bodies to a simple string, joined by a '____' delimiter, and sent them to AI altogether with the following prompt.

Context:
```txt
You are a developer tasked with composing a concise report detailing your activities and progress for the previous week, intended for submission to your supervisor.
```
Prompt (don't read it entirely, it's boring):

```txt
Please compile a summary of the work completed in the following Pull Requests (PRs). 
Each PR should be summarized in a single sentence, focusing more on the PR title and less on implementation details.
Group the sentences by repositories, each identified by its name mentioned in the 'repository:[name]' attribute of the PR.
The grouping is important an should be precise. 
Ensure that each sentence includes the corresponding issue number as an integer value.
If a PR doesn't mention an issue number, just print [#chore]. 
Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work.
Please strictly adhere to the example template provided.
Example of a report: #{example}. List of Pull Requests: [#{prs}]"}
```

That is all. I didn't do any grouping programmatically, I didn't prepare data, I didn't even write the prompt myself.
I asked AI to generate it for me, of course.
Am I a prompt engineer?
And... I got great results despite using only the cheapest GPT-3.5.

```txt
Last week achievements.
  jeo-maven-plugin:
  - Implemented disassembling of remaining instructions [#509]
  - Identified the problem with switch statement disassembling [#488]
  - Updated Qulice version to 0.22.2 [#chore]
  - Handled all bytecode instructions and updated plugin version [#488]
  - Improved performance of integration tests by optimizing cache usage [#499]
  - Made label identifier accessible in XmlLabel class [#497]

  opeo-maven-plugin:
  - Updated Jeo version to 0.3.4 [#190]
  - Enabled all integration tests and improved label handling [#189]
```

Of course, the AI confused grouping by repositories, mixed pull requests between several projects, and lost several items from the report.
Most importantly, it correctly combined different parts of each PR (title and body) into concise, short sentences, and the result looks human-readable—just what we need. 
So, I checked the final report, added some missing points, fixed several sentences to restore their meaning, and sent the report.

Further in this article, I won't include all the results because they would make the text excessively long and potentially confusing. 
However, if you are really interested, 
I have published the complete [history](https://volodya-lombrozo.github.io/newsman/) of the results I obtained along the way.

## Next week. Let's talk about the future?

The next week I did the same, but with Issues. 
Since we don't have any special boards, backlog, scrum and similar, we use only plain issues. 
Yes, most of them won't be solved during the next week.
So at the beggining I used all Issues for the last month, formatted them with AI tool and then manually remove the Items which I won't solve.
By doing this I added some sort of fitering.
Which reduced costs on API.

So the prompt was like the following:
```txt
Please compile a summary of the plans for the next week using the following GitHub Issues descriptions. 
Each issue should be summarized in a single sentence, focusing more on the issue title and less on implementation details. 
Group the sentences by repositories, each identified by its name mentioned in the 'repository:[name]' attribute of the issue.
Pay attention, that you din't loose any issue. 
The grouping is important an should be precise.
Ensure that each sentence includes the corresponding issue number as an integer value.
If an issue doesn't mention an issue number, just print [#chore]. 
Combine all the information from each Issue into a concise and fluent sentences, as if you were a developer reporting on your work.
Please strictly adhere to the example template provided: #{example_plans}. List of GitHub issues to aggregate: [#{issues}].
```

Afain, I didn't wrote this prompt myself. Ifter I got exactly the same problem with the structure, formatting and wrong groupping.
Ok, at least we have something.
I checked issue titles, fixed some of them, then removed all the issues which I won't solve during this week.
Later, of course, I added labels for the issues which I will solve soon. So the label name is "soon". 
By doing this I solved the problem with issues which I won't and will solve.
Moreover, I started labeling those issues which I will solve soon.

## What about meaning extraction from the text?

I mean our last point in the text. Let's imagine, that in the PR description you added the following text:
```
```

It was a problem, because not all changes in the code carried any risks.
So GPT tried to "invent" new risks where they were absent, sometimes it printed just a PR description without finding any problems. 
So it was problematic and still remains. 
Most probably, the key problem was with my prompt:
```txt
Please compile a summary of the risks identified in some repositories. 
If you can't find anything, just leave answer empty.
Add some entries to a report only if you are sure it's a risk.
Developers usually mention some risks in pull request descriptions. 
They either mention 'risk' or 'issue'. 
I will give you a list of pull requests. 
Each risk should be summarized in a single sentence.
Ensure that each sentence includes the corresponding issue number or PR number as an integer value. 
If a PR or an issue doesn't mention an issue number, just print [#chore].
Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work.
Please strictly adhere to the example template provided. 
Example of a report: #{example_risks}. List of Pull Requests: ```#{all}```.]
```

In order to avoid this problem, I had to mention risks directly in a PR descriptions:
Risk with the word "Risk" https://github.com/objectionary/opeo-maven-plugin/pull/259

As you can see, it's what I didn't want to do at all - structure my text. 


## Let's improve it?

Despite implementing all these parts, I still needed to do much of the work - structure, format, check that each generated sentence has valid meaning, or has meaning at all.
Since I did 3 separate requests, all the responses were differently formatted, as you can guess. Something like the following:

```txt
Example?
```

But how can I fix this problem? Of course, GPT:

```
I have a weekly report with different parts that use various formatting styles.
Please format the entire report into a single cohesive format while preserving the original text without any changes.
Ensure that the formatting is consistent throughout the document.

Here is the report:

#{report}
```

And it works like a charm. Hoevewer I all the time have different formating style. 
Which is OK in my case, though looks a bit strange, sine each week I have differently formatted reports.
Maybe I need to provide an example? 

## Let's spend more moneny?

I didn't mentioned it, but for all the previous requirests I made with an old, but cheap, model `gpt-3.5-turbo`.
So, to be honest, I decided to spend more money to check the newest `gpt-4o` model.
And here is the difference:
```
```

Do you see it? I don't. I used exactly the same Pull Requests and Issues. And haven't found the difference yet. 
Only the price. 
Of course, I can build more pipelines, to fix grammar errors, format the text, make it more "natural" and so on.
And it will probably give some gain. But, to be honest, I don't want spend much money for these task, which might be 
solved much easely and for free programmatically.

## How long?

Current situation is following. I open auto-generated report, read them, format small parts, fix problems with meanings. 
Then I open list of issues and pull requests and validate the report.
Wait, wait... What I'm doing? I wanted not to do this type of work at all. 
So I spend significant time to develop this scripts, configure them and did some chore around it.
But I'm still have to do a lot of work. Which I inidially wanted to avoid at all.
Dissapointment.
Of course, I have to do less, but still.

## High view?

Of course, I'm a bit sceptical and things are not so bad. Let's take a look at wat we got. 
We started the development very fast. Very.
I didn't need to do any formating, data preparation for AI analysis.
It understood what was necessary as is.
Just a simple prompt with data and you get a raw, full of mistakes results.
But you get a result! In a few hours of work. 

Later, when you need to make your system more "precise", you just add more code to it.
You split requests. Add meta-information. Build chain of requests and so on. You continue develop
the system.

If you continue to make the system more "precise", you suddenly, realize that you don't need AI at some point at all.
And it's fine to remove it, I belive.

So, I didn't clearly realized how I can express my feelings about this developemnt process, but it can be illustrated 
as follows:

```picture```

```txt
Could you draw a hand-drawn sketch of a plot? 
On the Y-axis, put 'Precision', and on the X-axis, put 'Development effort'. 
It should show a close to linear dependency. 
It should look like a cartoon-like image, similar to a hand-drawn sketch. 
Don’t put numbers on it.
Be precise in labels' grammar, and don’t make mistakes in word spelling.
```

```txt
Could you create a cartoon-style hand-drawn sketch of a plot? The Y-axis should be labeled ‘Trust’ and the X-axis should be labeled 'Development Effort.' The plot should depict a nearly linear relationship between the two variables. Please ensure that the labels are grammatically correct and spelled accurately. Do not include any numerical values on the plot.
```

Functionality of the application (number of implemented use cases remains constant.)
As you can see, we get the required functionality very fast, but with low precision. 
Later, when we start focusing on the precision, we increase developement time and reduce or specify the use of AI.
So, we have two extreems - the first one - fully AI system with a low precision and fully programmed system with high precision.
The distance bewtween them is a developement process.

So maybe in the future we will create systems exactly this way. Since for some systems we can tolerate low precision, for some others
like medicine, we cannot.


## All this sound around AI?

This days we experiense a large growth of AI tools. Most of them we are already adapted in our work process.
ChatGPT, ..., ..., which can generate some code which you don't remember (which you don't want to learn), for
example I use it for small bash scripts, or for generation XSL transformations.

Also modern tools do unit test generation wery well. And of course documentation generation.
For example, you can generate README files based on the code in your repository, you can generate
well-understandable and well-written code comments, thank you, CoPilot. 

So, there is definetly the progress in many places. However I should admit that not all things are perfect.

Obviousely, we still can't give precise tasks to AI, and I'm not sure if we will ever can. 
I don't pay attention to the answers generated by AI. 
For example, PR reviews - I just don't read them - I write much enough code, they usually suggest many things.
And where there is nothing to say, they soggest at least something. 
It seems they should say somthing all the time. It's annoying.
The same with some recommendation systems. 
I just ignore them. Maybe and most probably it will change in the future, but for now I'm still rather sceptical about
them.
I don't trust them and required all the time check their results since it's still many errors. 
Hope it will changes in the future. 


One more thing which I noticed is how I changed the content of my Issues and Pull Requests.
I started adding more human-readable messages and titles even for small tasks.
I started adding more labels to tasks. 
In much cases I don't use them, but here they are useful since they are used by another machine and finally you see
this text in a report.
I started identify risks and possible issues on my way and write their influense right into an issue description.
So, it seems, AI and this reports make me (my repository) better.


And yes. This post was written with help of AI as well. I fixed many grammar and spelling mistakes.
Structured this text and even drow an image in this article. 
So, it seems I trust them.


We will read more, a write less? More refactoring?
