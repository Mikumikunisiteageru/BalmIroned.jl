# src/storage.jl

struct Storage
	wood::Int8
	fish::Int8
	rock::Int8
end
for wood = 0:3
	for fish = 0:3
		for rock = 0:4
			left = Symbol("S", wood, fish, rock)
			right = Storage(wood, fish, rock)
			expr = Expr(:(=), left, right)
			glexpr = Expr(:global, expr)
			conglexpr = Expr(:const, glexpr)
			eval(conglexpr)
		end
	end
end
const S___ = Storage(127, 127, 127)

function Base.show(io::IO, s::Storage)
	wood = s.wood
	fish = s.fish
	rock = s.rock
	str = ""
	wood == fish == rock == typemax(Int8) && return print(io, "Infinity")
	if wood > 0
		str *= " $wood Wood"
		wood > 1 && (str *= "s")
	end
	if fish > 0
		str *= " $fish Fish"
	end
	if rock > 0
		str *= " $rock Rock"
		rock > 1 && (str *= "s")
	end
	print(io, isempty(str) ? "Free" : str[2:end])
end

struct Storages
	sels::Vector{Storage}
end
Storages(s::Storage) = Storages([s])
Storages(s::Storages) = s

function Base.show(io::IO, s::Storages)
	for (i, sel) = enumerate(s.sels)
		i > 1 && print(io, ", or ")
		show(io, sel)
	end
end

const Storagez = Union{Storage, Storages}

Base.:|(s1::Storage, s2::Storage) = Storages([s1, s2])
Base.:|(s1::Storage, s2::Storages) = Storages([s1, s2.sels...])
Base.:|(s1::Storages, s2::Storage) = Storages([s1.sels..., s2])
Base.:|(s1::Storages, s2::Storages) = Storages([s1.sels..., s2.sels...])

Base.:+(s1::Storage, s2::Storage) = 
	Storage(s1.wood + s2.wood, s1.fish + s2.fish, s1.rock + s2.rock)
Base.:+(s1::Storagez, s2::Storagez) = Storages(s1) + Storages(s2)
function Base.:+(s1::Storages, s2::Storages)
	sels = Storage[]
	for s1sel = s1.sels
		for s2sel = s2.sels
			push!(sels, s1sel + s2sel)
		end
	end
	return Storages(unique(sels))
end

Base.:<=(s1::Storage, s2::Storage) = 
	s1.wood <= s2.wood && s1.fish <= s2.fish && s1.rock <= s2.rock
Base.:<=(s1::Storagez, s2::Storagez) = Storages(s1) <= Storages(s2)
function Base.:<=(s1::Storages, s2::Storages)
	for s1sel = s1.sels
		for s2sel = s2.sels
			s1sel <= s2sel && return true
		end
	end
	return false
end

Base.zero(::Storage) = S000
Base.zero(::Type{Storage}) = S000

Base.iszero(s::Storage) = s == S000
Base.iszero(s::Storages) = any(==(S000).(s.sels))

Base.isfinite(s::Storage) = s != S___
Base.isfinite(s::Storages) = any(!=(S___).(s.sels))
