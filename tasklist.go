package main

import (
	"bufio"
	"io"
	"os"
	"sort"
)

type TaskList struct {
	path     string
	donePath string
	fp       *os.File
	tasks    []Task
	isDirty  bool
	writer   io.Writer
}

func (tl *TaskList) Len() int {
	return len(tl.tasks)
}

func (tl *TaskList) Swap(i, j int) {
	tl.tasks[i], tl.tasks[j] = tl.tasks[j], tl.tasks[i]
}

func (tl *TaskList) Less(i, j int) bool {
	return tl.tasks[i].Less(&tl.tasks[j])
}

// Load populates TaskList with tasks, sorting if necessary
func (tl *TaskList) Load() (err error) {
	tl.fp, err = os.OpenFile(tl.path, os.O_CREATE|os.O_RDWR, 0644)
	if err != nil {
		return err
	}

	reader := bufio.NewReader(tl.fp)

	bs := []byte{}
	var prev *Task
	needsSort := false
	for line := 0; ; line++ {
		bs, err = reader.ReadBytes('\n')
		if err == io.EOF {
			break
		} else if err != nil {
			panic(err)
		}

		t, err := DeserializeTask(bs[:len(bs)-1])

		if err != nil {
			continue
		}
		if prev != nil && prev.Less(&t) != true {
			needsSort = true
		}

		tl.tasks = append(tl.tasks, t)
		prev = &t
	}

	if needsSort {
		sort.Sort(tl)
	}

	return nil
}

func (tl *TaskList) Save() error {
	if tl.isDirty != true {
		return nil
	}

	doneFp, err := os.OpenFile(tl.donePath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return err
	}
	if err := tl.fp.Truncate(0); err != nil {
		return err
	}
	if _, err := tl.fp.Seek(0, os.SEEK_SET); err != nil {
		return err
	}

	for i := range tl.tasks {
		if tl.tasks[i].isDone {
			_, err = doneFp.WriteString(tl.tasks[i].Serialize() + "\n")
		} else {
			_, err = tl.fp.WriteString(tl.tasks[i].Serialize() + "\n")
		}

		if err != nil {
			return err
		}
	}

	if err := tl.fp.Close(); err != nil {
		return err
	}
	if err := doneFp.Close(); err != nil {
		return err
	}
	return nil
}

func (tl *TaskList) Finish(id string) {
	for i := range tl.tasks {
		if tl.tasks[i].Matches(id) {
			tl.tasks[i].isDone = true
			tl.isDirty = true
			break
		}
	}
}

// Add creates a Task from given text and adds it where it belongs
func (tl *TaskList) Add(text string) Task {
	t := NewTask(text)
	tl.tasks = append(tl.tasks, t)

	var i int
	//at [len(tl.tasks) - 2], we have what was the last element before append
	//and at [i+1] we have t
	for i = len(tl.tasks)-2; i >= 0 && t.Less(&tl.tasks[i]); i-- {
		tl.Swap(i, i+1)
	}
	tl.isDirty = true
	return t
}

// List prints the list of Tasks, printing shortest id possible for each
func (tl *TaskList) List(w io.Writer, color bool) {
	for line1 := 0; line1 < len(tl.tasks); line1++ {
		t := &tl.tasks[line1]
		col := 1

		for prev := line1 - 1; prev >= 0 && t.Matches(tl.tasks[prev].id[:col]); col++ {
		}

		t.Fwrite(w, col, color)
	}
}
