package main

import (
	"flag"
	"log"
	"os"
	"path"
	"strings"
	//"github.com/karrick/golf" for short/long cli flags
)

func usage() {
	log.Printf("%s [-t DIR] [-l LIST] [OPTIONS] [TEXT]\n", os.Args[0])
	flag.PrintDefaults()
}

func main() {
	tasks := TaskList{
		writer: os.Stdout,
	}
	var (
		finish    string
		dir       string
		list      string
		color     string
		hasColors bool
		help      bool
	)

	flag.Usage = usage
	flag.StringVar(&finish, "f", "", "mark TASK as finished")
	flag.StringVar(&dir, "t", "./", "dir to find list in")
	flag.StringVar(&list, "l", "tasks", "list to work on")
	flag.StringVar(&color, "c", "auto", "color mode: never|always|auto")
	flag.BoolVar(&help, "h", false, "show usage")
	flag.Parse()

	switch color {
	case "never":
		hasColors = false
	case "always":
		hasColors = true
	case "auto":
		if fi, _ := os.Stdout.Stat(); fi.Mode()&os.ModeCharDevice != 0 {
			hasColors = true
		}

	}

	tasks.path = path.Join(dir, list)
	tasks.donePath = path.Join(dir, "."+list+".done")

	if err := tasks.Load(); err != nil {
		log.Fatal(err)
	}

	switch {
	case help:
		flag.Usage()
	case len(finish) > 0:
		tasks.Finish(finish)
	case len(flag.Args()) > 0:
		tasks.Add(strings.Join(flag.Args(), " "))
	default:
		tasks.List(os.Stdout, hasColors)
	}

	if err := tasks.Save(); err != nil {
		log.Fatal(err)
	}

}
