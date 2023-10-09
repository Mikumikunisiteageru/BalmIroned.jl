# src/deck.jl

const MAXROUND = 8

struct Deck
	hands::Vector{Card}
	queue::Vector{Card}
end

twodigit(n) = n < 10 ? "0" * string(n) : string(n)

function Base.show(io::IO, ::MIME"text/plain", deck::Deck)
	for i = 15:-1:2
		print(io, twodigit(i), ": ")
		show(io, "text/oneline", deck.queue[i])
		println(io)
	end
	print(io, twodigit(1), ": ")
	show(io, "text/plain", deck.queue[1])
	println(io, '\n')
	print(io, "Hand 1: ")
	show(io, "text/plain", deck.hands[1])
	println(io)
	print(io, "Hand 2: ")
	show(io, "text/plain", deck.hands[2])
	println(io)
end

getstored(deck::Deck, qii) = filter(isstored, deck.queue[qii])

getdeposit(deck::Deck, qii) = sum(storage.(getstored(deck, qii)))

function init()
	perm = [sortperm(rand(16)); 17]
	hands = Card.(perm[1:2])
	queue = Card.(perm[3:17])
	return Deck(hands, queue)
end

function terminate(deck)
	starhands = sum(star.(deck.hands))
	starqueue = sum(star.(deck.queue))
	startotal = starhands + starqueue
	@info "You get $startotal stars in this game!  ﾟ∀ﾟ)σ"
	return nothing
end

function checkqueuetop!(deck::Deck)
	while true
		if isroundmarker(deck.queue[1])
			card = popat!(deck.queue, 1)
			round = card.frs + 1
			push!(deck.queue, Card(17, round))
			@info "Round $round has finished. (`ε´ )"
			round >= MAXROUND && return terminate(deck)
		elseif isstored(deck.queue[1])
			card = popat!(deck.queue, 1)
			@info "Stored Card $(card.no) wasted... (;´д`)"
			push!(deck.queue, store(card))
		else
			break
		end
	end
	return deck
end

function operatehand!(deck::Deck, operate, operatecost, hi, qii)
	@assert in(hi, 1:2)
	@assert issubset(qii, 1:15)
	@assert all(isstored.(deck.queue[qii]))
	cost = operatecost(deck.hands[hi])
	deposit = getdeposit(deck, qii)
	@assert cost <= deposit
	for qi = qii
		deck.queue[qi] = store(deck.queue[qi])
	end
	push!(deck.queue, operate(deck.hands[hi]))
	deck.hands[hi] = popat!(deck.queue, 1)
	return checkqueuetop!(deck)
end

function storehand!(deck::Deck, hi, qii=[])
	@assert count(isstored.(deck.queue)) <= 3
	return operatehand!(deck, store, storecost, hi, qii)
end

rotatehand!(deck::Deck, hi, qii=[]) = 
	operatehand!(deck, rotate, rotatecost, hi, qii)
fliphand!(deck::Deck, hi, qii=[]) = operatehand!(deck, flip, flipcost, hi, qii)

function passhand!(deck::Deck, hi)
	@assert in(hi, 1:2)
	push!(deck.queue, deck.hands[hi])
	deck.hands[hi] = popat!(deck.queue, 1)
	return checkqueuetop!(deck)
end

function unstorequeue!(deck::Deck, qi)
	@assert in(qi, 1:15)
	@assert isstored(deck.queue[qi])
	deck.queue[qi] = store(deck.queue[qi])
	return deck
end
