package jass
import strings "core:strings"
import strconv "core:strconv"

Word :: union #no_nil {string, proc()}
Parameter :: union #no_nil {string, f32}

// runtime
dict := make(map[string]Word)
stack: [dynamic]Parameter
log: [dynamic]string

add :: proc()
{
	a_ok, b_ok := false, false
	a, b : f32 = 0.0, 0.0

	switch v in stack[len(stack)-1]
	{
		case string:
		return
		case f32:
		a = v
		a_ok = true
	}

	switch v in stack[len(stack)-2]
	{
		case string:
		return
		case f32:
		b = v
		b_ok = true
	}

	if b_ok && a_ok
	{
		pop(&stack)
		pop(&stack)
		append(&stack, a + b)
	}
}

mul :: proc()
{
	a_ok, b_ok := false, false
	a, b : f32 = 0.0, 0.0

	switch v in stack[len(stack)-1]
	{
		case string:
		return
		case f32:
		a = v
		a_ok = true
	}

	switch v in stack[len(stack)-2]
	{
		case string:
		return
		case f32:
		b = v
		b_ok = true
	}

	if b_ok && a_ok
	{
		pop(&stack)
		pop(&stack)
		append(&stack, a * b)
	}
}

sub :: proc()
{
	a_ok, b_ok := false, false
	a, b : f32 = 0.0, 0.0

	switch v in stack[len(stack)-1]
	{
		case string:
		return
		case f32:
		a = v
		a_ok = true
	}

	switch v in stack[len(stack)-2]
	{
		case string:
		return
		case f32:
		b = v
		b_ok = true
	}

	if b_ok && a_ok
	{
		pop(&stack)
		pop(&stack)
		append(&stack, a - b)
	}
}

div :: proc()
{
	a_ok, b_ok := false, false
	a, b : f32 = 0.0, 0.0

	switch v in stack[len(stack)-1]
	{
		case string:
		return
		case f32:
		a = v
		a_ok = true
	}

	switch v in stack[len(stack)-2]
	{
		case string:
		return
		case f32:
		b = v
		b_ok = true
	}

	if b_ok && a_ok
	{
		pop(&stack)
		pop(&stack)
		append(&stack, a / b)
	}
}

dup :: proc()
{
	append(&stack, stack[len(stack)-1])
}

drop :: proc()
{
	if len(&stack) > 0 { pop(&stack) }
}

read_forward_dict := make(map[string]proc([]string))


define_word :: proc(tokens: []string)
{
	if (len(tokens) < 3)
	{
		return
	}

	label := tokens[1]
	defined_line := strings.join(tokens[2:], " ")
	dict[label] = Word(defined_line)
}

define_proc_word :: proc(label: string, procedure: proc())
{
	dict[label] = Word(procedure)
}

init_runtime :: proc()
{
	read_forward_dict["def"] = define_word
	define_proc_word("add", add)
	define_proc_word("mul", mul)
	define_proc_word("sub", sub)
	define_proc_word("div", div)
	define_proc_word("dup", dup)
	define_proc_word("drop", drop)
}

run_line :: proc(line: string)
{
	if len(line) > 0
	{
		if line[0] != '#'
		{
			tokens := strings.fields(line)

			for word in read_forward_dict
			{
				if tokens[0] == word
				{
					read_forward_dict[word](tokens)
					return
				}
			}


			for token in tokens
			{
			// push tokens that look like floats to the stack
				tmp, ok1 := strconv.parse_f32(token)
				if ok1 {
					append(&stack, tmp)
					continue
				}

				val, defined := dict[token]
				if !defined
				{
					//fmt.printf("Invalid command \"%s\"\n", token)
					// param : Parameter = token
					// append(&stack, param)
					// continue
					if token[0] == '\"' && token[len(token)-1] == '\"'
					{
						param : Parameter = token[1 : len(token)-1]
						append(&stack, param)
						continue
					}
				}

				
				switch v in val
				{
					case string:
					run_line(v)
					case proc():
					v()
				}
			}
		}
	}
}
