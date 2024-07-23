@tool
class_name Profession
extends Node
## The profession of a game actor.
##
## Assigns a set of stats to a pawn, 

@export var starting_stats: Resource
@export var starting_skills: Array[String]
#@export var character_skill_scene: PackedScene

@onready var stats = $Stats
@onready var skills = $Skills


func _ready():
	stats.init(starting_stats)
	#if starting_skills != null and starting_skills.size() > 0:
		#for skill in starting_skills:
			#var new_skill = character_skill_scene.instance()
			#new_skill.init(skill)
			#skills.add_child(new_skill)
