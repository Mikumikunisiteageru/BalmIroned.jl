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

function powerset(collection::AbstractVector{T}) where T
	results = [T[]]
	for element = collection
		append!(results, vcat.(results, [element]))
	end
	return results
end

function costcombs(cost::Storagez, storages::AbstractVector{<:Storagez})
	indsubsets = powerset(eachindex(storages))
	powers = getindex.([storages], indsubsets)
	coverables = trues(size(powers))
	for i = eachindex(powers)
		if coverables[i]
			if cost <= sum(powers[i])
				for j = eachindex(powers)
					if j != i && issubset(indsubsets[i], indsubsets[j])
						coverables[j] = false
					end
				end
			else
				coverables[i] = false
			end
		end
	end
	@assert any(coverables)
	return indsubsets[coverables]
end

function costcomb(cost::Storagez, deck::Deck)
	qii = filter(i -> isstored(deck.queue[i]), 1:15)
	storages = storage.(deck.queue[qii])
	indsubsets = getindex.([qii], costcombs(cost, storages))
	if length(indsubsets) == 1
		return indsubsets[1]
	else
		@warn "Suggested <queue#...>: $(join(indsubsets, "; "))"
		error()
	end
end

function operatehand!(deck::Deck, operate, operatecost, hi, qii)
	checkqueuetop!(deck)
	@assert in(hi, 1:2)
	cost = operatecost(deck.hands[hi])
	@assert issubset(qii, 1:15)
	@assert all(isstored.(deck.queue[qii]))
	if isempty(qii)
		qii = costcomb(cost, deck)
	end
	for qi = qii
		deck.queue[qi] = store(deck.queue[qi])
	end
	push!(deck.queue, operate(deck.hands[hi]))
	deck.hands[hi] = popat!(deck.queue, 1)
	return deck
end

function storehand!(deck::Deck, hi, qii=[])
	@assert count(isstored.(deck.queue)) <= 3
	return operatehand!(deck, store, storecost, hi, qii)
end

rotatehand!(deck::Deck, hi, qii=[]) = 
	operatehand!(deck, rotate, rotatecost, hi, qii)
fliphand!(deck::Deck, hi, qii=[]) = operatehand!(deck, flip, flipcost, hi, qii)

function passhand!(deck::Deck, hi)
	checkqueuetop!(deck)
	@assert in(hi, 1:2)
	push!(deck.queue, deck.hands[hi])
	deck.hands[hi] = popat!(deck.queue, 1)
	return deck
end

function unstorequeue!(deck::Deck, qi)
	@assert in(qi, 1:15)
	@assert isstored(deck.queue[qi])
	deck.queue[qi] = store(deck.queue[qi])
	return deck
end
