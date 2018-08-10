#!/bin/bash

tmpdir=""

function globalsetup {
	cp ../t ./
	chmod +x ./t

	echo "\
[ ] the first task
[ ] a parent task
	[ ] a child task
		[ ] a grandchild

			some comments about the grandchild task
			some more comments

			even more comments

			[ ] child to grandchild
		[ ] second grandchild
	[ ] another child
		[ ] third grandchild
[ ] another parent
	[ ] yet another child" > sample-complex-todo.txt

	echo "\
[ ] first task
[ ] second task" > sample-basic-todo.txt
}

function globalcleanup {
	rm ./t
	rm ./sample-complex-todo.txt
	rm ./sample-basic-todo.txt
}

function setup {
	tmpdir=$(mktemp -d T_TEST_XXX)
	cd $tmpdir
}

function cleanup {
	cd ../
	rm -rf $tmpdir
}

function test_list_format {
	cp ../sample-complex-todo.txt TODO.txt
	echo "\
1. the first task
2. a parent task
3. 	a child task
4. 		a grandchild
11. 			child to grandchild
12. 		second grandchild
13. 	another child
14. 		third grandchild
15. another parent
16. 	yet another child" > expected.txt

	../t | diff expected.txt - || return 1
}

function test_hides_complete_items {
	echo "\
[o] complete item
[ ] incomplete item
[o] complete parent
	[ ] incomplete child of complete parent
	[o] complete child of complete parent
[ ] incomplete parent
	[ ] incomplete child of incomplete parent
	[o] complete child of incomplete parent
[k] a different item" > TODO.txt
	echo "\
2. incomplete item
4. 	incomplete child of complete parent
6. incomplete parent
7. 	incomplete child of incomplete parent" > expected.txt

	../t | diff expected.txt - || return 1
}

function test_list_in_other_folder {
	mkdir somewhere-else
	cp ../sample-basic-todo.txt ./somewhere-else/TODO.txt
	echo "\
1. first task
2. second task" > expected.txt
	
	../t -t somewhere-else | diff expected.txt - || return 1
}

function test_list_in_other_file {
	cp ../sample-basic-todo.txt ./another.txt
	echo "\
1. first task
2. second task" > expected.txt
	../t -l "another.txt" | diff expected.txt - || return 1
}

function test_list_with_nonexistent_file {
	echo -n "" > expected.txt
	../t | diff -y expected.txt - || return 1
}

function test_add_task {
	cp ../sample-basic-todo.txt ./TODO.txt
	echo "\
[ ] first task
[ ] second task
[ ] third task" > expected.txt

	../t third task || return 1
	diff TODO.txt expected.txt || return 1
}

function test_add_task_with_nonexistent_list_file {
	echo "[ ] a new task" > expected.txt

	../t a new task || return 1
	diff --color=always TODO.txt expected.txt || return 1
}

function main {
	testCount=0
	passCount=0
	
	globalsetup
	declare -a funs=(\
		test_list_format \
		test_list_in_other_file \
		test_list_in_other_folder \
		test_list_with_nonexistent_file \
		test_hides_complete_items \
		test_add_task \
		test_add_task_with_nonexistent_list_file \
	)
	for f in ${funs[@]}; do
		setup
		echo "TEST: $f:"
		$f
		result=$?
		cleanup
	
		if [ $result -ne 0 ]; then
			echo "  FAIL"
		else
			echo "  OK"
			passCount=$(($passCount + 1))
		fi
		testCount=$((testCount + 1))
		echo ""
	done
	globalcleanup
	
	echo "$passCount / $testCount" tests passed.
	
	if [ "$passCount" -lt "$testCount" ]; then
		exit 1
	else
		exit 0
	fi
}

main
