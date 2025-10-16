extends Node

enum OPERATION {
	ADD, SUBTRACT, MULTIPLY, DIVIDE,
	FRACTION_ADD, FRACTION_SUBTRACT, FRACTION_MULTIPLY, FRACTION_DIVIDE,
	DECIMAL_ADD, DECIMAL_SUBTRACT, DECIMAL_MULTIPLY, DECIMAL_DIVIDE,
	PERCENTAGE, PERCENTAGE_INCREASE, PERCENTAGE_DECREASE,
	PROPORTION_DIRECT, PROPORTION_INVERSE,
	RULE_OF_THREE_DIRECT, RULE_OF_THREE_INVERSE,
	POWER, SQUARE_ROOT, CUBE_ROOT
}

class Fraction:
	var numerator: int
	var denominator: int
	
	func _init(n: int, d: int):
		numerator = n
		denominator = d
		simplify()
	
	func simplify():
		var g = gcd(abs(numerator), abs(denominator))
		numerator /= g
		denominator /= g
		if denominator < 0:
			numerator = -numerator
			denominator = -denominator
	
	func fake_to_string() -> String:
		if denominator == 1:
			return str(numerator)
		return "%d/%d" % [numerator, denominator]
	
	func to_float() -> float:
		return float(numerator) / float(denominator)
	
	static func gcd(a: int, b: int) -> int:
		while b != 0:
			var temp = b
			b = a % b
			a = temp
		return a

var CurrentOperation: OPERATION
var CorrectAnswer
var rng = RandomNumberGenerator.new()
var ops = []

func _ready():
	rng.randomize()

func GenerateProblem(Difficulty: int = 1) -> Dictionary:
	var available_ops = _get_operations_for_difficulty(Difficulty)
	CurrentOperation = available_ops[rng.randi() % available_ops.size()]
	
	var problem_data = {}
	
	match CurrentOperation:
		OPERATION.ADD:
			problem_data = _generate_addition(Difficulty)
		OPERATION.SUBTRACT:
			problem_data = _generate_subtraction(Difficulty)
		OPERATION.MULTIPLY:
			problem_data = _generate_multiplication(Difficulty)
		OPERATION.DIVIDE:
			problem_data = _generate_division(Difficulty)
		OPERATION.FRACTION_ADD:
			problem_data = _generate_fraction_operation(Difficulty, "add")
		OPERATION.FRACTION_SUBTRACT:
			problem_data = _generate_fraction_operation(Difficulty, "subtract")
		OPERATION.FRACTION_MULTIPLY:
			problem_data = _generate_fraction_operation(Difficulty, "multiply")
		OPERATION.FRACTION_DIVIDE:
			problem_data = _generate_fraction_operation(Difficulty, "divide")
		OPERATION.DECIMAL_ADD:
			problem_data = _generate_decimal_operation(Difficulty, "add")
		OPERATION.DECIMAL_SUBTRACT:
			problem_data = _generate_decimal_operation(Difficulty, "subtract")
		OPERATION.DECIMAL_MULTIPLY:
			problem_data = _generate_decimal_operation(Difficulty, "multiply")
		OPERATION.DECIMAL_DIVIDE:
			problem_data = _generate_decimal_operation(Difficulty, "divide")
		OPERATION.PERCENTAGE:
			problem_data = _generate_percentage(Difficulty)
		OPERATION.PERCENTAGE_INCREASE:
			problem_data = _generate_percentage_change(Difficulty, true)
		OPERATION.PERCENTAGE_DECREASE:
			problem_data = _generate_percentage_change(Difficulty, false)
		OPERATION.PROPORTION_DIRECT:
			problem_data = _generate_proportion(Difficulty, true)
		OPERATION.PROPORTION_INVERSE:
			problem_data = _generate_proportion(Difficulty, false)
		OPERATION.RULE_OF_THREE_DIRECT:
			problem_data = _generate_rule_of_three(Difficulty, true)
		OPERATION.RULE_OF_THREE_INVERSE:
			problem_data = _generate_rule_of_three(Difficulty, false)
		OPERATION.POWER:
			problem_data = _generate_power(Difficulty)
		OPERATION.SQUARE_ROOT:
			problem_data = _generate_square_root(Difficulty)
		OPERATION.CUBE_ROOT:
			problem_data = _generate_cube_root(Difficulty)
	
	return problem_data

