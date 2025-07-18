extends Node

class_name PID

var Kp: float = 1.0
var Ki: float = 0
var Kd: float = 0

var previous_error: float = 0.0
var integral: float = 0.0

func compute(setpoint: float, measured_value: float, delta_time: float) -> float:
	var error: float = setpoint - measured_value
	var proportional: float = Kp * error
	integral += error * delta_time
	var integral_term: float = Ki * integral
	var derivative: float = (error - previous_error) / delta_time
	var derivative_term: float = Kd * derivative
	previous_error = error
	return proportional + integral_term + derivative_term
