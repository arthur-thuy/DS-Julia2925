#=
Created on Friday 4 December 2020
Last update: Saturday 26 December 2020

@author: Michiel Stock
michielfmstock@gmail.com

@author: Bram De Jaegher
bram.de.jaegher@gmail.com

Automatic grading of answers in our Pluto notebook.
Templates heavily based on the MIT course "Computational Thinking"

https://computationalthinking.mit.edu/Fall20/installation/
=#


mutable struct ProgressTracker 
	correct::Int
	total::Int
	name::String
	email::String
	ProgressTracker(name, email) = return new(0, 0, name, email)
end

addQuestion!(t::ProgressTracker) = t.total += 1
accept!(t::ProgressTracker) =	t.correct += 1
Base.show(io::IO, t::ProgressTracker) = print(io, "Notebook of **$(t.name)** with a completion of **$(t.correct) out of $(t.total)** question(s).")

function check_answer(validators,  t::ProgressTracker)
	addQuestion!(t)
	all_valid = all(validators)
	some_valid = any(validators)
	if ismissing(all_valid) 
		status = still_missing()
	elseif some_valid && !all_valid
		status = keep_working()
	elseif !all_valid
		status = keep_working()
	elseif all_valid 
		accept!(t)
		status = correct()
	end
	return status
end

function validate(q::AbstractQuestion, t::ProgressTracker)
	q.status = check_answer(q.validators, t)
	
	for (key, status) in q.opt_statuses
		q.opt_statuses[key] = check_answer(q.opt_validators[key])
	end
	return q
end

function grade(fn)
	open(fn, "a") do f
    write(f, "\ntracker\n")
	end
	include(fn)
	return tracker
end