func _get_operations_for_difficulty(diff: int) -> Array:
	if diff >= 1:
		ops.append_array([
			OPERATION.ADD, OPERATION.SUBTRACT, 
			OPERATION.MULTIPLY, OPERATION.DIVIDE]
		)
	
	if diff >= 2:
		ops.append_array([
			OPERATION.FRACTION_ADD, OPERATION.FRACTION_SUBTRACT,
			OPERATION.DECIMAL_ADD, OPERATION.DECIMAL_SUBTRACT
		])
	
	if diff >= 3:
		ops.append_array([
			OPERATION.FRACTION_MULTIPLY, OPERATION.FRACTION_DIVIDE,
			OPERATION.DECIMAL_MULTIPLY, OPERATION.DECIMAL_DIVIDE,
			OPERATION.PERCENTAGE, OPERATION.PERCENTAGE_INCREASE, OPERATION.PERCENTAGE_DECREASE
		])
	
	if diff >= 4:
		ops.append_array([
			OPERATION.PROPORTION_DIRECT, OPERATION.RULE_OF_THREE_DIRECT,
			OPERATION.POWER, OPERATION.SQUARE_ROOT
		])
	
	if diff >= 5:
		ops.append_array([
			OPERATION.PROPORTION_INVERSE, OPERATION.RULE_OF_THREE_INVERSE,
			OPERATION.CUBE_ROOT
		])
	
	return ops

# ===== OPERACIONES BÁSICAS =====
func _generate_addition(diff: int) -> Dictionary:
	var max_num = 10 + diff * 15
	var op1 = rng.randi_range(1, max_num)
	var op2 = rng.randi_range(1, max_num)
	CorrectAnswer = op1 + op2
	
	return {
		"operand1": op1,
		"operand2": op2,
		"operation": OPERATION.ADD,
		"answer": CorrectAnswer,
		"problem_text": "%d + %d = " % [op1, op2],
	}

func _generate_subtraction(diff: int) -> Dictionary:
	var max_num = 10 + diff * 15
	var op1 = rng.randi_range(10, max_num)
	var op2 = rng.randi_range(1, op1)
	CorrectAnswer = op1 - op2
	
	return {
		"operand1": op1,
		"operand2": op2,
		"operation": OPERATION.SUBTRACT,
		"answer": CorrectAnswer,
		"problem_text": "%d - %d = " % [op1, op2],
	}

func _generate_multiplication(diff: int) -> Dictionary:
	var max_num = 5 + diff * 3
	var op1 = rng.randi_range(2, max_num)
	var op2 = rng.randi_range(2, 12)
	CorrectAnswer = op1 * op2
	
	return {
		"operand1": op1,
		"operand2": op2,
		"operation": OPERATION.MULTIPLY,
		"answer": CorrectAnswer,
		"problem_text": "%d × %d = " % [op1, op2],
	}

func _generate_division(diff: int) -> Dictionary:
	var divisor = rng.randi_range(2, 12)
	var quotient = rng.randi_range(1, 5 + diff * 2)
	var op1 = divisor * quotient
	CorrectAnswer = quotient
	
	return {
		"operand1": op1,
		"operand2": divisor,
		"operation": OPERATION.DIVIDE,
		"answer": CorrectAnswer,
		"problem_text": "%d ÷ %d = " % [op1, divisor],
	}

