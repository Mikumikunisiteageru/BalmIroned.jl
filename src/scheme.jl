# src/scheme.jl

const STORAGETABLE = [
	S010 S020 S110 S120; S010 S020 S110 S120; S010 S020 S110 S120; 
	S100 S100 S000 S200; S100 S100 S000 S200; S100 S100 S000 S200; 
	S000 S001 S001 S002; S000 S001 S001 S002; S000 S001 S001 S002; 
	S001 S011 S101 S111; 
	S110 S300 S030 S003; 
	S000 S000 S110 S111; 
	S000 S000 S000 S000; S000 S000 S000 S000; 
	S000 S000 S000 S000; S000 S000 S000 S000; 
	S000 S000 S000 S000]

const STORECOSTTABLE = [
	S000 S000 S000 S000; S000 S000 S000 S000; S000 S000 S000 S000; 
	S000 S000 S___ S000; S000 S000 S___ S000; S000 S000 S___ S000; 
	S___ S000 S000 S000; S___ S000 S000 S000; S___ S000 S000 S000; 
	S100|S010 S100 S010 S100|S010|S001; 
	S020|S200 S020|S200 S200|S002 S200|S020; 
	S___ S___ S000 S000; 
	S___ S___ S___ S___; S___ S___ S___ S___; 
	S___ S___ S___ S___; S___ S___ S___ S___; 
	S___ S___ S___ S___]

const ROTATECOSTTABLE = [
	S010 S___ S110 S___; S010 S___ S110 S___; S010 S___ S110 S___; 
	S110 S___ S___ S202; S110 S___ S___ S202; S110 S___ S___ S202; 
	S200 S___ S120 S___; S200 S___ S120 S___; S200 S___ S120 S___; 
	S200 S___ S011 S___; 
	S010 S___ S110 S001; 
	S112 S___ S111 S___; 
	S110 S___ S___ S222; S110 S___ S___ S222; 
	S112 S___ S___ S334; S112 S___ S___ S334; 
	S___ S___ S___ S___]

const FLIPCOSTTABLE = [
	S010 S110 S___ S___; S010 S110 S___ S___; S010 S110 S___ S___; 
	S___ S101 S___ S___; S___ S101 S___ S___; S___ S101 S___ S___; 
	S020 S210 S___ S___; S020 S210 S___ S___; S020 S210 S___ S___; 
	S020 S101 S___ S___; 
	S100 S110 S___ S001; 
	S110 S___ S___ S222; 
	S___ S111 S___ S___; S___ S111 S___ S___; 
	S___ S223 S___ S___; S___ S223 S___ S___; 
	S___ S___ S___ S___]

const STARTABLE = [
	0 0 0 0; 0 0 0 0; 0 0 0 0; 
	0 1 5 2; 0 1 5 2; 0 1 5 2; 
	0 0 0 2; 0 0 0 2; 0 0 0 2; 
	0 0 0 0; 
	0 0 0 0; 
	0 4 0 0; 
	0 1 6 3; 0 1 6 3; 
	0 3 10 6; 0 3 10 6; 
	0 0 0 0]

const NAMETABLE = [
	"Canoe House", "Canoe House", "Canoe House", 
	"Logger", "Logger", "Logger", 
	"Quarry", "Quarry", "Quarry", 
	"Market", 
	"Trade House", 
	"Tool Maker", 
	"Housing", "Housing", 
	"Temple", "Temple", 
	"Round Marker"]
