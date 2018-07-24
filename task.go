package main

import (
	"bytes"
	"crypto/sha1"
	"encoding/hex"
	"fmt"
	"io"
	"strings"
)

type Task struct {
	id     string
	text   string
	isDone bool
}

const COLORED_FORMAT = "\x1B[34m%s\x1B[0m - %s\n"
const PLAIN_FORMAT = "%s - %s\n"

func (t *Task) Serialize() string {
	return t.text + " | id:" + t.id
}

func (t *Task) Less(o *Task) bool {
	return strings.Compare(t.id, o.id) < 0
}

func (t *Task) Matches(id string) bool {
	resp := strings.HasPrefix(t.id, id)
	return resp
}

func (t *Task) Fwrite(w io.Writer, idWidth int, color bool) {
	if color {
		fmt.Fprintf(w, COLORED_FORMAT, t.id[0:idWidth], t.text)
	} else {
		fmt.Fprintf(w, PLAIN_FORMAT, t.id[0:idWidth], t.text)
	}
}

func DeserializeTask(b []byte) (Task, error) {
	separator := bytes.LastIndexByte(b, '|')

	if separator < 1 {
		return Task{}, fmt.Errorf("could not parse \"%s\" as a task because id was not found.", b)
	} else if separator+2 >= len(b) {
		return Task{}, fmt.Errorf("could not parse \"%s\" because id could not be found.", b)
	}

	t := Task{
		text: string(b[0 : separator-1]),
	}
	hasId := false

	for i := separator + 2; i < len(b); {
		colon := bytes.IndexByte(b, ':')
		next := bytes.IndexByte(b[i:], ' ') + 1
		if next <= 0 {
			next = len(b)
		}

		key := string(b[i:colon])
		value := string(b[colon+1 : next])

		if strings.Compare(key, "id") == 0 {
			t.id = value
			hasId = true
		} else {
			return Task{}, fmt.Errorf("Unexpected task property: %s", key)
		}

		i = next
	}

	if hasId != true {
		return Task{}, fmt.Errorf("could not parse \"%s\" because id could not be found.", b)
	}

	return t, nil
}

func NewTask(text string) Task {
	hash := sha1.Sum([]byte(text))
	return Task{
		text: text,
		id:   hex.EncodeToString(hash[0:sha1.Size]),
	}
}