# ===== FRACCIONES =====
func _generate_fraction_operation(diff: int, op_type: String) -> Dictionary:
	var max_den = 6 + diff * 2
	var f1 = Fraction.new(rng.randi_range(1, 10), rng.randi_range(2, max_den))
	var f2 = Fraction.new(rng.randi_range(1, 10), rng.randi_range(2, max_den))
	
	var result_num: int
	var result_den: int
	var op_symbol: String
	
	match op_type:
		"add":
			result_num = f1.numerator * f2.denominator + f2.numerator * f1.denominator
			result_den = f1.denominator * f2.denominator
			op_symbol = "+"
		"subtract":
			result_num = f1.numerator * f2.denominator - f2.numerator * f1.denominator
			result_den = f1.denominator * f2.denominator
			op_symbol = "-"
		"multiply":
			result_num = f1.numerator * f2.numerator
			result_den = f1.denominator * f2.denominator
			op_symbol = "×"
		"divide":
			result_num = f1.numerator * f2.denominator
			result_den = f1.denominator * f2.numerator
			op_symbol = "÷"
	
	var result = Fraction.new(result_num, result_den)
	CorrectAnswer = result.to_float()
	
	return {
		"operand1": f1.fake_to_string(),
		"operand2": f2.fake_to_string(),
		"operation": CurrentOperation,
		"answer": result.fake_to_string(),
		"answer_decimal": CorrectAnswer,
		"problem_text": "%s %s %s = " % [f1.fake_to_string(), op_symbol, f2.fake_to_string()],
	}

# ===== DECIMALES =====
func _generate_decimal_operation(diff: int, op_type: String) -> Dictionary:
	var max_val = 10.0 + diff * 5.0
	
	var op1 = snappedf(rng.randf_range(0.1, max_val), 0.01)
	var op2 = snappedf(rng.randf_range(0.1, max_val), 0.01)
	
	var op_symbol: String
	
	match op_type:
		"add":
			CorrectAnswer = snappedf(op1 + op2, 0.01)
			op_symbol = "+"
		"subtract":
			if op2 > op1:
				var temp = op1
				op1 = op2
				op2 = temp
			CorrectAnswer = snappedf(op1 - op2, 0.01)
			op_symbol = "-"
		"multiply":
			op1 = snappedf(rng.randf_range(0.1, 10.0), 0.1)
			op2 = snappedf(rng.randf_range(0.1, 10.0), 0.1)
			CorrectAnswer = snappedf(op1 * op2, 0.01)
			op_symbol = "×"
		"divide":
			op2 = snappedf(rng.randf_range(0.5, 5.0), 0.1)
			CorrectAnswer = snappedf(rng.randf_range(1.0, 10.0), 0.1)
			op1 = snappedf(op2 * CorrectAnswer, 0.01)
			op_symbol = "÷"
	
	return {
		"operand1": op1,
		"operand2": op2,
		"operation": CurrentOperation,
		"answer": CorrectAnswer,
		"problem_text": "%.2f %s %.2f = " % [op1, op_symbol, op2],
	}

# ===== PORCENTAJES =====
func _generate_percentage(diff: int) -> Dictionary:
	var base = rng.randi_range(20, 200 + diff * 50)
	var percent = rng.randi_range(5, 50) if diff < 4 else rng.randi_range(1, 100)
	CorrectAnswer = int(base * percent / 100.0)
	
	return {
		"operand1": percent,
		"operand2": base,
		"operation": OPERATION.PERCENTAGE,
		"answer": CorrectAnswer,
		"problem_text": "How much is %d%% of %d? " % [percent, base],
	}

func _generate_percentage_change(diff: int, increase: bool) -> Dictionary:
	var base = rng.randi_range(50, 500 + diff * 100)
	var percent = rng.randi_range(10, 50)
	var change = int(base * percent / 100.0)
	CorrectAnswer = base + change if increase else base - change
	
	var action = "increase" if increase else "decrease"
	
	return {
		"operand1": base,
		"operand2": percent,
		"operation": CurrentOperation,
		"answer": CorrectAnswer,
		"problem_text": "If a product costs $%d and %s %d%%, what is the final price? " % [base, action, percent],
	}

# ===== PROPORCIONES =====
func _generate_proportion(diff: int, direct: bool) -> Dictionary:
	var a = rng.randi_range(2, 10)
	var b = rng.randi_range(2, 20 + diff * 10)
	var c = rng.randi_range(2, 15)
	var d: int
	
	if direct:
		d = int(float(b * c) / float(a))
		CorrectAnswer = d
		return {
			"values": [a, b, c],
			"operation": OPERATION.PROPORTION_DIRECT,
			"answer": CorrectAnswer,
			"problem_text": "If %d is to %d, then %d is to how much? " % [a, b, c],
		}
	else:
		d = int(float(a * b) / float(c))
		CorrectAnswer = d
		return {
			"values": [a, b, c],
			"operation": OPERATION.PROPORTION_INVERSE,
			"answer": CorrectAnswer,
			"problem_text": "In inverse proportion: if %d needs %d, how much does %d need? " % [a, b, c],
		}

