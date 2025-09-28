extends Node

class_name PID3

var Kp: float = 1
var Ki: float = 0
var Kd: float = 0

var previous_error: Vector3 = Vector3()
var integral: Vector3 = Vector3()

func compute(setpoint: Vector3, measured_value: Vector3, delta_time: float) -> Vector3:
	var error: Vector3 = setpoint - measured_value
	var proportional: Vector3 = Kp * error
	integral += error * delta_time
	var integral_term: Vector3 = Ki * integral
	var derivative: Vector3 = (error - previous_error) / delta_time
	var derivative_term: Vector3 = Kd * derivative
	previous_error = error
	return proportional + integral_term + derivative_term
