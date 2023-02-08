# TaskProcessor

Hello reviewers! Nice to git-meet you.
I understand reviewing many candidates' code is hard, especially when each of them have different design and styles. So I'd like to guide you my project briefly.

## Design
You can traverse the project based on three parts. This project is following [phoenix design guide](https://hexdocs.pm/phoenix/contexts.html#thinking-about-design).
- Context: `TaskProcessor.CommandTask`
- Controller: `TaskProcessorWeb.TaskController`
- Test: `TaskProcessor.CommandTaskTest`, `TaskProcessorWeb.TaskControllerTest`

## Results
[workflow](https://github.com/parkdoyeon/task_processor/actions/workflows/dialyzer-and-test.yml/badge.svg)
To check weather I successfully solved to problem, I first recommend you first to go test and CI ☝️. I wrote controller and context tests. 
For success test case, I included sample data in task instruction pdf.

I made two apis as requested.
- POST "http://localhost:4000/api" - return processed tasks
- POST "http://localhost:4000/api/bash" - return processed tasks' bash commands

And for the `/api/bash`, I tested it in my local machine too. 
```bash
curl -d @sample_tasks.json http://localhost:4000/api/bash -H "Content-Type: application/json" | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   527  100    78  100   449    944   5434 --:--:-- --:--:-- --:--:--  6587
Hello World!
```

## Logic

If you want to check how the task processing logic is implemented, please start from [this line](https://github.com/parkdoyeon/task_processor/blob/main/lib/task_processor/command_task.ex#L36-L42). I wrote a docstring how sort operation is implemented.

I solved similar topological sort problem few months ago to demonstrate the concept of the GenServer to my work colleagues. It was [advent of code 2018 day7](https://adventofcode.com/2018/day/7) part 2 questions. To keep state to find vertex with no incoming edges, `requires` in this problem, it's good to try GenServer. But for this task, requirements are rather not complex. So, I decided to keep it simple. If you want to check out my GenServer repository, here it is.

## More
I spent quite a time thinking whether I use struct or any type of static schema validating task map. But this kind of decision depends on architecture and team convention. If this is internal project, I would enjoy convenience and efficiency of dynamic typing. However, if requests come from outside of world, I would use embedded schema for type checking and changeset for validation to make unexpected request payload visible.

Hope my code not to take away your time too much. Thanks!
