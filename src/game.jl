# src/game.jl

HELPTEXT = "
C <card#> <status>       Check card of a given status
F <hand#> <queue#...>    Flip card and pay the cost from storage in queue
P <hand#>                Pass card
Q                        Quit immediately
R <hand#> <queue#...>    Rotate card and pay the cost from storage in queue
S <hand#> <queue#...>    Store card and pay the cost from storage in queue
U <queue#>               Unstore a stored card in queue 
"[2:end-1]

plural(n, noun) = "$n $noun$(n > 1 ? "s" : "")"

function exec!(deck, line)
	try
		isempty(line) && throw(WrongCommandError())
		cmd = line[1:1]
		words = split(strip(line[2:end]), ' ')
		args = tryparse.(Int, words)
		if cmd == "C"
			length(args) == 2 || throw(ArgumentNumberError())
			display(Card(args[1], args[2]))
			println()
			return waitcommand!(deck)
		elseif cmd == "F"
			length(args) >= 1 || throw(ArgumentNumberError())
			return fliphand!(deck, args[1], args[2:end])
		elseif cmd == "P"
			length(args) == 1 || throw(ArgumentNumberError())
			return passhand!(deck, args[1])
		elseif cmd == "R"
			length(args) >= 1 || throw(ArgumentNumberError())
			return rotatehand!(deck, args[1], args[2:end])
		elseif cmd == "S"
			length(args) >= 1 || throw(ArgumentNumberError())
			return storehand!(deck, args[1], args[2:end])
		elseif cmd == "U"
			length(args) == 1 || throw(ArgumentNumberError())
			return unstorequeue!(deck, args[1])
		elseif cmd == "Q"
			throw(InterruptException())
		else
			throw(WrongCommandError())
		end
	catch e
		if isa(e, GameOver)
			@info "You won $(plural(e.stars, "star")) in this game (*ﾟ∇ﾟ)!"
			rethrow(e)
		elseif isa(e, InterruptException)
			rethrow(e)
		elseif isa(e, AmbiguityError)
			@warn "Suggested <queue#...>: $(join(e.indsubsets, "; "))"
		elseif isa(e, StoreFullError)
			@warn "Number of stored cards reaches limit (4)"
		elseif isa(e, UncoverableError)
			@warn "No stored card combination can cover the cost"
		elseif isa(e, HandIndexError)
			@warn "Index of card in hands must be in [1..2]"
		elseif isa(e, QueueIndexError)
			@warn "Index of card in queue must be in [1..15]"
		elseif isa(e, CardUnstoredError)
			@warn "Card to be consumed is not stored"
		elseif isa(e, WrongCommandError)
			@warn "Command must start with C/F/P/R/S/U/Q"
		else
			showerror(e)
		end
		println('\n', HELPTEXT, '\n')
		return waitcommand!(deck)
	end
end

function waitcommand!(deck)
	print("> ")
	line = uppercase(strip(readline()))
	println()
	return exec!(deck, line)
end

function play()
	deck = init()
	println(HELPTEXT, '\n')
	while true
		try
			display(deck)
			deck = waitcommand!(deck)
		catch e
			break
		end
	end
end
