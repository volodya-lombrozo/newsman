# Do you trust me?

We live all these last years in a periof of AI boom. AI is everywhere: searching, learning, text processing, code review, code writing assistance, and many other systems araised in the last few years. Seems everybody is trying to apply an AI where it's possible and impossible. I'm not an exception. Under the influense of this wibe I decided to try to write something my own which would help me in everyday life and used AI somehow. So here I will tell you my own story of wrtiting an application with the use of AI. And some thoughts about it, of course, which a rather contradictory.

## Where to apply?

I'm working with a distributed team of developers and as any other team member I need to explain what I was doing in the last week (or didn't do) to my colegues and team mates. Our team actually prefere text-based reports instead of face-to-face communication, because many reasons (all the benifits were already mention many-many times.) So after a while we come up with a particular document format and structure which our report has to have. It has name [SIMBA](https://www.yegor256.com/2021/09/09/simba.html). Actually this format is extremly simple:

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

As you can see - there are three distinguishing parts which should be summarazied based on the results which you achived (or not) during the previous week.
This report is usually short and very simple. 
But, if you need to create this report every week - it might be tedious. 
Extremly tedious. 
Sometimes it's just hard to remeber what you were doing at the beggining of the previous week. 
Moreover, guys with lot's of projects suffer, because the switch they context almost each day and easily forget things.
Things that should be noticed.
So why we don't generate this report autmatically? 
Since we have an access to the activity of a developer. 
We use GitHub for our projects now, but the source of activity might be any other system.
Let's say that in out case GitHub is just a provider of a developer activity. 

However all this activity usually is bed formatted since we don't have any rigid conventions of Commits, Issue and Pull Request formatting.
Moreover, this formatting might change between projects.
And to be honest, we doesn't want to invent this rigid rules, restrictions and style guidelienes.
It's boring.
We have AI which will extract and format all this parts of this report for us.
Great, we have a suitable task.
Do you belive if AI will help us? I do.

## I'm lazy. Can you generate it for me?

I'm lazy and I don't have much time on writing a large script or an application to perform this task.
So the first attempt to generate a report was the most straightforward.
For the first part I also decided to concentrate on the "Last Week Achievements" part only.
All the rest parst I left empty.
We need only merged PRs for it. So I got GitHub API, retrieved banch of my closed Pull Requests for the previous week and
send them altogether with the following prompt.

Context:
```txt
You are a developer tasked with composing a concise report detailing your activities and progress for the previous week, intended for submission to your supervisor.
```
Prompt (don't read it entirely, it's boring):

```txt
Please compile a summary of the work completed in the following Pull Requests (PRs). Each PR should be summarized in a single sentence, focusing more on the PR title and less on implementation details. Group the sentences by repositories, each identified by its name mentioned in the 'repository:[name]' attribute of the PR. The grouping is important an should be precise. Ensure that each sentence includes the corresponding issue number as an integer value. If a PR doesn't mention an issue number, just print [#chore]. Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work. Please strictly adhere to the example template provided. Example of a report: #{example}. List of Pull Requests: [#{prs}]"}
```

I was lazy to do groupping programmatically, to prepare data, I just concat them using empty lines as delimeters between items.
I was lazy to even write this prompt myself. I asked ChatGPT to genere it for me. (By the way, it seems that Prompt Engeneer profession will die as fast as it was invented.)
And, surprisingly, I got great results despite using only gpt-3.5 version. 

Of course, it confused groupping by repositories, mixing Pull Requests between several projects.
And It lost several items. 
But the result looked human readable, and what is the most important, it correctly combined different parts (title and PR description) into a consise short sentences.
Just what we need.
I won't put direct results here, because they will only confuse you, but if you are really interested, I published all the [history](https://volodya-lombrozo.github.io/newsman/), so you can check starting from the old one and moving to the newest - you will see the history of results I got on my way.

After this attempt, I checked the report, added some missing points, fixed several sentences to restore their meaning and sent the report. Profit.

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
Please compile a summary of the risks identified in some repositories. If you can't find anything, just leave answer empty. Add some entries to a report only if you are sure it's a risk. Developers usually mention some risks in pull request descriptions. They either mention 'risk' or 'issue'. I will give you a list of pull requests. Each risk should be summarized in a single sentence. Ensure that each sentence includes the corresponding issue number or PR number as an integer value. If a PR or an issue doesn't mention an issue number, just print [#chore]. Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work. Please strictly adhere to the example template provided. Example of a report: #{example_risks}. List of Pull Requests: ```#{all}```.]
```

In order to avoid this problem, I had to mention risks directly in a PR descriptions:
Risk with the word "Risk" https://github.com/objectionary/opeo-maven-plugin/pull/259

As you can see, it's what I didn't want to do at all - structure my text. 


## Let's improve it?

Despite implementing all these parts, I still needed to do much of the work - structure, format, check that each generated sentence has valid meaning, or has meaning at all.
I decided to go using small steps.


