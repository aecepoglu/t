package main

import (
	"bytes"
	. "gopkg.in/go-playground/assert.v1"
	"testing"
)

func TestList(t *testing.T) {
	buf := bytes.Buffer{}

	tl := TaskList{
		tasks: []Task{
			Task{id: "a123456", text: "one"},
			Task{id: "b123456", text: "two"},
			Task{id: "c123456", text: "three"},
			Task{id: "ca12345", text: "four"},
			Task{id: "cb12345", text: "five"},
			Task{id: "cba1234", text: "six"},
			Task{id: "cbb1234", text: "seven"},
		},
	}

	tl.List(&buf, false)

	Equal(t, buf.String(), ""+
		"a - one\n"+
		"b - two\n"+
		"c - three\n"+
		"ca - four\n"+
		"cb - five\n"+
		"cba - six\n"+
		"cbb - seven\n")
}

func TestAddToMiddle(t *testing.T) {
	tl := TaskList{
		tasks: []Task{
			Task{id: "00", text: "ay"},
			Task{id: "zz1", text: "see"},
			Task{id: "zz2", text: "see"},
		},
	}

	newT := tl.Add("bee")
	
	Equal(t, len(tl.tasks), 4)
	Equal(t, tl.tasks[0], Task{id: "00", text: "ay"})
	Equal(t, tl.tasks[1], newT)
	Equal(t, tl.tasks[2], Task{id: "zz1", text: "see"})
	Equal(t, tl.tasks[3], Task{id: "zz2", text: "see"})
}

func TestAddToStart(t *testing.T) {
	tl := TaskList{
		tasks: []Task{
			Task{id: "zz1", text: "see"},
			Task{id: "zz2", text: "see"},
		},
	}

	newT := tl.Add("bee")
	
	Equal(t, len(tl.tasks), 3)
	Equal(t, tl.tasks[0], newT)
	Equal(t, tl.tasks[1], Task{id: "zz1", text: "see"})
	Equal(t, tl.tasks[2], Task{id: "zz2", text: "see"})
}

func TestAddToEnd(t *testing.T) {
	tl := TaskList{
		tasks: []Task{
			Task{id: "001", text: "ay"},
			Task{id: "002", text: "ayy"},
		},
	}

	newT := tl.Add("bee")
	
	Equal(t, len(tl.tasks), 3)
	Equal(t, tl.tasks[0], Task{id: "001", text: "ay"})
	Equal(t, tl.tasks[1], Task{id: "002", text: "ayy"})
	Equal(t, tl.tasks[2], newT)
}

func TestFinish(t *testing.T) {
	tl := TaskList{
		tasks: []Task{
			Task{id: "a"},
			Task{id: "ab"},
			Task{id: "abc"},
		},
	}

	tl.Finish("ab")

	Equal(t, tl.tasks[1].isDone, true)
}
