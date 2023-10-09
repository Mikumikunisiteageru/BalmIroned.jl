# src/exceptions.jl

struct UncoverableError <: Exception end

struct StoreFullError <: Exception end

struct AmbiguityError <: Exception
	indsubsets
end

struct HandIndexError <: Exception end

struct QueueIndexError <: Exception end

struct CardUnstoredError <: Exception end

struct ArgumentNumberError <: Exception end

struct WrongCommandError <: Exception end

struct GameOver <: Exception
	stars
end
