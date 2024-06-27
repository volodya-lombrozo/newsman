# Do you trust them?

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

## What about the future?

For the 'Next Week Plans' section, I followed a similar approach since there is nothing special. 
The only difference is the source of data.
In our team, we don't have any special software to track tasks like boards, backlog, and similar. 
We use plain GitHub issues, as many other open-source projects do. 
Hence, I focused on issues opened by a developer in the last month, as these are the ones we will likely address sooner. 
Of course, most of them won't be resolved during the next week, so the developer will need to remove the ones they won't solve during the following week.

In other words, I get a list of issues created by a developer for the last month, join them using '____' delimeter and send them with the following 
prompt.

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

And I got more or less appropriate results in a human-readable format that are almost ready to be presented to the team.

```txt
Next week plans:
jeo-maven-plugin:
- Refactor Annotations Implementation in BytecodeAnnotation.java for simplification and readability [#532]
- Investigate and fix the issue of automatic frame computation in CustomClassWriter to prevent test failures [#528]
- Enable 'spring' Integration Test in pom.xml by adding support for various Java features [#488]
```

Here, I also encountered the same problems with the structure, formatting, and incorrect grouping as in the 'Last week achievements' section.
So, I checked the issue titles, fixed and formatted some of them, then removed all the issues that I won't solve during this week and sent the report.

P.S.
After several weeks, removing plans that I didn't want to address soon became extremely tedious. 
To simplify this task, I added a label for the issues I plan to solve in the near future. 
The label name is 'soon.' 
Yes, I know, my imagination is quite vivid. 
Anyway, I no longer need to spend much time on this section. 
Now, my script, along with AI, analyzes future plans quite well.

## Risks 

Now let's move to the most exciting part: risk identification, specifically our last 'Risks' section in the report.
Typically, developers mention some risks and possible problems in PR descriptions. 
Actually, they can be mentioned anywhere, but let's start with something simple.

