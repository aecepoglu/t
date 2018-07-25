# t

A task manager for people who want to complete their tasks, not organize them.

## Simple, Effective & Extensible

**t**'s simplicity is its strength.

It is a very thin utility tool to manage a 'TODO.txt' that looks like so:

    [ ] buy groceries
    [ ] cook
    	[ ] chicken stew
    	[ ] dhal
    		[o] curry paste
		    (remember to make extra)
    		[o] dhal
    		[ ] rice
    [ ] publish 't'
    	develop t. It should feel and function like github.com/sjl/t
	perl could be a fun language for it
    	[o] the perl code
	[ ] README.md

The lines in the form of:

      [o] the description of the tasks
     ^ ^ ^
     | | |
     | | |
     | | +---- a space
     | +------ a character.
     |            conventionally, although you can :
     |              ` ` means it is a TODO,
     |              `o` means it is done
     |            and you can use any other k
     |
     +-------- any number of spaces or tabs
                   use indentation to visually define subtasks

Any other line is considered a comment. In fact it might be helpful for you or your teammates if you put a legend on top of your TODO.txt:

    # [ ] todo
    # [o] done
    # [x] canceled
    # [!] in progress
    # [r] needs research
    #----------------------------
     
## Usage

* `t` lists your tasks
* `t -e` opens your EDITOR to edit your tasks
* `t cancel the credit card` creates the task *cancel the credit card*.
* `t -h` shows its usage and rest of the options

## Why rewrite sjl/t

[sjl's t](http://github.com/sjl/t) is what inspired this tool.
We are staying faithful to its philosophy of keeping it simple, removing features that can be done by other tools while adding some of our own that we thought were lacking (*eg. colors*)

## To Contribute

The planned features are in the `TODO.txt` file :) Choose one and send me a PR or suggest a feature of your own.

The codebase is very small and relatively easy to develop new features on top of, but `t` is meant to be simple. If you are seeking something more powerful, [TaskWarrior](todo) or [todo.txt](todo) might suit you better.
