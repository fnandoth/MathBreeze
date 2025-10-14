extends Node
enum OPERATION {ADD, SUBTRACT, MULTIPLY, DIVIDE}
var CurrentOperation: OPERATION
var Operand1: int
var Operand2: int
var CorrectAnswer: int

func GenerateProblem(Difficulty: int = 1) -> Dictionary:
	CurrentOperation = OPERATION.values()[randi() % OPERATION.size()]
	
	var MaxNumber = 10 + Difficulty * 5
	
	match CurrentOperation:
		OPERATION.ADD:
			Operand1 = randi_range(1, MaxNumber)
			Operand2 = randi_range(1, MaxNumber)
			CorrectAnswer = Operand1 + Operand2
		
		OPERATION.SUBTRACT:
			Operand1 = randi_range(1, MaxNumber)
			Operand2 = randi_range(1, Operand1)
			CorrectAnswer = Operand1 - Operand2
		
		OPERATION.MULTIPLY:
			Operand1 = randi_range(1, MaxNumber / 2.0)
			Operand2 = randi_range(1, 10)
			CorrectAnswer = Operand1 * Operand2
		
		OPERATION.DIVIDE:
			Operand2 = randi_range(1, 10)
			CorrectAnswer = randi_range(1, 5)
			Operand1 = Operand2 * CorrectAnswer
	
	return {
		"operand1": Operand1,
		"operand2": Operand2,
		"operation": CurrentOperation,
		"answer": CorrectAnswer
	}

func GetProblemText(ProblemData: Dictionary) -> String:
	var OpSymbol = ""
	match ProblemData["operation"]:
		OPERATION.ADD: OpSymbol = "+"
		OPERATION.SUBTRACT: OpSymbol = "-"
		OPERATION.MULTIPLY: OpSymbol = "*"
		OPERATION.DIVIDE: OpSymbol = "/"
	
	return "%d%s%d=" % [ProblemData["operand1"], OpSymbol, ProblemData["operand2"]]

func GenerateOptions(CorrectValue: int, Count: int = 4) -> Array:
	var Options = [CorrectValue]
	
	while Options.size() < Count:
		var Offset = randi_range(-10, 10)
		var FakeAnswer = CorrectValue + Offset
		
		if FakeAnswer not in Options and FakeAnswer >= 0:
			Options.append(FakeAnswer)
	
	Options.shuffle()
	return Options
