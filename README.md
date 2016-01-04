# HandsOnMath

I think that software applications have the potential to be extraordinarily better for learning than textbooks, videos, or lectures. This is one attempt to show what that might look like.

I started it at HackingEDU hackathon and have been continuing to work on it a bit, and it is still in development (so please excuse the commented out code and the print statements). Below is the write up I made for the hackathon.

## Teaching and Learning

**“Tell me and I forget, teach me and I may remember, involve me and I learn”**  -_Ben Franklin_

I think a lot about good teaching and bad teaching. For a while, I though that bad teaching meant telling people facts while good teaching meant telling people ideas, explanations, justifications, and letting them use those to remember the facts. I still mostly think that, but I also think that if you can discover something yourself, without having someone else tell you, that is the most powerful way to learn.

Importantly, enabling self discovery is hard, and I think for many lessons interacting with a device (as opposed to consuming a lecture from a speaker, book, or online video) is a necessary part.

So I took a math concept (combining factors and exponents) and built an experience for students to discover the lesson, not have someone else tell it to them. 

 
## What I made

![hands on math](http://i.imgur.com/JMq3Doq.gif)

(the round dots in the demo are "fingers", since you can't pinch with a mouse)

I built a native iOS app using Swift that allows the student to discover the rules of how factors combine when they are multiplied together. There are no instructions, no explicit rules. Just some structured behaviors that the student is left to observe and understand. 

The app presents the student with a mathematical expression full of terms and exponents. There is a simplified version beneath it that serves as a kind of end goal. To get there, the student can physically manipulate the expression, through the touch screen, and see how different terms combine and interact through direct manipulation.

## Challenges and Accomplishments

I felt strongly that it was important to accurately model the full interactions and forms that these mathematical expressions can take. So instead of scripting up a skeleton demo without any behind the scenes logic, I built out the data model that almost completely handles the interactions, combinations, substitutions, reorderings and more that can take place with expressions in math.

A particular highlight is [this file](https://github.com/mlipman/HandsOnMath/blob/master/HandsOnMath/ExpressionBrain.swift) which represents how the data is modeled.

Also checkout my [recent commits](https://github.com/mlipman/HandsOnMath/commits/master).
