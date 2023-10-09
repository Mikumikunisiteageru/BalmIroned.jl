# src/game.jl

HELPTEXT = "
C <card#> <status>       Check card of a given status
F <hand#> <queue#...>    Flip card and pay the cost from storage in queue
P <hand#>                Pass card
Q                        Quit immediately
R <hand#> <queue#...>    Rotate card and pay the cost from storage in queue
S <hand#> <queue#...>    Store card and pay the cost from storage in queue
"[2:end-1]

function exec!(deck, cmd, args)
	try
		if cmd == "C"
			@assert length(args) == 2
			display(Card(args[1], args[2]))
			println()
			return waitcommand!(deck)
		elseif cmd == "F"
			@assert length(args) >= 1
			return fliphand!(deck, args[1], args[2:end])
		elseif cmd == "P"
			@assert length(args) == 1
			return passhand!(deck, args[1])
		elseif cmd == "R"
			@assert length(args) >= 1
			return rotatehand!(deck, args[1], args[2:end])
		elseif cmd == "S"
			@assert length(args) >= 1
			return storehand!(deck, args[1], args[2:end])
		elseif cmd == "Q"
			throw(InterruptException())
		else
			error()
		end
	catch e
		isa(e, InterruptException) && throw(e)
		println(HELPTEXT, '\n')
		return waitcommand!(deck)
	end
end

function waitcommand!(deck)
	print("> ")
	line = uppercase(strip(readline()))
	cmd = line[1:1]
	words = split(strip(line[2:end]), ' ')
	args = tryparse.(Int, words)
	return exec!(deck, cmd, args)
end

function play()
	deck = init()
	println(HELPTEXT, '\n')
	while ! isnothing(deck)
		display(deck)
		deck = waitcommand!(deck)
	end
end
