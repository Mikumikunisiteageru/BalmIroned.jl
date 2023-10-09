# src/card.jl

struct Card
	no::Int8
	frs::Int8
end
function Card(no::Integer; 
		flipped::Bool=false, rotated::Bool=false, stored::Bool=false)
	frs = flipped << 2 + rotated << 1 + stored
	return Card(no, frs)
end

function banned(str::AbstractString, minlen=40, sep=' ', pad='-')
	len = length(str)
	if len == 0
		return pad ^ minlen
	elseif len >= minlen
		return str
	elseif len + 1 == minlen
		return str * sep
	else
		lendiff = minlen - len - 2
		leftpad = pad ^ (lendiff >> 1)
		rightpad = pad ^ (lendiff - lendiff >> 1)
		return leftpad * sep * str * sep * rightpad
	end
end

function Base.show(io::IO, ::MIME"text/oneline", card::Card)
	str = if isroundmarker(card)
		"End of Round $(card.frs+1)"
	elseif isstored(card)
		string(storage(card))
	else
		string()
	end
	print(io, banned(str))
	n = star(card)
	n > 0 && print(io, ' ', "*" ^ n)
end

function cardexpr(card::Card)
	n = star(card)
	return "Card($(card.no),$(card.frs))" * "*"^n
end

function Base.show(io::IO, ::MIME"text/plain", card::Card)
	isroundmarker(card) && 
		return print(io, "End of Round $(card.frs+1)")
	strs = ["$(name(card)) --- $(cardexpr(card))"]
	isfinite(storecost(card)) && 
		push!(strs, iszero(storecost(card)) ? 
			"\t> Store $(storage(card)) for free" : 
			"\t> Store $(storage(card)) by paying $(storecost(card))")
	isfinite(rotatecost(card)) && 
		push!(strs, "\t> Rotate to $(cardexpr(rotate(card))) " * 
			"by paying $(rotatecost(card))")
	isfinite(flipcost(card)) && 
		push!(strs, "\t> Flip to $(cardexpr(flip(card))) " * 
			"by paying $(flipcost(card))")
	push!(strs, "\t> Pass this card for free")
	print(io, join(strs, '\n'))
end

flip(card::Card) = Card(card.no, xor(4, card.frs))
rotate(card::Card) = Card(card.no, xor(2, card.frs))
store(card::Card) = Card(card.no, xor(1, card.frs))

isroundmarker(card::Card) = card.no == 17
isflipped(card::Card) = card.frs & 4 > 0
isrotated(card::Card) = card.frs & 2 > 0
isstored(card::Card) = isroundmarker(card) ? false : card.frs & 1 > 0

storage(card::Card) = STORAGETABLE[card.no, card.frs>>1+1]
storecost(card::Card) = STORECOSTTABLE[card.no, card.frs>>1+1]
rotatecost(card::Card) = ROTATECOSTTABLE[card.no, card.frs>>1+1]
flipcost(card::Card) = FLIPCOSTTABLE[card.no, card.frs>>1+1]
star(card::Card) = STARTABLE[card.no, card.frs>>1+1]
name(card::Card) = NAMETABLE[card.no]