I generated the following prompt to identify risks from these descriptions:

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
Example of a report: #{example_risks}. List of Pull Requests: ```#{all}```.
```

Unfortunately, it didn't work as expected.
Not all code changes carried risks, so the AI often tried to invent new risks where there were none.
Sometimes it simply repeated the PR description without identifying any problems. 
Other times, it printed risks from the example provided instead of from the real data. 
It also frequently confused PR numbers when it found risks.
In other words, it was a mess.

Most likely, the key problem was with my prompt. 
I tried several modifications, but the results remained more or less the same.

So, I decided to give some clues to the AI. 
I started writing all PR descriptions as clearly as possible. 
And... surprise, surprise, it started working like a charm. 
For this PR description:

```txt
During the implementation of this issue, I identified some problems which might cause issues in the future:
Some of the decompiled object values look rather strange, especially the field default values - they have the '--' value.
We need to pay attention to the mapping of these values and fix the problem. 
For now, it doesn't create any issues, but it's better to deal with it somehow.
```

I got the following result:

```txt
Risks:
jeo-maven-plugin:
- In PR Update All Project Dependencies, there is a risk related to strange decompiled object values with -- default values that may need attention in the future [#199].
```

The more human-readable messages I leave, the easier it is for AI to analyze results.
(Who would've thought, right? 🤔)
As a result, I have become more disciplined in my pull requests.
I've now developed much better-styled, grammatically correct, and descriptive messages that are more understandable.
So, it’s a nice improvement for people who read my PRs, not just for AI processing.

However, I should admit that in some cases I went beyond that, and now I sometimes add additional markers like 'Risk 1: ...,' 'Risk 2: ...' in the text
(as I did [here](https://github.com/objectionary/opeo-maven-plugin/pull/259)) to get more precise answers from the AI. 
By doing this, the AI almost didn't make any mistakes. 
But do we really need the AI in this case at all? 
As you can see, it's exactly what I initially didn't want to do – structure my text and add meta information. 
How ironic.

## Let's improve it?

Even though we've implemented all these parts, 
I still had to handle much of the work, including structuring, formatting, and making sure each generated sentence actually made sense.
I'm not sure if we can fix the problem related to meaning verification. 
It's just easier to do it manually, at least for now. 
So, we're left with some structural and formatting problems. 
To illustrate, just take a look at the report we generated.


```txt
Last week achievements:
jeo-maven-plugin:
* Remove Mutable Methods [#352]

Next week plans:
opeo-maven-plugin:
- Fix 'staticize' optimization [#207]

Risks:
    jeo-maven-plugin:
       - The server is weak, we may fail the delivery of the dataset, report milestone will be missed [#557].
```

Since we made three separate requests, the responses predictably came back in different formats. 
We have at least three possible solutions to this problem. 
Can you guess the simplest one? 
That's right, let's throw even more AI at it. More and more AI!
Alright, let's not get carried away. 
For now, we can just add one more request.

```
I have a weekly report with different parts that use various formatting styles.
Please format the entire report into a single cohesive format while preserving the original text without any changes.
Ensure that the formatting is consistent throughout the document.

Here is the report:

#{report}
```

And it works. 

```txt
Last week achievements:
jeo-maven-plugin:
- Remove Mutable Methods [#352]

Next week plans:
opeo-maven-plugin:
- Fix 'staticize' optimization [#207]

Risks:
jeo-maven-plugin:
- The server is weak, we may fail the delivery of the dataset, report milestone will be missed [#557].
```

However, we have different formatting styles between reports now, which is okay in this case. 
Though it looks a bit strange since each week I have differently formatted reports.
Maybe it gives the impression of a real person.

The second improvement we can apply is to improve the AI model itself. 
I haven't mentioned this yet; all the previous requests I made were with an old but relatively cheap model, GPT-3.5-turbo. 
So, to be honest, I decided to spend more money to check out the newest GPT-4 model. 
And it works much better. 
It is subjective, of course, but my perception tells me that the results look better in most cases. 
Again, you can check the difference here.

The final improvement involved the format of the input data for the pull requests and issues I submitted to the AI.
Initially, I didn't spend much time preparing the data.
However, I later switched from unstructured text with delimiters to JSON, which seemed to help.
Although I don't have concrete proof, it appears that the AI makes fewer mistakes.

In summary, I can build more pipelines with chained requests, pay more money, format the input data, and so on.
And it will probably yield some gains.
But, to be honest, I don't want to spend much on these tasks anymore.
Moreover, I have a feeling that all these problems might be solved much more easily programmatically even without the use of AI.
So, the current solution is enough for me.

## Bird's-eye View

Let's agree; we completely changed the original task. 
We formatted the pull request and issue descriptions, 
added meta information like the 'soon' label and 'Risk' markers, 
and handled some parts programmatically. 
Moreover, we spent significant time developing these scripts, configuring data, and adjusting prompts, which we initially wanted to avoid altogether.
We still need to validate the report; we can't blindly trust it. 
And I wonder if, after all these changes, we still need an AI at all.

Did we fail in our attempt to build an AI-based application? 
I can't say that.
Things are not so dramatically bad.
Let's take a look at what we have.
We started the development very quickly. Very quickly.
Initially, we didn't do anything special in terms of formatting or data preparation for AI analysis.
Just a simple prompt with data, and we got raw, full-of-mistakes results.
But we got results! In a few minutes.

Later, when we needed to make our system more precise, we gradually added more code to it. 
We specified the solution, added meta-information, improved prompts, built a chain of requests, and so on. 
I bet if you continue to make the system more precise, you will suddenly realize that you don't need AI at some point. 
And it's fine to remove the AI usage in this case, I believe. 
So, I can illustrate my observations about this development process as follows:

![trust-third.webp](trust-third.webp "The more you develop the system, the more you trust it")

We can quickly achieve full functionality, but initially with low precision. 
Later, as we focus on increasing precision, development time extends, and the use of AI becomes more targeted or reduced. 
And we start to trust our system more.
This creates two extremes: a fully AI-driven system with low precision and a fully programmed system with high precision. 
The development process bridges the gap between these extremes. 
For some systems, low precision is acceptable, such as in our current task.
And we will likely start creating some systems in this way.
However, for critical applications like those in medicine, finance, and robotics, high precision is essential, and we will continue to code them as we do now.

## Final Note 

These days, we are experiencing a significant growth in AI tools.
Most of them we have already integrated into our work processes.
They can generate some code very well, especially when it's not your primary language and you don't remember tiny details.
For example, they can generate small Bash scripts, XSL transformations, YAML configurations, and so on.
They successfully generate unit tests as well as documentation. 
For example, you can generate README files based on the code in your repository or from well-written code comments. 
So, there is definitely progress in many areas.
What I can say for sure, we become more readers and verifiers then coders and writers.
And it definetly speeds up our work.

And yes, this post was written with great help from AI as well. Even the picture in this article was generated by AI. 
Moreover, as I already mentioned, in some cases, 
AI improves our systems indirectly—we start to prepare our data and make it more readable and understandable by systems like AI which yields results for people as well. 
So, it seems AI makes our code better.

However, I should admit that not all things are perfect. 
Obviously, we still can't give precise tasks to AI, and I'm not sure if we ever will. 
We also use these systems for code review, PR description summarization, and so on. 
To be honest, from my experience, they just create noise for the same reasons - they aren't precise, and we just don't trust them. 
And this noise is annoying.
Hence, In most cases, we simply ignore their results.

But AI is still far from being perfect. 
I don't trust it and require checking its results all the time since there are still many errors. 
Maybe, and most probably, this will change in the future, but for now, I'm still rather skeptical about it.
We still need to control the output of AI. At least, I still have lots of doubts about its work. 
But what about you? 
Do you trust them?