# ===== REGLA DE TRES =====
func _generate_rule_of_three(diff: int, direct: bool) -> Dictionary:
	var items = ["apples", "books", "candies", "pens", "hours", "days"]
	var item = items[rng.randi() % items.size()]
	
	var a = rng.randi_range(2, 10)
	var b = rng.randi_range(10, 100 + diff * 50)
	var c = rng.randi_range(3, 15)
	var d: int
	
	if direct:
		d = int(float(b * c) / float(a))
		CorrectAnswer = d
		return {
			"values": [a, b, c],
			"operation": OPERATION.RULE_OF_THREE_DIRECT,
			"answer": CorrectAnswer,
			"problem_text": "If %d %s cost $%d, how much will %d %s cost? " % [a, item, b, c, item],
		}
	else:
		d = int(float(a * b) / float(c))
		CorrectAnswer = d
		return {
			"values": [a, b, c],
			"operation": OPERATION.RULE_OF_THREE_INVERSE,
			"answer": CorrectAnswer,
			"problem_text": "%d workers take %d days. How many days will %d workers take? " % [a, b, c],
		}

# ===== POTENCIAS Y RAÍCES =====
func _generate_power(diff: int) -> Dictionary:
	var base = rng.randi_range(2, 5 + diff)
	var fake_exp = rng.randi_range(2, 3) if diff < 4 else rng.randi_range(2, 4)
	CorrectAnswer = int(pow(base, fake_exp))
	
	return {
		"operand1": base,
		"operand2": fake_exp,
		"operation": OPERATION.POWER,
		"answer": CorrectAnswer,
		"problem_text": "What is %d raised to the power of %d? " % [base, fake_exp],
	}

func _generate_square_root(diff: int) -> Dictionary:
	var root = rng.randi_range(2, 8 + diff)
	var value = root * root
	CorrectAnswer = root
	
	return {
		"operand1": value,
		"operation": OPERATION.SQUARE_ROOT,
		"answer": CorrectAnswer,
		"problem_text": "What is the square root of %d? " % value,
	}

func _generate_cube_root(_diff: int) -> Dictionary:
	var root = rng.randi_range(2, 5)
	var value = root * root * root
	CorrectAnswer = root
	
	return {
		"operand1": value,
		"operation": OPERATION.CUBE_ROOT,
		"answer": CorrectAnswer,
		"problem_text": "What is the cube root of %d? " % value,
	}

# ===== GENERACIÓN DE OPCIONES =====
func GenerateOptions(problem_data: Dictionary, count: int = 4) -> Array:
	var correct = problem_data["answer"]
	var options = [correct]
	
	var correct_val = correct if typeof(correct) != TYPE_STRING else problem_data.get("answer_decimal", 0)
	
	var attempts = 0
	while options.size() < count and attempts < 50:
		attempts += 1
		var fake
		
		if typeof(correct) == TYPE_STRING:
			fake = snappedf(correct_val + rng.randf_range(-5, 5), 0.01)
			if fake not in options and fake > 0:
				options.append(fake)
		elif typeof(correct_val) == TYPE_FLOAT:
			var offset = rng.randf_range(-correct_val * 0.3, correct_val * 0.3)
			fake = snappedf(correct_val + offset, 0.01)
			if fake not in options and fake > 0:
				options.append(fake)
		else:
			var offset_pct = rng.randf_range(0.1, 0.5)
			var offset = int(correct_val * offset_pct)
			if offset == 0:
				offset = rng.randi_range(1, 5)
			fake = correct_val + (offset if rng.randf() > 0.5 else -offset)
			if fake not in options and fake > 0:
				options.append(fake)
	
	options.shuffle()
	return options

func GetProblemText(problem_data: Dictionary) -> String:
	return problem_data.get("problem_text", "Error: problema no formateado")
