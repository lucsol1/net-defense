extends Node
class_name Server

var hp: int = 1000
var processing_power: int = 0  # seu "throughput"
var firewall: int = 0           # poder de bloqueio
var packet_queue: Array[Packet] = []
