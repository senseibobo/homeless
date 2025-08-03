class_name PersonAi
extends Resource


enum State
{
	STANDING_WAITING,
	SITTING,
	GOING_TO_CHAIR,
	CHECKING,
	GOING_TO_PERSON_CHECK,
}


var state: State
var person: Person


func init(person: Person):
	self.person = person


func _process(delta):
	match state:
		State.STANDING_WAITING:
			pass
