extends Node2D

signal TiempoAgotado
signal TiempoActualizado(NuevoTiempo)

@onready var CapsuleSprite = $Capsule
@onready var BarSprite = $Capsule/Bar
var TweenAnim: Tween
var ShakeTween: Tween

var TiempoTotal: float = 30.0
var TiempoActual: float = 30.0
var TiempoExtraPorPunto: float = 0.5
var TiempoCorriendo: bool = true

var ShakeActivo: bool = false
var RotacionOriginal: float = 0.0
var UmbralShake: float = 15.0
var MaxRotacion: float = 2.5
var FrecuenciaShake: float = 1.5  # Frecuencia fija


func _ready():
	BarSprite.scale.x = 1.0
	TiempoActual = TiempoTotal
	RotacionOriginal = CapsuleSprite.rotation_degrees


func _process(delta):
	if not TiempoCorriendo:
		return

	TiempoActual -= delta
	BarSprite.scale.x = clamp(TiempoActual / TiempoTotal, 0.0, 1.0)
	ControlarShake()
	TiempoActualizado.emit(TiempoActual)

	if TiempoActual <= 0:
		TiempoCorriendo = false
		TiempoAgotado.emit()
		DetenerShake()


func ControlarShake():
	if TiempoActual <= UmbralShake and not ShakeActivo:
		IniciarShake()
	elif TiempoActual > UmbralShake and ShakeActivo:
		DetenerShake()


func IniciarShake():
	ShakeActivo = true
	if ShakeTween:
		ShakeTween.kill()
	CrearTweenOscilacion()


func CrearTweenOscilacion():
	ShakeTween = create_tween()
	ShakeTween.set_loops()
	
	# Oscilación continua con frecuencia fija
	ShakeTween.tween_property(CapsuleSprite, "rotation_degrees",
		RotacionOriginal + MaxRotacion, 0.5 / FrecuenciaShake).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ShakeTween.tween_property(CapsuleSprite, "rotation_degrees",
		RotacionOriginal - MaxRotacion, 1.0 / FrecuenciaShake).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ShakeTween.tween_property(CapsuleSprite, "rotation_degrees",
		RotacionOriginal, 0.5 / FrecuenciaShake).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func DetenerShake():
	ShakeActivo = false
	if ShakeTween:
		ShakeTween.kill()
		ShakeTween = null
	
	var RestoreTween = create_tween()
	RestoreTween.tween_property(CapsuleSprite, "rotation_degrees", RotacionOriginal, 0.2)


func AgregarTiempoExtra(Cantidad: float = 0.5):
	if not TiempoCorriendo:
		return
	TiempoActual = min(TiempoActual + Cantidad, TiempoTotal)
	var NuevoPorcentaje = clamp(TiempoActual / TiempoTotal, 0.0, 1.0)

	if TweenAnim:
		TweenAnim.kill()
	TweenAnim = create_tween()
	TweenAnim.tween_property(BarSprite, "scale:x", NuevoPorcentaje, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	TiempoActualizado.emit(TiempoActual)

	var BrilloTween = create_tween()
	BrilloTween.tween_property(BarSprite, "modulate", Color(1.5, 1.5, 1.5, 1), 0.15)
	BrilloTween.tween_property(BarSprite, "modulate", Color(1, 1, 1, 1), 0.25)


func PausarTiempo():
	TiempoCorriendo = false
	if ShakeActivo:
		DetenerShake()


func ReanudarTiempo():
	TiempoCorriendo = true


func ReiniciarTiempo():
	TiempoActual = TiempoTotal
	TiempoCorriendo = true
	BarSprite.scale.x = 1.0
	BarSprite.modulate = Color(1, 1, 1, 1)
	CapsuleSprite.rotation_degrees = RotacionOriginal
	DetenerShake()


func EstablecerTiempoTotal(NuevoTiempo: float):
	TiempoTotal = NuevoTiempo
	TiempoActual = NuevoTiempo
	UmbralShake = NuevoTiempo * 0.5
	BarSprite.scale.x = 1.0
	BarSprite.modulate = Color(1, 1, 1, 1)
	CapsuleSprite.rotation_degrees = RotacionOriginal
	DetenerShake()
