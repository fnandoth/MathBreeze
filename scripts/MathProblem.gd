extends Node

# Enum defining available mathematical operations
enum OPERATION {ADD, SUBTRACT, MULTIPLY, DIVIDE}

# Problem generation variables
var CurrentOperation: OPERATION
var Operand1: int
var Operand2: int
var CorrectAnswer: float

# Generates a math problem based on difficulty level
# @param Difficulty: Integer representing problem difficulty (higher = harder)
# @return: Dictionary containing problem data (operands, operation, answer)
func GenerateProblem(Difficulty: int = 1) -> Dictionary:
	# Randomly select an operation from the enum
	CurrentOperation = OPERATION.values()[randi() % OPERATION.size()]
	
	# Calculate maximum operand value based on difficulty
	var MaxNumber = 10 + Difficulty * 5
	
	# Generate operands and calculate answer based on operation type
	match CurrentOperation:
		OPERATION.ADD:
			Operand1 = randi_range(1, MaxNumber)
			Operand2 = randi_range(1, MaxNumber)
			CorrectAnswer = Operand1 + Operand2
		
		OPERATION.SUBTRACT:
			Operand1 = randi_range(1, MaxNumber)
			Operand2 = randi_range(1, Operand1)  # Ensure non-negative results
			CorrectAnswer = Operand1 - Operand2
		
		OPERATION.MULTIPLY:
			Operand1 = randi_range(1, MaxNumber/2)  # Keep products reasonable
			Operand2 = randi_range(1, 10)  # Limit multiplication table
			CorrectAnswer = Operand1 * Operand2
		
		OPERATION.DIVIDE:
			Operand2 = randi_range(1, 10)  # Keep divisors manageable
			CorrectAnswer = randi_range(1, 5)  # Limit quotient range
			Operand1 = Operand2 * CorrectAnswer  # Ensure exact division
	
	return {
		"operand1": Operand1,
		"operand2": Operand2,
		"operation": CurrentOperation,
		"answer": CorrectAnswer
	}

# Formats the problem data into a displayable string
# @param ProblemData: Dictionary containing problem components
# @return: Formatted string (e.g., "5×3=")
func GetProblemText(ProblemData: Dictionary) -> String:
	var OpSymbol = ""
	match ProblemData["operation"]:
		OPERATION.ADD: OpSymbol = "+"
		OPERATION.SUBTRACT: OpSymbol = "-"
		OPERATION.MULTIPLY: OpSymbol = "×"
		OPERATION.DIVIDE: OpSymbol = "÷"
	
	return "%d%s%d=" % [ProblemData["operand1"], OpSymbol, ProblemData["operand2"]]

# Generates multiple choice options including the correct answer
# @param CorrectAnswer: The right answer to include
# @param Count: Total number of options to generate (default 4)
# @return: Shuffled array of answer options
func GenerateOptions(CorrectAnswer: int, Count: int = 4) -> Array:
	var Options = [CorrectAnswer]
	
	# Generate plausible wrong answers
	while Options.size() < Count:
		var Offset = randi_range(-10, 10)
		var FakeAnswer = CorrectAnswer + Offset
		
		# Ensure wrong answers are unique and non-negative
		if FakeAnswer not in Options and FakeAnswer >= 0:
			Options.append(FakeAnswer)
	
	Options.shuffle()
	return Options
